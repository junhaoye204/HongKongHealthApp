import Foundation
import SwiftUI

final class LocalStore: ObservableObject {
    static let shared = LocalStore()

    @Published var meals: [MealEntry] = []
    @Published var foodDB: [MealEntry] = []
    @Published var hikes: [HikeEntry] = []
    @Published var todayWaterGlasses: Int = 0
    @Published var dailyTip: String = "記得多飲水，保持水分充足！"
    @Published var latestFoodDescription: String = ""
    @Published var moodEntries: [MoodEntry] = []

    private init() {
        loadSampleDataIfNeeded()
        loadWaterData()
        loadMoods()
    }

    func loadSampleDataIfNeeded() {
        if meals.isEmpty {
            meals = [
                MealEntry(name: "Steamed Fish", calories: 320, saltLevel: "low"),
                MealEntry(name: "Two-dish set meal", calories: 800, saltLevel: "high")
            ]
        }
        if foodDB.isEmpty {
            foodDB = [
                MealEntry(name: "Char Siu Rice", calories: 650, saltLevel: "high"),
                MealEntry(name: "Steamed Fish", calories: 320, saltLevel: "low"),
                MealEntry(name: "Vegetable Congee", calories: 220, saltLevel: "low")
            ]
        }
    }

    func addMeal(_ meal: MealEntry) { meals.insert(meal, at: 0) }
    func addHike(_ hike: HikeEntry) { hikes.insert(hike, at: 0) }

    func addWaterGlass() {
        todayWaterGlasses += 1
        UserDefaults.standard.set(todayWaterGlasses, forKey: "todayWaterGlasses")
        objectWillChange.send()
    }

    func resetDailyData() {
        todayWaterGlasses = 0
        UserDefaults.standard.set(0, forKey: "todayWaterGlasses")
        objectWillChange.send()
    }

    private func loadWaterData() {
        todayWaterGlasses = UserDefaults.standard.integer(forKey: "todayWaterGlasses")
        let lastCheck = UserDefaults.standard.object(forKey: "lastWaterCheckDate") as? Date ?? Date.distantPast
        if !Calendar.current.isDateInToday(lastCheck) { resetDailyData() }
        UserDefaults.standard.set(Date(), forKey: "lastWaterCheckDate")
    }

    func addMood(_ mood: MoodEntry) {
        moodEntries.insert(mood, at: 0)
        saveMoods()
    }

    private func loadMoods() {
        if let data = UserDefaults.standard.data(forKey: "moodEntries"),
           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            moodEntries = decoded
        }
    }

    private func saveMoods() {
        if let encoded = try? JSONEncoder().encode(moodEntries) {
            UserDefaults.standard.set(encoded, forKey: "moodEntries")
        }
    }
}