import XCTest
@testable import HongKongHealthApp

final class AuthManagerTests: XCTestCase {
    
    var authManager: AuthManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        authManager = AuthManager.shared
    }
    
    override func tearDownWithError() throws {
        authManager.logout()
        authManager = nil
        try super.tearDownWithError()
    }
    
    func testLoginLogoutFlow() throws {
        // 模擬登入
        authManager.isLoggedIn = true
        XCTAssertTrue(authManager.isLoggedIn, "登入後應該是 true")
        
        // 模擬登出
        authManager.logout()
        XCTAssertFalse(authManager.isLoggedIn, "登出後應該是 false")
    }
}
