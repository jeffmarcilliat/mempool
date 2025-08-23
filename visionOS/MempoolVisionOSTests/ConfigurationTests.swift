import XCTest
@testable import MempoolVisionOS

final class ConfigurationTests: XCTestCase {
    var mempoolService: MempoolService!
    
    override func setUpWithError() throws {
        mempoolService = MempoolService()
        UserDefaults.standard.removeObject(forKey: "isUsingSelfHosted")
        UserDefaults.standard.removeObject(forKey: "selfHostedURL")
    }
    
    override func tearDownWithError() throws {
        mempoolService = nil
        UserDefaults.standard.removeObject(forKey: "isUsingSelfHosted")
        UserDefaults.standard.removeObject(forKey: "selfHostedURL")
    }
    
    func testDefaultConfiguration() {
        let service = MempoolService()
        
        XCTAssertFalse(service.isUsingSelfHosted)
        XCTAssertEqual(service.selfHostedURL, "http://localhost:8999")
    }
    
    func testConfigurationPersistence() {
        UserDefaults.standard.set(true, forKey: "isUsingSelfHosted")
        UserDefaults.standard.set("http://192.168.1.100:8999", forKey: "selfHostedURL")
        
        let service = MempoolService()
        
        XCTAssertTrue(service.isUsingSelfHosted)
        XCTAssertEqual(service.selfHostedURL, "http://192.168.1.100:8999")
    }
    
    func testSelfHostedURLGeneration() {
        mempoolService.isUsingSelfHosted = true
        mempoolService.selfHostedURL = "http://localhost:8999"
        
        XCTAssertEqual(mempoolService.selfHostedURL, "http://localhost:8999")
        XCTAssertTrue(mempoolService.isUsingSelfHosted)
    }
    
    func testPublicAPIURLGeneration() {
        mempoolService.isUsingSelfHosted = false
        
        XCTAssertFalse(mempoolService.isUsingSelfHosted)
    }
    
    func testHTTPSToWSConversion() {
        mempoolService.isUsingSelfHosted = true
        mempoolService.selfHostedURL = "https://my-mempool.example.com"
        
        XCTAssertEqual(mempoolService.selfHostedURL, "https://my-mempool.example.com")
        XCTAssertTrue(mempoolService.isUsingSelfHosted)
    }
    
    func testReconnectWithNewConfiguration() async {
        mempoolService.connectWebSocket()
        
        let wasConnected = mempoolService.isConnectedToWebSocket
        
        await mempoolService.reconnectWithNewConfiguration()
        
        XCTAssertTrue(mempoolService.isConnectedToWebSocket)
    }
}
