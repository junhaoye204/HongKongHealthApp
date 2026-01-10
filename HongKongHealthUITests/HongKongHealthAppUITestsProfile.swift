//
//  abc.swift
//  HongKongHealthApp
//
//  Created by Ye on 15/1/2026.
//

import XCTest

final class HongKongHealthAppUITestsProfile: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    func testProfileTabExists() {
        let app = XCUIApplication()
        XCTAssertTrue(app.tabBars.buttons["Profile"].exists)
    }
    
    func testProfileScreenElements() {
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        
        // Verify profile icon or name field exists
        XCTAssertTrue(app.images["person.fill"].exists || app.staticTexts["Profile"].exists)
    }
}
