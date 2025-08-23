import XCTest
@testable import MempoolVisionOS

final class SearchFunctionalityTests: XCTestCase {
    var mempoolService: MempoolService!
    
    override func setUpWithError() throws {
        mempoolService = MempoolService()
    }
    
    override func tearDownWithError() throws {
        mempoolService = nil
    }
    
    func testValidTransactionIdSearch() async {
        let validTxId = "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"
        
        let results = await mempoolService.searchTransactionOrAddress(validTxId)
        
        if !results.isEmpty {
            XCTAssertEqual(results.first?.type, .transaction)
            XCTAssertEqual(results.first?.title, "Transaction")
        }
    }
    
    func testValidAddressSearch() async {
        let validAddress = "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
        
        let results = await mempoolService.searchTransactionOrAddress(validAddress)
        
        if !results.isEmpty {
            XCTAssertEqual(results.first?.type, .address)
            XCTAssertEqual(results.first?.title, "Address")
        }
    }
    
    func testInvalidSearch() async {
        let invalidQuery = "invalid_query"
        
        let results = await mempoolService.searchTransactionOrAddress(invalidQuery)
        
        XCTAssertTrue(results.isEmpty, "Should return empty results for invalid query")
    }
    
    func testEmptySearch() async {
        let results = await mempoolService.searchTransactionOrAddress("")
        
        XCTAssertTrue(results.isEmpty, "Should return empty results for empty query")
    }
    
    func testSearchResultStructure() {
        let searchResult = SearchResult(
            type: .transaction,
            title: "Test Transaction",
            subtitle: "test_subtitle"
        )
        
        XCTAssertEqual(searchResult.type, .transaction)
        XCTAssertEqual(searchResult.title, "Test Transaction")
        XCTAssertEqual(searchResult.subtitle, "test_subtitle")
        XCTAssertNotNil(searchResult.id)
    }
    
    func testSearchResultTypes() {
        let transactionResult = SearchResult(type: .transaction, title: "TX", subtitle: "tx_id")
        let addressResult = SearchResult(type: .address, title: "Address", subtitle: "address")
        let blockResult = SearchResult(type: .block, title: "Block", subtitle: "block_hash")
        
        XCTAssertEqual(transactionResult.type, .transaction)
        XCTAssertEqual(addressResult.type, .address)
        XCTAssertEqual(blockResult.type, .block)
    }
}
