//
//  abc.swift
//  HongKongHealthApp
//
//  Created by Ye on 15/1/2026.
//

import XCTest

final class HongKongHealthAppUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    func testLoginViewElementsExist() {
        let app = XCUIApplication()
        XCTAssertTrue(app.textFields["電郵"].exists)
        XCTAssertTrue(app.secureTextFields["密碼"].exists)
        XCTAssertTrue(app.buttons["登入"].exists)
    }
    
    func testSignupNavigation() {
        let app = XCUIApplication()
        app.buttons["未有帳戶？註冊"].tap()
        XCTAssertTrue(app.staticTexts["註冊 Hong Kong Health"].exists)
    }
    
    func testSignupFormInput() {
        let app = XCUIApplication()
        app.buttons["未有帳戶？註冊"].tap()
        let emailField = app.textFields["電郵"]
        emailField.tap()
        emailField.typeText("test@example.com")
        
        let passwordField = app.secureTextFields["密碼"]
        passwordField.tap()
        passwordField.typeText("password123")
        
        XCTAssertTrue(app.buttons["註冊"].exists)
    }
    
    func testTabBarNavigation() {
        let app = XCUIApplication()
        // Assume user is logged in and ContentView is shown
        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
        XCTAssertTrue(app.tabBars.buttons["Food Log"].exists)
        XCTAssertTrue(app.tabBars.buttons["Exercise"].exists)
        XCTAssertTrue(app.tabBars.buttons["Hiking"].exists)
        XCTAssertTrue(app.tabBars.buttons["Profile"].exists)
    }
}
