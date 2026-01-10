import Foundation
import FirebaseAuth

class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String? = nil

    private var authListener: AuthStateDidChangeListenerHandle?

    private init() {
        authListener = Auth.auth().addStateDidChangeListener { auth, user in
            self.isLoggedIn = user != nil
            if let user = user {
                if let displayName = user.displayName {
                    UserProfile.shared.name = displayName
                } else {
                    let newName = user.email?.components(separatedBy: "@").first ?? "用戶"
                    UserProfile.shared.name = newName
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = newName
                    changeRequest.commitChanges { _ in }
                }
            }
        }
    }

    func signup(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error { self.errorMessage = error.localizedDescription; return }
            if let user = result?.user {
                let newName = email.components(separatedBy: "@").first ?? "用戶"
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = newName
                changeRequest.commitChanges { commitError in
                    if let commitError = commitError {
                        self.errorMessage = commitError.localizedDescription
                    } else {
                        self.isLoggedIn = true
                        self.errorMessage = nil
                    }
                }
            }
        }
    }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error { self.errorMessage = error.localizedDescription; return }
            self.isLoggedIn = true
            self.errorMessage = nil
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    deinit {
        if let listener = authListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}
