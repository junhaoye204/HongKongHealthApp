import SwiftUI
import AVKit

struct WorkoutPlayerView: View {
    @StateObject private var viewModel = PlayerViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("運動播放器").font(.title2).bold()
            VideoPlayer(player: viewModel.player)
                .frame(height: 300)
                .cornerRadius(10)
            Spacer()
        }
        .padding()
        .onDisappear { viewModel.player.pause() }
    }
}