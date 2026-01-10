//
//  HealthManagerTests.swift
//  HongKongHealthApp
//
//  Created by Ye on 15/1/2026.
//


import XCTest
@testable import HongKongHealthApp

final class HealthManagerTests: XCTestCase {
    
    var healthManager: HealthManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        healthManager = HealthManager()
    }
    
    override func tearDownWithError() throws {
        healthManager = nil
        try super.tearDownWithError()
    }
    
    func testInitialValues() throws {
        XCTAssertEqual(healthManager.todaySteps, 0)
        XCTAssertEqual(healthManager.todayCalories, 0)
        XCTAssertEqual(healthManager.todayExerciseMinutes, 0)
    }
}
