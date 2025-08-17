import Foundation
import SwiftUI
import RealityKit

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

    private let mempoolService = MempoolService()

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
}