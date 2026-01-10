import Foundation
import AVFoundation

class RelaxMusicManager: ObservableObject {
    static let shared = RelaxMusicManager()

    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    @Published var currentTrack: String = "Music"

    private let availableTracks = [
        "relax": "放鬆音樂 1",
        "relax2": "放鬆音樂 2",
        "lofi": "放鬆音樂 3"
    ]

    private init() { setupAudioSession() }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }

    func play(track: String? = nil) {
        if let newTrack = track, newTrack != currentTrack { currentTrack = newTrack }
        guard let url = Bundle.main.url(forResource: currentTrack, withExtension: "mp3") else {
            print("Music file not found: \(currentTrack)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Couldn't play music: \(error)")
        }
    }

    func stop() {
        audioPlayer?.stop()
        isPlaying = false
    }

    func getTrackName(for key: String) -> String { availableTracks[key] ?? "未知" }
    var trackKeys: [String] { Array(availableTracks.keys) }
}