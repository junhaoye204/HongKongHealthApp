//
//  AnimatedHeaderView.swift
//  HongKongHealthApp
//
//  Created by Ye on 16/1/2026.
//


import SwiftUI
import AVKit

struct AnimatedHeaderView: View {
    let name: String
    var namespace: Namespace.ID
    @Binding var animate: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("你好，\(name)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .matchedGeometryEffect(id: "greeting", in: namespace)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.green.opacity(0.18), Color.green.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 72, height: 72)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                Image(systemName: "leaf.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.green)
                    .scaleEffect(animate ? 1.0 : 0.85)
                    .rotationEffect(.degrees(animate ? 0 : -8))
                    .animation(.easeOut(duration: 0.6), value: animate)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
    }

    var subtitle: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "早晨，準備好迎接新一日"
        case 12..<18: return "下晝好，記得補充水分"
        default: return "晚上好，放鬆一下"
        }
    }
}

struct SummaryRing: View {
    let title: String
    let value: Double
    let target: Double
    let color: Color
    var unit: String = ""

    var progress: Double { min(max(value / max(target, 1), 0), 1) }

    var body: some View {
        VStack {
            ringView
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
    }

    private var ringView: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.18), lineWidth: 8)
                .frame(width: 72, height: 72)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(AngularGradient(gradient: Gradient(colors: [color, color.opacity(0.6)]), center: .center), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 72, height: 72)
                .animation(.easeInOut(duration: 0.8), value: progress)
            VStack {
                Text("\(Int(value))").font(.headline).fontWeight(.semibold)
                if !unit.isEmpty { Text(unit).font(.caption).foregroundColor(.secondary) }
            }
        }
    }
}

struct MiniDashboardView: View {
    @ObservedObject var healthManager: HealthManager
    var body: some View {
        HStack(spacing: 12) {
            MetricCard(icon: "bed.double.fill", title: "睡眠", value: String(format: "%.1f h", healthManager.lastNightSleepHours), color: .indigo)
            MetricCard(icon: "heart.fill", title: "心率", value: "\(Int(healthManager.latestHeartRate)) bpm", color: .red)
            MetricCard(icon: "bolt.fill", title: "能量", value: "\(Int(healthManager.todayCalories)) kcal", color: .orange)
        }
    }
}

struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Spacer()
            }
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(value).font(.headline).fontWeight(.semibold)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}

struct QuickActionButton: View {
    let title: String
    let systemIcon: String
    let color: Color

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 10) {
                Image(systemName: systemIcon)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct FloatingActionButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(LinearGradient(colors: [Color.green, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 6)
        }
        .padding()
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
    }
}

class PlayerViewModel: ObservableObject {
    let player: AVPlayer

    init() {
        if let url = Bundle.main.url(forResource: "healthvideo", withExtension: "mp4") {
            player = AVPlayer(url: url)
        } else {
            player = AVPlayer()
        }
        player.play()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            self?.player.seek(to: .zero)
            self?.player.play()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
}