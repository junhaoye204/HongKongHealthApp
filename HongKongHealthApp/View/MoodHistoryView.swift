//
//  MoodHistoryView.swift
//  HongKongHealthApp
//
//  Created by Ye on 16/1/2026.
//


import SwiftUI

struct MoodHistoryView: View {
    @EnvironmentObject var localStore: LocalStore

    var body: some View {
        NavigationStack {
            List(localStore.moodEntries) { entry in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(entry.date, style: .date).font(.headline)
                        Spacer()
                        Text(entry.date, style: .time).font(.subheadline).foregroundColor(.secondary)
                    }
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("心情").font(.caption).foregroundColor(.secondary)
                            Text("\(entry.mood)/5").font(.title3.bold()).foregroundColor(moodColor(for: entry.mood))
                        }
                        VStack(alignment: .leading) {
                            Text("壓力").font(.caption).foregroundColor(.secondary)
                            Text("\(entry.stress)/5").font(.title3.bold()).foregroundColor(stressColor(for: entry.stress))
                        }
                    }
                    if !entry.note.isEmpty {
                        Text("備註: \(entry.note)").font(.body).foregroundColor(.primary).padding(.top, 4)
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("心情與壓力歷史")
        }
    }

    private func moodColor(for mood: Int) -> Color {
        switch mood {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        default: return .blue
        }
    }
    private func stressColor(for stress: Int) -> Color {
        switch stress {
        case 1: return .green
        case 2: return .yellow
        case 3: return .orange
        case 4: return .red
        default: return .purple
        }
    }
}