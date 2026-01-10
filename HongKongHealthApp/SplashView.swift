import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView()   // your main TabView
        } else {
            ZStack {
                LinearGradient(colors: [Color.green, Color.blue],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    Text("Hong Kong Health")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                    Text("Track steps, meals, exercise & hikes")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                }
            }
            .onAppear {
                // Auto-advance after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}