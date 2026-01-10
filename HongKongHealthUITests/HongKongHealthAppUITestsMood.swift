//
//  abc.swift
//  HongKongHealthApp
//
//  Created by Ye on 15/1/2026.
//

import XCTest

final class HongKongHealthAppUITestsMood: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    func testOpenMoodTrackerSheet() {
        let app = XCUIApplication()
        // Navigate to Home tab
        app.tabBars.buttons["Home"].tap()
        
        // Tap the share button (toolbar item)
        app.buttons["square.and.arrow.up"].tap()
        
        // Verify sheet appears
        XCTAssertTrue(app.sheets.element.exists)
    }
    
    func testDailyTipExistsOnHome() {
        let app = XCUIApplication()
        app.tabBars.buttons["Home"].tap()
        
        // Check that one of the daily tips is visible
        XCTAssertTrue(app.staticTexts["記得多飲水，保持水分充足！"].exists ||
                      app.staticTexts["每日至少行 8000 步！"].exists ||
                      app.staticTexts["均衡飲食，少鹽少糖！"].exists)
    }
}
