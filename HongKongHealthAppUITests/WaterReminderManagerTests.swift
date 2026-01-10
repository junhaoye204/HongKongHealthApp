//
//  abc.swift
//  HongKongHealthApp
//
//  Created by Ye on 15/1/2026.
//

import XCTest
@testable import HongKongHealthApp

final class WaterReminderManagerTests: XCTestCase {
    
    var manager: WaterReminderManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        manager = WaterReminderManager.shared
        manager.cancelAll() // 確保乾淨狀態
    }
    
    override func tearDownWithError() throws {
        manager.cancelAll()
        manager = nil
        try super.tearDownWithError()
    }
    
    func testScheduleHourlyReminders() throws {
        // Act
        manager.scheduleHourlyReminders()
        
        // Assert
        let expectation = XCTestExpectation(description: "Check scheduled notifications")
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            XCTAssertEqual(requests.count, 16, "應該排程 16 個提醒通知")
            XCTAssertTrue(requests.allSatisfy { $0.identifier.contains("water-reminder") })
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
}

