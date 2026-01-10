import Foundation
import HealthKit

final class HealthManager: ObservableObject {
    private let store = HKHealthStore()
    @Published var todaySteps: Int = 0
    @Published var todayExerciseMinutes: Int = 0
    @Published var todayCalories: Int = 0
    @Published var latestHeartRate: Double = 0
    @Published var lastNightSleepHours: Double = 0.0
    @Published var weeklySteps: [Int] = Array(repeating: 0, count: 7)

    init() {}

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let read: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        ]
        store.requestAuthorization(toShare: [], read: read) { success, error in
            if success {
                self.fetchTodaySteps()
                self.fetchActiveEnergy()
                self.fetchExerciseTime()
                self.readLatestHeartRate { _ in }
                self.fetchSleepEstimate()
                self.fetchWeeklySteps()
            } else {
                print("HealthKit auth failed:", error?.localizedDescription ?? "unknown")
            }
        }
    }

    func fetchTodaySteps() {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let sum = result?.sumQuantity() else { return }
            DispatchQueue.main.async { self.todaySteps = Int(sum.doubleValue(for: HKUnit.count())) }
        }
        store.execute(query)
    }

    func fetchActiveEnergy() {
        let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let sum = result?.sumQuantity() else { return }
            DispatchQueue.main.async { self.todayCalories = Int(sum.doubleValue(for: HKUnit.kilocalorie())) }
        }
        store.execute(query)
    }

    func fetchExerciseTime() {
        let type = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let sum = result?.sumQuantity() else { return }
            DispatchQueue.main.async { self.todayExerciseMinutes = Int(sum.doubleValue(for: HKUnit.minute())) }
        }
        store.execute(query)
    }

    func readLatestHeartRate(completion: @escaping (Double) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else { return }
            let hrUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let value = sample.quantity.doubleValue(for: hrUnit)
            DispatchQueue.main.async {
                self.latestHeartRate = value
                completion(value)
            }
        }
        store.execute(query)
    }

    func fetchSleepEstimate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.lastNightSleepHours = 6.8
        }
    }

    func fetchWeeklySteps() {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        var dailySteps: [Int] = Array(repeating: 0, count: 7)
        let group = DispatchGroup()

        for dayOffset in 0..<7 {
            group.enter()
            let startDate = calendar.date(byAdding: .day, value: -dayOffset, to: calendar.startOfDay(for: now))!
            let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let sum = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                dailySteps[6 - dayOffset] = Int(sum)
                group.leave()
            }
            store.execute(query)
        }

        group.notify(queue: .main) {
            self.weeklySteps = dailySteps
        }
    }
}