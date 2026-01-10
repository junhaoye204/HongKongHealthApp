import SwiftUI

struct AuthWrapperView: View {
    @StateObject var authManager = AuthManager.shared

    var body: some View {
        Group {
            if authManager.isLoggedIn {
                SplashView()
            } else {
                NavigationStack { LoginView() }
            }
        }
        .environmentObject(authManager)
        .environmentObject(UserProfile.shared)
    }
}