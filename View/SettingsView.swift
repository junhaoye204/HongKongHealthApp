//
//  SettingsView.swift
//  HongKongHealthApp
//
//  Created by Ye on 16/1/2026.
//


import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("dailyReminders") private var dailyReminders = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("顯示")) {
                    Toggle("深色模式", isOn: $darkModeEnabled)
                        .onChange(of: darkModeEnabled) { _ in }
                }
                Section(header: Text("通知")) {
                    Toggle("每日健康提醒", isOn: $dailyReminders)
                        .onChange(of: dailyReminders) { newValue in
                            if newValue { WaterReminderManager.shared.scheduleHourlyReminders() }
                            else { WaterReminderManager.shared.cancelAll() }
                        }
                }
                Section(header: Text("帳戶")) { Text("暫時示範設定") }
                Section(header: Text("隱私")) { Text("HealthKit 權限與資料使用說明") }
                Section { Button("關閉") { dismiss() } }
            }
            .navigationTitle("設定")
        }
    }
}
