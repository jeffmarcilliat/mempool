import Foundation
import SwiftUI
import RealityKit
import Combine

@MainActor
class BlockchainViewModel: ObservableObject {
    @Published var selectedBlock: Block?
    @Published var selectedTransaction: Transaction?
    @Published var selectedUTXOs: [UTXO] = []
    @Published var currentView: ViewType = .blockchain
    @Published var isLoading = false
    @Published var cameraPosition: SIMD3<Float> = SIMD3<Float>(0, 0, 5)
    @Published var feeDistribution: [Double] = []
    @Published var errorMessage: String?
    @Published var mempoolStrata: [MempoolStrata] = []
    @Published var recommendedFees: RecommendedFees?
    @Published var isConnectedToWebSocket = false
    @Published var searchResults: [SearchResult] = []

    private let mempoolService = MempoolService()
    private var cancellables = Set<AnyCancellable>()

    enum ViewType {
        case blockchain
        case mempool
        case transaction
        case utxo
        case chain
        case feeMarket
        case blockDetail
        case transactionDetail
        case utxoExplorer
    }

    var blocks: [Block] {
        mempoolService.blocks
    }

    var mempoolTransactions: [Transaction] {
        mempoolService.mempoolTransactions
    }
    
    init() {
        mempoolService.$mempoolStrata
            .receive(on: DispatchQueue.main)
            .assign(to: \.mempoolStrata, on: self)
            .store(in: &cancellables)
        
        mempoolService.$recommendedFees
            .receive(on: DispatchQueue.main)
            .assign(to: \.recommendedFees, on: self)
            .store(in: &cancellables)
        
        mempoolService.$isConnectedToWebSocket
            .receive(on: DispatchQueue.main)
            .assign(to: \.isConnectedToWebSocket, on: self)
            .store(in: &cancellables)
    }

    func loadData() async {
        isLoading = true
        
        // Fetch blocks first (this is the critical data we need)
        await mempoolService.fetchBlocks()
        
        // Try to fetch mempool, but don't let it block the UI if it fails
        await mempoolService.fetchMempool()
        
        // Always clear loading state, even if mempool fails
        isLoading = false
        print("✅ Data loading completed. Blocks: \(blocks.count)")
    }

    func selectBlock(_ block: Block) {
        selectedBlock = block
        currentView = .blockchain
    }

    func selectTransaction(_ transaction: Transaction) {
        selectedTransaction = transaction
        currentView = .transaction
    }

    func showMempool() {
        currentView = .mempool
    }
    
    func resetCamera() {
        cameraPosition = SIMD3<Float>(0, 0, 5)
    }
    
    func goToLatestBlock() {
        if let latestBlock = blocks.first {
            selectedBlock = latestBlock
            currentView = .blockDetail
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func connectToRealTimeData() {
        mempoolService.connectWebSocket()
    }
    
    func searchTransactionOrAddress(_ query: String) async -> [SearchResult] {
        let results = await mempoolService.searchTransactionOrAddress(query)
        await MainActor.run {
            self.searchResults = results
        }
        return results
    }
}
