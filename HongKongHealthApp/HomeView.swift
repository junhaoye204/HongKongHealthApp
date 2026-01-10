import SwiftUI
import Charts

// MARK: - HomeView (improved with more useful functions)

struct HomeView: View {
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var localStore: LocalStore
    @Namespace private var ns
    
    @State private var showMoodTracker = false
    @State private var selectedMotivation = 0
    @State private var selectedTip = 0
    @State private var animateHeader = false
    @State private var showWeeklyChart = false  // Added for toggling chart view
    @State private var showShareSheet = false  // Added for sharing
    
    private let motivations = [
        "每一小步都係進步，加油！",
        "今日做得好好，繼續保持！",
        "健康係最大嘅財富，為自己努力！",
        "唔緊要慢，最緊要係堅持！",
        "你做得到嘅，相信自己！"
    ]
    
    private let tips = [
        "記得多飲水，保持水分充足！",
        "每日至少行 8000 步！",
        "均衡飲食，少鹽少糖！"
    ]
    
    @State private var motivationTimer: Timer?
    @State private var tipTimer: Timer?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    
                    summaryRings
                    
                    miniDashboard
                    
                    waterIntakeSection  // Added: Water tracking
                    
                    dailyTipSection  // Added: Daily health tip
                    
                    weeklyStepsChartSection  // Added: Weekly steps chart
                    
                    moodSection
                    
                    motivationalCarousel
                    
                    quickActions
                    
