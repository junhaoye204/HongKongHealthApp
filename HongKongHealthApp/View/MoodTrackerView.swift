//
//  MoodTrackerView.swift
//  HongKongHealthApp
//
//  Created by Ye on 16/1/2026.
//


import SwiftUI

struct MoodTrackerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localStore: LocalStore
    @State private var mood: Int = 3
    @State private var stress: Int = 3
    @State private var note: String = ""
    @ObservedObject var musicManager = RelaxMusicManager.shared
    @State private var showSaveConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Image(systemName: "heart.text.square.fill")
                            .font(.title)
                            .foregroundColor(.pink)
                        Text("記錄心情與壓力").font(.title2.bold())
                    }.padding(.top)

                    moodSection
                    stressSection
                    noteSection
                    musicSection
                    Spacer()
                }
                .padding()
            }
            .background(LinearGradient(colors: [Color.pink.opacity(0.1), Color.blue.opacity(0.05)], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
            .navigationTitle("心情與壓力記錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        let entry = MoodEntry(mood: mood, stress: stress, note: note)
                        localStore.addMood(entry)
                        showSaveConfirmation = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.green.gradient)
                    .clipShape(Capsule())
                    .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                    .overlay(
                        Group { if showSaveConfirmation { Text("已儲存！").font(.subheadline).foregroundColor(.white).transition(.opacity) } }
                    )
                    .animation(.easeInOut, value: showSaveConfirmation)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .onAppear {
                if stress > 3 {
                    musicManager.currentTrack = "relax"
                    musicManager.play()
                }
            }
        }
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日心情").font(.headline).foregroundColor(.primary)
            HStack(spacing: 16) {
                ForEach(1...5, id: \.self) { i in
                    Text(moodEmoji(i))
                        .font(.system(size: 40))
                        .frame(width: 60, height: 60)
                        .background(mood == i ? Color.pink.opacity(0.3) : Color.gray.opacity(0.1))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(mood == i ? Color.pink : Color.clear, lineWidth: 2))
                        .scaleEffect(mood == i ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3), value: mood)
                        .onTapGesture { mood = i }
                }
            }
            .frame(maxWidth: .infinity)

            Text(moodTip).font(.subheadline).multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(moodColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(moodColor.opacity(0.3), lineWidth: 1))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    private var stressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("壓力水平").font(.headline).foregroundColor(.primary)
            Slider(value: Binding(get: { Double(stress) }, set: { stress = Int($0) }), in: 1...5, step: 1)
                .tint(.orange)
            HStack {
                Text("低").font(.subheadline).foregroundColor(.green)
                Spacer()
                Text("中").font(.subheadline).foregroundColor(.yellow)
                Spacer()
                Text("高").font(.subheadline).foregroundColor(.red)
            }
            Text(stressTip).font(.subheadline).multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(stressColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(stressColor.opacity(0.3), lineWidth: 1))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("備註").font(.headline)
            TextField("例如：今日加班，好攰", text: $note, axis: .vertical)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .lineLimit(3...5)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    private var musicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("放鬆音樂").font(.headline)
            Picker("選擇音樂", selection: $musicManager.currentTrack) {
                ForEach(musicManager.trackKeys, id: \.self) { key in
                    Text(musicManager.getTrackName(for: key)).tag(key)
                }
            }
            .pickerStyle(.segmented)

            Toggle("播放音樂", isOn: $musicManager.isPlaying)
                .tint(.blue)
                .onChange(of: musicManager.isPlaying) { newValue in
                    if newValue { musicManager.play() } else { musicManager.stop() }
                }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    private var moodTip: String {
        switch mood {
        case 1: return "心情低落？試下深呼吸或散步放鬆。"
        case 2: return "感覺一般，找朋友傾訴下啦。"
        case 3: return "中性心情，保持平衡。"
        case 4: return "心情不錯，繼續加油！"
        default: return "超好心情，分享喜悅！"
        }
    }

    private var stressTip: String {
        switch stress {
        case 1: return "壓力低，繼續保持！"
        case 2: return "輕微壓力，試下聽音樂放鬆。"
        case 3: return "中等壓力，建議做運動。"
        case 4: return "壓力較高，試下冥想。"
        default: return "壓力很大，考慮休息或求助。"
        }
    }

    private var moodColor: Color {
        switch mood {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        default: return .blue
        }
    }

    private var stressColor: Color {
        switch stress {
        case 1: return .green
        case 2: return .yellow
        case 3: return .orange
        case 4: return .red
        default: return .purple
        }
    }

    private func moodEmoji(_ i: Int) -> String {
        switch i {
        case 1: return "😞"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        default: return "😄"
        }
    }
}