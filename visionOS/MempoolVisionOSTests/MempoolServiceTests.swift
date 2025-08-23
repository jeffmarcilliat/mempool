import XCTest
@testable import MempoolVisionOS

final class MempoolServiceTests: XCTestCase {
    var mempoolService: MempoolService!
    
    override func setUpWithError() throws {
        mempoolService = MempoolService()
    }
    
    override func tearDownWithError() throws {
        mempoolService = nil
    }
    
    func testInitialConfiguration() {
        XCTAssertFalse(mempoolService.isUsingSelfHosted)
        XCTAssertEqual(mempoolService.selfHostedURL, "http://localhost:8999")
    }
    
    func testConfigurationSwitching() {
        mempoolService.isUsingSelfHosted = true
        mempoolService.selfHostedURL = "http://192.168.1.100:8999"
        
        XCTAssertTrue(mempoolService.isUsingSelfHosted)
        XCTAssertEqual(mempoolService.selfHostedURL, "http://192.168.1.100:8999")
    }
    
    func testFetchBlocksPublicAPI() async {
        mempoolService.isUsingSelfHosted = false
        
        await mempoolService.fetchBlocks()
        
        XCTAssertFalse(mempoolService.blocks.isEmpty, "Should fetch blocks from public API")
    }
    
    func testSearchTransactionOrAddress() async {
        let validTxId = "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"
        
        let results = await mempoolService.searchTransactionOrAddress(validTxId)
        
        XCTAssertFalse(results.isEmpty, "Should return search results for valid transaction ID")
    }
    
    func testSearchEmptyQuery() async {
        let results = await mempoolService.searchTransactionOrAddress("")
        
        XCTAssertTrue(results.isEmpty, "Should return empty results for empty query")
    }
    
    func testWebSocketConnection() {
        let expectation = XCTestExpectation(description: "WebSocket connection")
        
        mempoolService.connectWebSocket()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertTrue(self.mempoolService.isConnectedToWebSocket, "Should connect to WebSocket")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testReconnectWithNewConfiguration() async {
        mempoolService.connectWebSocket()
        
        await mempoolService.reconnectWithNewConfiguration()
        
        XCTAssertTrue(mempoolService.isConnectedToWebSocket, "Should reconnect after configuration change")
    }
}
