//
//  WaterReminderManager.swift
//  HongKongHealthApp
//
//  Created by Ye on 16/1/2026.
//


import Foundation
import UserNotifications

class WaterReminderManager {
    static let shared = WaterReminderManager()

    private init() {
        requestPermission()
    }

    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            if granted {
                let drinkAction = UNNotificationAction(identifier: "DRINK_WATER_ACTION", title: "飲咗", options: [])
                let category = UNNotificationCategory(identifier: "WATER_REMINDER_CATEGORY", actions: [drinkAction], intentIdentifiers: [], options: [])
                UNUserNotificationCenter.current().setNotificationCategories([category])
            }
        }
    }

    func scheduleHourlyReminders() {
        cancelAll()
        for offset in 1...16 {
            let content = UNMutableNotificationContent()
            content.title = "飲水時間到啦！💧"
            content.body = "已經一個鐘未飲水喇～快啲飲杯水補充水分！"
            content.sound = .default
            content.categoryIdentifier = "WATER_REMINDER_CATEGORY"

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600 * Double(offset), repeats: false)
            let request = UNNotificationRequest(identifier: "water-reminder-\(offset)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
        print("Scheduled 16 water reminders")
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}