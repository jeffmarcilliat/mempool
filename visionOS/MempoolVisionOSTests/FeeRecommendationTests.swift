import XCTest
@testable import MempoolVisionOS

final class FeeRecommendationTests: XCTestCase {
    var mempoolService: MempoolService!
    
    override func setUpWithError() throws {
        mempoolService = MempoolService()
    }
    
    override func tearDownWithError() throws {
        mempoolService = nil
    }
    
    func testRecommendedFeesStructure() {
        let fees = RecommendedFees(
            fastestFee: 50,
            halfHourFee: 30,
            hourFee: 20,
            economyFee: 10,
            minimumFee: 1
        )
        
        XCTAssertEqual(fees.fastestFee, 50)
        XCTAssertEqual(fees.halfHourFee, 30)
        XCTAssertEqual(fees.hourFee, 20)
        XCTAssertEqual(fees.economyFee, 10)
        XCTAssertEqual(fees.minimumFee, 1)
    }
    
    func testFeeRecommendationsFromWebSocket() {
        let expectation = XCTestExpectation(description: "Fee recommendations received")
        
        mempoolService.connectWebSocket()
        
        let cancellable = mempoolService.$recommendedFees
            .compactMap { $0 }
            .first()
            .sink { fees in
                XCTAssertNotNil(fees)
                XCTAssertGreaterThan(fees.fastestFee, 0)
                XCTAssertGreaterThan(fees.halfHourFee, 0)
                XCTAssertGreaterThan(fees.hourFee, 0)
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 10.0)
        cancellable.cancel()
    }
    
    func testFeeOrderingLogic() {
        let fees = RecommendedFees(
            fastestFee: 50,
            halfHourFee: 30,
            hourFee: 20,
            economyFee: 10,
            minimumFee: 1
        )
        
        XCTAssertGreaterThanOrEqual(fees.fastestFee, fees.halfHourFee)
        XCTAssertGreaterThanOrEqual(fees.halfHourFee, fees.hourFee)
        XCTAssertGreaterThanOrEqual(fees.hourFee, fees.economyFee)
        XCTAssertGreaterThanOrEqual(fees.economyFee, fees.minimumFee)
    }
    
    func testMempoolStrataStructure() {
        let strata = MempoolStrata(
            feeRange: 10.0...20.0,
            transactionCount: 100,
            totalSize: 50000,
            averageFee: 15.0,
            color: .orange
        )
        
        XCTAssertEqual(strata.feeRange.lowerBound, 10.0)
        XCTAssertEqual(strata.feeRange.upperBound, 20.0)
        XCTAssertEqual(strata.transactionCount, 100)
        XCTAssertEqual(strata.totalSize, 50000)
        XCTAssertEqual(strata.averageFee, 15.0)
        XCTAssertEqual(strata.color, .orange)
    }
    
    func testMempoolStrataColors() {
        let redStrata = MempoolStrata(feeRange: 100.0...200.0, transactionCount: 10, totalSize: 5000, averageFee: 150.0, color: .red)
        let orangeStrata = MempoolStrata(feeRange: 50.0...100.0, transactionCount: 20, totalSize: 10000, averageFee: 75.0, color: .orange)
        let yellowStrata = MempoolStrata(feeRange: 20.0...50.0, transactionCount: 30, totalSize: 15000, averageFee: 35.0, color: .yellow)
        let greenStrata = MempoolStrata(feeRange: 1.0...20.0, transactionCount: 40, totalSize: 20000, averageFee: 10.0, color: .green)
        
        XCTAssertEqual(redStrata.color, .red)
        XCTAssertEqual(orangeStrata.color, .orange)
        XCTAssertEqual(yellowStrata.color, .yellow)
        XCTAssertEqual(greenStrata.color, .green)
    }
}