                    recentMeals
                    
                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .navigationTitle("香港健康")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.green)
                    }
                }
            }
            .sheet(isPresented: $showMoodTracker) {
                MoodTrackerView()
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: [generateShareText()])
            }
            .onAppear {
                withAnimation(.spring(response: 0.9, dampingFraction: 0.8)) {
                    animateHeader = true
                }
                localStore.resetDailyData()  // Optional: Reset daily data if needed
                startMotivationTimer()
                startTipTimer()
            }
            .onDisappear {
                motivationTimer?.invalidate()
                motivationTimer = nil
                tipTimer?.invalidate()
                tipTimer = nil
            }
        }
    }
    
    private func startMotivationTimer() {
        motivationTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                selectedMotivation = (selectedMotivation + 1) % motivations.count
            }
        }
    }
    
    private func startTipTimer() {
        tipTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                selectedTip = (selectedTip + 1) % tips.count
            }
        }
    }
    
    private var headerView: some View {
        AnimatedHeaderView(name: userProfile.name, namespace: ns, animate: $animateHeader)
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            .shadow(color: .gray.opacity(0.2), radius: 6, x: 0, y: 3)
            .padding(.horizontal)
    }
    
    private var summaryRings: some View {
        HStack(spacing: 16) {
            SummaryRing(title: "步數", value: Double(healthManager.todaySteps), target: 8000, color: .purple)
            SummaryRing(title: "運動", value: Double(healthManager.todayExerciseMinutes), target: 30, color: .blue, unit: "分")
            SummaryRing(title: "卡路里", value: Double(healthManager.todayCalories), target: Double(userProfile.calorieTarget), color: .orange, unit: "kcal")
        }
        .padding(.horizontal)
    }
    
    private var miniDashboard: some View {
        MiniDashboardView(healthManager: healthManager)
            .padding(.horizontal)
    }
    
    // Added: Water Intake Section
    private var waterIntakeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今日飲水進度")
                    .font(.headline)
                Spacer()
                Text("\(localStore.todayWaterGlasses)/8 杯")
                    .font(.title3.bold())
                    .foregroundColor(localStore.todayWaterGlasses >= 8 ? .green : .blue)
            }
            
            ProgressView(value: Double(localStore.todayWaterGlasses), total: 8)
                .tint(localStore.todayWaterGlasses >= 8 ? .green : .blue)
                .scaleEffect(y: 1.6)
            
            Text("目標：每日至少 8 杯水（約 2 公升）")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.blue.opacity(0.08)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .blue.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    // Added: Daily Tip Section with same size and similar style as motivational card
    private var dailyTipSection: some View {
        TabView(selection: $selectedTip) {
            ForEach(tips.indices, id: \.self) { idx in
                tipCardView(for: idx)
            }
        }
        .frame(height: 110)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
    
    private func tipCardView(for idx: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("每日健康提示")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(tips[idx])
                .font(.body.bold())
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(LinearGradient(colors: [Color.yellow.opacity(0.18), Color.yellow.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .yellow.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
        .tag(idx)
    }
    
    // Added: Weekly Steps Chart Section
    private var weeklyStepsChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("本週步數趨勢")
                    .font(.headline)
                Spacer()
                Button("詳情") {
                    showWeeklyChart.toggle()
                }
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color.purple.gradient)
                .clipShape(Capsule())
                .shadow(color: .purple.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(0..<7, id: \.self) { day in
                        BarMark(
                            x: .value("Day", ["一", "二", "三", "四", "五", "六", "日"][day]),
                            y: .value("Steps", healthManager.weeklySteps[day])
                        )
                        .foregroundStyle(.purple.gradient)
                    }
                }
                .frame(height: 150)
                .chartYScale(domain: 0 ... 10000)
            } else {
                Text("圖表需 iOS 16+")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.purple.opacity(0.05)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .purple.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
        .sheet(isPresented: $showWeeklyChart) {
            WeeklyChartDetailView(weeklySteps: healthManager.weeklySteps)
        }
    }
    
    private var moodSection: some View {
        HStack {
            Text("心情與壓力")
                .font(.headline)
            Spacer()
            Button(action: { showMoodTracker = true }) {
                Label("記錄心情", systemImage: "heart.text.square.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.pink.gradient)
                    .clipShape(Capsule())
                    .shadow(color: .pink.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal)
    }
    
    private var motivationalCarousel: some View {
        TabView(selection: $selectedMotivation) {
            ForEach(motivations.indices, id: \.self) { idx in
                cardView(for: idx)
            }
        }
        .frame(height: 110)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
    
    private func cardView(for idx: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("每日鼓勵")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(motivations[idx])
                .font(.body.bold())
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(LinearGradient(colors: [Color.yellow.opacity(0.18), Color.yellow.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .yellow.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
        .tag(idx)
    }
    
    private var quickActions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                QuickActionButton(title: "記錄飲食", systemIcon: "camera.fill", color: .orange)
                QuickActionButton(title: "開始運動", systemIcon: "play.circle.fill", color: .green)
                QuickActionButton(title: "行山打卡", systemIcon: "location.fill", color: .blue)
                QuickActionButton(title: "今日OT", systemIcon: "clock.badge.exclamationmark.fill", color: .red)
            }
            .padding(.horizontal)
        }
    }
    
    private var recentMeals: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近餐單")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(localStore.meals.prefix(3)) { meal in
                HStack {
                    VStack(alignment: .leading) {
                        Text(meal.name).bold()
                        Text("\(meal.calories) kcal • \(meal.saltLevel.capitalized)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(meal.date, style: .time).font(.caption)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                .padding(.horizontal)
            }
        }
    }
    
    // New function: Generate shareable text for the record
    private func generateShareText() -> String {
        let steps = healthManager.todaySteps
        let calories = healthManager.todayCalories
        let sleep = healthManager.lastNightSleepHours
        let heartRate = Int(healthManager.latestHeartRate)
        let water = localStore.todayWaterGlasses
        
        return """
        我的今日健康記錄：
        - 步數: \(steps) 步
        - 燃燒卡路里: \(calories) kcal
        - 睡眠: \(String(format: "%.1f", sleep)) 小時
        - 心率: \(heartRate) bpm
        - 飲水: \(water) 杯
        
        加入香港健康 App，一起保持健康！ 💪🌿
        """
    }
}