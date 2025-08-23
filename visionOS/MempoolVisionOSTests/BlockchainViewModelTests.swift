import XCTest
@testable import MempoolVisionOS

@MainActor
final class BlockchainViewModelTests: XCTestCase {
    var viewModel: BlockchainViewModel!
    
    override func setUpWithError() throws {
        viewModel = BlockchainViewModel()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func testInitialState() {
        XCTAssertNil(viewModel.selectedBlock)
        XCTAssertNil(viewModel.selectedTransaction)
        XCTAssertEqual(viewModel.currentView, .blockchain)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }
    
    func testLoadData() async {
        await viewModel.loadData()
        
        XCTAssertFalse(viewModel.isLoading, "Loading should complete")
        XCTAssertFalse(viewModel.blocks.isEmpty, "Should load blocks")
    }
    
    func testSelectBlock() {
        let testBlock = Block(
            id: "test_block",
            height: 800000,
            timestamp: Int(Date().timeIntervalSince1970),
            txCount: 1000,
            size: 1000000,
            weight: 4000000,
            difficulty: 50000000000.0
        )
        
        viewModel.selectBlock(testBlock)
        
        XCTAssertEqual(viewModel.selectedBlock?.id, testBlock.id)
        XCTAssertEqual(viewModel.currentView, .blockchain)
    }
    
    func testSelectTransaction() {
        let testTransaction = Transaction(
            id: "test_tx",
            fee: 1000,
            size: 250,
            weight: 1000,
            status: Transaction.TransactionStatus(confirmed: true, blockHeight: 800000, blockHash: "test_hash", blockTime: Int(Date().timeIntervalSince1970)),
            vin: [],
            vout: []
        )
        
        viewModel.selectTransaction(testTransaction)
        
        XCTAssertEqual(viewModel.selectedTransaction?.id, testTransaction.id)
        XCTAssertEqual(viewModel.currentView, .transaction)
    }
    
    func testShowMempool() {
        viewModel.showMempool()
        
        XCTAssertEqual(viewModel.currentView, .mempool)
    }
    
    func testGoToLatestBlock() async {
        await viewModel.loadData()
        
        viewModel.goToLatestBlock()
        
        if !viewModel.blocks.isEmpty {
            XCTAssertNotNil(viewModel.selectedBlock)
            XCTAssertEqual(viewModel.currentView, .blockDetail)
        }
    }
    
    func testSearchFunctionality() async {
        let query = "test_query"
        
        let results = await viewModel.searchTransactionOrAddress(query)
        
        XCTAssertEqual(viewModel.searchResults, results)
    }
    
    func testConnectToRealTimeData() {
        viewModel.connectToRealTimeData()
        
        XCTAssertNotNil(viewModel.mempoolService)
    }
}
