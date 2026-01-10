//
//  LocalStoreTests.swift
//  HongKongHealthApp
//
//  Created by Ye on 15/1/2026.
//


import XCTest
@testable import HongKongHealthApp

final class LocalStoreTests: XCTestCase {
    var store: LocalStore!

    override func setUpWithError() throws {
        try super.setUpWithError()
        store = LocalStore.shared
        // 清理狀態
        store.meals = []
        store.hikes = []
        store.todayWaterGlasses = 0
        store.moodEntries = []
        UserDefaults.standard.removeObject(forKey: "todayWaterGlasses")
        UserDefaults.standard.removeObject(forKey: "moodEntries")
    }

    override func tearDownWithError() throws {
        store = nil
        try super.tearDownWithError()
    }

    func testAddMealInsertsAtFront() {
        let meal = MealEntry(name: "Test Meal", calories: 100, saltLevel: "low")
        store.addMeal(meal)
        XCTAssertEqual(store.meals.first?.name, "Test Meal")
    }

    func testAddWaterGlassPersists() {
        store.addWaterGlass()
        XCTAssertEqual(store.todayWaterGlasses, 1)
        let saved = UserDefaults.standard.integer(forKey: "todayWaterGlasses")
        XCTAssertEqual(saved, 1)
    }

    func testMoodSaveAndLoad() {
        let mood = MoodEntry(mood: 4, stress: 2, note: "ok")
        store.addMood(mood)
        // reload into a new instance simulation
        let data = UserDefaults.standard.data(forKey: "moodEntries")
        XCTAssertNotNil(data)
        if let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data!) {
            XCTAssertEqual(decoded.first?.note, "ok")
        } else {
            XCTFail("Failed to decode moods")
        }
    }
}
