import Foundation
import Combine
import SwiftUI

@MainActor
class BlockchainViewModel: ObservableObject {
    private let mempoolService = MempoolService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published Properties
    
    @Published var selectedBlock: Block?
    @Published var selectedTransaction: Transaction?
    @Published var selectedUTXOs: [UTXO] = []
    @Published var blocks: [Block] = []
    @Published var mempoolTransactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentView: BlockchainView = .chain
    
    // Network stats
    @Published var currentHeight: Int = 0
    @Published var mempoolSize: Int = 0
    @Published var averageFee: Double = 0.0
    
    // 3D Scene properties
    @Published var cameraPosition: SIMD3<Float> = SIMD3(0, 0, 5)
    @Published var selectedBlockPosition: SIMD3<Float>?
    @Published var animationState: AnimationState = .idle
    
    // MARK: - Enums
    
    enum BlockchainView {
        case chain
        case mempool
        case feeMarket
        case blockDetail
        case transactionDetail
        case utxoExplorer
    }
    
    enum AnimationState {
        case idle
        case loading
        case transitioning
        case exploring
    }
    
    // MARK: - Initialization
    
    init() {
        setupBindings()
        loadInitialData()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Bind mempool service updates
        mempoolService.$currentHeight
            .assign(to: \.currentHeight, on: self)
            .store(in: &cancellables)
        
        mempoolService.$mempoolSize
            .assign(to: \.mempoolSize, on: self)
            .store(in: &cancellables)
        
        mempoolService.$averageFee
            .assign(to: \.averageFee, on: self)
            .store(in: &cancellables)
        
        mempoolService.$recentBlocks
            .assign(to: \.blocks, on: self)
            .store(in: &cancellables)
        
        mempoolService.$mempoolTransactions
            .assign(to: \.mempoolTransactions, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    private func loadInitialData() {
        isLoading = true
        
        // Load recent blocks
        mempoolService.fetchBlocks(limit: 20)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] blocks in
                    self?.blocks = blocks
                    self?.selectedBlock = blocks.first
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Navigation Methods
    
    func goToLatestBlock() {
        guard let latestBlock = blocks.first else { return }
        selectBlock(latestBlock)
        currentView = .blockDetail
        animateToBlock(latestBlock)
    }
    
    func showMempool() {
        currentView = .mempool
        animationState = .transitioning
        
        // Load mempool transactions if not already loaded
        if mempoolTransactions.isEmpty {
            loadMempoolTransactions()
        }
    }
    
    func showFeeMarket() {
        currentView = .feeMarket
        animationState = .transitioning
    }
    
    func selectBlock(_ block: Block) {
        selectedBlock = block
        selectedTransaction = nil
        selectedUTXOs = []
        
        // Load block transactions
        loadBlockTransactions(for: block)
    }
    
    func selectTransaction(_ transaction: Transaction) {
        selectedTransaction = transaction
        currentView = .transactionDetail
        animationState = .exploring
        
        // Load transaction UTXOs if needed
        loadTransactionUTXOs(for: transaction)
    }
    
    func exploreUTXOs(for address: String) {
        currentView = .utxoExplorer
        animationState = .loading
        
        mempoolService.fetchAddressUTXOs(address: address)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.animationState = .idle
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] utxos in
                    self?.selectedUTXOs = utxos
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading Methods
    
    private func loadBlockTransactions(for block: Block) {
        mempoolService.fetchBlockTransactions(hash: block.id)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { transactions in
                    // Handle block transactions
                    print("Loaded \(transactions.count) transactions for block \(block.height)")
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadMempoolTransactions() {
        mempoolService.fetchMempoolTransactions()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] transactions in
                    self?.mempoolTransactions = transactions
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadTransactionUTXOs(for transaction: Transaction) {
        // For each input, fetch the UTXO it's spending
        let inputPromises = transaction.vin.compactMap { input -> AnyPublisher<UTXO?, Error>? in
            guard !input.isCoinbase else { return nil }
            
            // In a real implementation, you'd fetch the UTXO from the previous transaction
            // For now, we'll create a placeholder
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // Combine all UTXO fetches
        Publishers.MergeMany(inputPromises)
            .collect()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to load UTXOs: \(error)")
                    }
                },
                receiveValue: { utxos in
                    // Handle loaded UTXOs
                    print("Loaded \(utxos.count) UTXOs for transaction")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - 3D Scene Methods
    
    func animateToBlock(_ block: Block) {
        animationState = .transitioning
        
        // Calculate position based on block height
        let blockIndex = blocks.firstIndex(of: block) ?? 0
        let targetPosition = SIMD3<Float>(
            Float(blockIndex) * 0.3,
            0,
            0
        )
        
        // Animate camera to block position
        withAnimation(.easeInOut(duration: 2.0)) {
            cameraPosition = targetPosition
            selectedBlockPosition = targetPosition
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.animationState = .idle
        }
    }
    
    func resetCamera() {
        animationState = .transitioning
        
        withAnimation(.easeInOut(duration: 1.5)) {
            cameraPosition = SIMD3(0, 0, 5)
            selectedBlockPosition = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.animationState = .idle
        }
    }
    
    // MARK: - Utility Methods
    
    func clearError() {
        errorMessage = nil
    }
    
    func refreshData() {
        loadInitialData()
    }
    
    // MARK: - Computed Properties
    
    var totalBlocksValue: Double {
        blocks.reduce(0) { $0 + Double($1.totalOutputAmt) / 100_000_000.0 }
    }
    
    var averageBlockSize: Double {
        guard !blocks.isEmpty else { return 0 }
        return blocks.reduce(0) { $0 + $1.blockSize } / Double(blocks.count)
    }
    
    var feeDistribution: [String: Int] {
        var distribution: [String: Int] = [:]
        
        for transaction in mempoolTransactions {
            let feeRange: String
            if transaction.feeRate > 100 {
                feeRange = "High (>100 sat/vB)"
            } else if transaction.feeRate > 50 {
                feeRange = "Medium (50-100 sat/vB)"
            } else if transaction.feeRate > 20 {
                feeRange = "Low (20-50 sat/vB)"
            } else {
                feeRange = "Very Low (<20 sat/vB)"
            }
            
            distribution[feeRange, default: 0] += 1
        }
        
        return distribution
    }
}
