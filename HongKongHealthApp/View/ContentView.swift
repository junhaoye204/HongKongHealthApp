import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = true

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            FoodTrackingScreen()
                .tabItem { Label("Food Log", systemImage: "fork.knife") }
            ExerciseScreen()
                .tabItem { Label("Exercise", systemImage: "figure.walk") }
            HikingScreen()
                .tabItem { Label("Hiking", systemImage: "mountain.2.fill") }
            ProfileScreen()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .accentColor(.green)
    }
}
