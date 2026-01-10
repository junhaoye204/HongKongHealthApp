import FirebaseAuth

final class UserProfile: ObservableObject {
    static let shared = UserProfile()
    
    @Published var name: String
    @Published var calorieTarget: Int = 1800
    @Published var achievementLevel: Int = 4
    @Published var totalWorkoutDays: Int = 42
    @Published var totalCaloriesBurned: Int = 12000
    @Published var totalHikes: Int = 18
    @Published var streakDays: Int = 5
    @Published var profileIcon: String
    
    private init() {
        name = ""
        profileIcon = UserDefaults.standard.string(forKey: "profileIcon") ?? "person.circle.fill"
    }
    
    func updateName(newName: String) {
        self.name = newName
        guard let user = Auth.auth().currentUser else { return }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newName
        changeRequest.commitChanges { error in
            if let error = error {
                print("Update name error: \(error.localizedDescription)")
                // Optionally revert or show alert
            }
        }
    }
    
    func updateProfileIcon(newIcon: String) {
        self.profileIcon = newIcon
        UserDefaults.standard.set(newIcon, forKey: "profileIcon")
    }
}