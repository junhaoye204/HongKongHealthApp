import XCTest

final class UITestsNavigation: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    @MainActor
    func testLoginViewElements() throws {
        let app = XCUIApplication()
        XCTAssertTrue(app.textFields["電郵"].exists)
        XCTAssertTrue(app.secureTextFields["密碼"].exists)
        XCTAssertTrue(app.buttons["登入"].exists)
    }
    
    @MainActor
    func testNavigateToSignupView() throws {
        let app = XCUIApplication()
        app.buttons["未有帳戶？註冊"].tap()
        XCTAssertTrue(app.staticTexts["註冊 Hong Kong Health"].exists)
    }
    
    @MainActor
    func testTabBarExists() throws {
        let app = XCUIApplication()
        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
        XCTAssertTrue(app.tabBars.buttons["Food Log"].exists)
        XCTAssertTrue(app.tabBars.buttons["Exercise"].exists)
        XCTAssertTrue(app.tabBars.buttons["Hiking"].exists)
        XCTAssertTrue(app.tabBars.buttons["Profile"].exists)
    }
}
