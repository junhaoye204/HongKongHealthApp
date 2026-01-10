import SwiftUI
import AVKit

struct ExerciseScreen: View {
    @State private var isOTToday = false
    @State private var isTired = false
    @State private var selectedDuration = 10
    @State private var showWorkoutPlayer = false

    @State private var bmiHeight: String = ""
    @State private var bmiWeight: String = ""

    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var age: String = ""
    @State private var generatedPlan: String = ""
    @State private var isGenerating = false
    @State private var showGeneratedPlan = false

    let durations = [5, 10, 15, 20, 30]
    let conciergeAPI = DailyConciergeAPI()

    var bmi: Double? {
        guard let h = Double(bmiHeight), let w = Double(bmiWeight), h > 0 else { return nil }
        let heightInMeters = h / 100
        return w / (heightInMeters * heightInMeters)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    togglesSection
                    durationPicker
                    recommendationsSection
                    bmiCalculatorSection
                    personalizedExerciseSection
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle("運動計劃")
            .sheet(isPresented: $showWorkoutPlayer) { WorkoutPlayerView() }
            .sheet(isPresented: $showGeneratedPlan) { GuidedExerciseView(plan: generatedPlan) }
        }
    }

    private var togglesSection: some View {
        VStack(spacing: 15) {
            Toggle(isOn: $isOTToday) {
                HStack { Image(systemName: "clock.badge.exclamationmark").foregroundColor(.orange); Text("今日OT").font(.headline) }
            }.tint(.orange)
            Toggle(isOn: $isTired) {
                HStack { Image(systemName: "bed.double.fill").foregroundColor(.blue); Text("今日好攰").font(.headline) }
            }.tint(.blue)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.08)))
    }

    private var durationPicker: some View {
        Picker("Duration", selection: $selectedDuration) {
            ForEach(durations, id: \.self) { d in Text("\(d) 分鐘").tag(d) }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isOTToday || isTired ? "輕鬆運動建議" : "今日推薦運動").font(.headline)
            ForEach(getRecommendedWorkouts(), id: \.id) { w in
                WorkoutCard(workout: w) { showWorkoutPlayer = true }
            }
        }
        .padding()
    }

    private var bmiCalculatorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("BMI 計算器").font(.headline).foregroundColor(.primary)

            HStack { Image(systemName: "ruler").foregroundColor(.gray)
                TextField("身高 (cm)", text: $bmiHeight).keyboardType(.decimalPad).textFieldStyle(.plain) }
                .padding().background(Color.gray.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 12))

            HStack { Image(systemName: "scalemass").foregroundColor(.gray)
                TextField("體重 (kg)", text: $bmiWeight).keyboardType(.decimalPad).textFieldStyle(.plain) }
                .padding().background(Color.gray.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 12))

            if let bmiValue = bmi {
                HStack {
                    Image(systemName: bmiIcon(for: bmiValue))
                        .font(.title2).foregroundColor(bmiColor(for: bmiValue))
                    VStack(alignment: .leading) {
                        Text("你的 BMI: \(String(format: "%.1f", bmiValue))").font(.headline).foregroundColor(.blue)
                        Text(bmiCategory(for: bmiValue)).font(.subheadline).foregroundColor(bmiColor(for: bmiValue))
                    }
                }
                .padding().frame(maxWidth: .infinity)
                .background(bmiColor(for: bmiValue).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(bmiColor(for: bmiValue).opacity(0.3), lineWidth: 1))
            }

            if !bmiHeight.isEmpty || !bmiWeight.isEmpty {
                Button("清除輸入") { bmiHeight = ""; bmiWeight = "" }
                    .font(.subheadline).foregroundColor(.red).padding(.top, 4)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.08)))
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    private var personalizedExerciseSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("個人化運動計劃").font(.headline).foregroundColor(.primary)

            HStack { Image(systemName: "ruler").foregroundColor(.gray)
                TextField("身高 (cm)", text: $height).keyboardType(.decimalPad).textFieldStyle(.plain) }
                .padding().background(Color.gray.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 12))

            HStack { Image(systemName: "scalemass").foregroundColor(.gray)
                TextField("體重 (kg)", text: $weight).keyboardType(.decimalPad).textFieldStyle(.plain) }
                .padding().background(Color.gray.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 12))

            HStack { Image(systemName: "person").foregroundColor(.gray)
                TextField("年齡", text: $age).keyboardType(.numberPad).textFieldStyle(.plain) }
                .padding().background(Color.gray.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 12))

            Button("生成計劃") { generatePersonalizedPlan() }
                .disabled(height.isEmpty || weight.isEmpty || age.isEmpty || isGenerating)
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)

            if isGenerating {
                HStack {
                    ProgressView().progressViewStyle(.circular).tint(.green)
                    Text("AI 生成中...").font(.subheadline).foregroundColor(.secondary)
                }.padding(.top, 8)
            }

            if !height.isEmpty || !weight.isEmpty || !age.isEmpty {
                Button("清除輸入") { height = ""; weight = ""; age = "" }
                    .font(.subheadline).foregroundColor(.red).padding(.top, 4)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.08)))
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    private func bmiCategory(for bmi: Double) -> String {
        if bmi < 18.5 { return "過輕 - 建議增加營養攝取" }
        else if bmi < 25 { return "正常 - 繼續保持健康生活" }
        else if bmi < 30 { return "過重 - 注意飲食與運動" }
        else { return "肥胖 - 建議諮詢醫生" }
    }
    private func bmiColor(for bmi: Double) -> Color {
        if bmi < 18.5 { return .yellow }
        else if bmi < 25 { return .green }
        else if bmi < 30 { return .orange }
        else { return .red }
    }
    private func bmiIcon(for bmi: Double) -> String {
        if bmi < 18.5 { return "exclamationmark.triangle" }
        else if bmi < 25 { return "checkmark.circle" }
        else if bmi < 30 { return "exclamationmark.triangle" }
        else { return "exclamationmark.triangle.fill" }
    }

    private func generatePersonalizedPlan() {
        isGenerating = true
        let prompt = "為一位身高 \(height) cm、體重 \(weight) kg、年齡為 \(age) 的用戶創建一個適合的運動計劃。計劃應包括日常運動建議、持續時間和強度，適合香港健康App。"
        conciergeAPI.chat(with: prompt) { result in
            DispatchQueue.main.async {
                isGenerating = false
                switch result {
                case .success(let chatResponse):
                    generatedPlan = chatResponse.choices?.first?.message?.content ?? "未能生成計劃"
                    showGeneratedPlan = true
                case .failure(let error):
                    generatedPlan = "錯誤: \(error.localizedDescription)"
                    showGeneratedPlan = true
                }
            }
        }
    }

    func getRecommendedWorkouts() -> [Workout] {
        if isOTToday || isTired {
            return [
                Workout(id: 1, name: "辦公室拉筋", duration: 5, intensity: "低", icon: "figure.stand"),
                Workout(id: 2, name: "頸肩放鬆", duration: 10, intensity: "低", icon: "figure.mind.and.body"),
                Workout(id: 3, name: "呼吸冥想", duration: 5, intensity: "低", icon: "wind")
            ]
        } else {
            return [
                Workout(id: 4, name: "HIIT燃脂", duration: 15, intensity: "高", icon: "flame.fill"),
                Workout(id: 5, name: "核心訓練", duration: 10, intensity: "中", icon: "figure.core.training"),
                Workout(id: 6, name: "全身伸展", duration: 10, intensity: "低", icon: "figure.flexibility")
            ]
        }
    }
}

struct WorkoutCard: View {
    let workout: Workout
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: workout.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading) {
                    Text(workout.name).bold()
                    Text("\(workout.duration) 分鐘 • \(workout.intensity)").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.secondary)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }
}