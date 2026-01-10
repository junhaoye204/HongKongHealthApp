import SwiftUI
import AVFoundation

struct GuidedExerciseView: View {
    let plan: String
    @State private var isActive = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var currentStepIndex = 0
    @State private var exerciseSteps: [String] = []

    var body: some View {
        VStack(spacing: 20) {
            Text("AI 引導運動").font(.title2.bold())
            if !isActive {
                Text(plan)
                    .padding()
                    .multilineTextAlignment(.leading)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("開始運動") { startExercise() }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
            } else {
                Text("已用時間: \(formatElapsed(elapsedTime))")
                    .font(.title3).foregroundColor(.blue)

                Text("目前步驟: \(exerciseSteps[currentStepIndex])")
                    .font(.body).multilineTextAlignment(.center).padding()

                Button("停止運動") { stopExercise() }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
            }
            Spacer()
        }
        .padding()
        .onAppear { parsePlanIntoSteps() }
        .onDisappear { stopExercise() }
    }

    private func parsePlanIntoSteps() {
        exerciseSteps = plan.components(separatedBy: ". ").filter { !$0.isEmpty }
        if exerciseSteps.isEmpty { exerciseSteps = ["開始運動！", "繼續堅持！", "完成！"] }
    }

    private func startExercise() {
        isActive = true
        elapsedTime = 0
        currentStepIndex = 0
        let encouragement = "加油！你做得好！現在開始第一個運動："
        let firstStep = exerciseSteps[currentStepIndex]
        speak(encouragement + firstStep)

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
            if Int(elapsedTime) % 30 == 0 && currentStepIndex < exerciseSteps.count - 1 {
                currentStepIndex += 1
                speak(exerciseSteps[currentStepIndex])
            }
        }
    }

    private func stopExercise() {
        isActive = false
        timer?.invalidate()
        timer = nil
        speechSynthesizer.stopSpeaking(at: .immediate)
        speak("運動結束！做得好！")
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-HK")
        utterance.rate = 0.5
        speechSynthesizer.speak(utterance)
    }

    private func formatElapsed(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}