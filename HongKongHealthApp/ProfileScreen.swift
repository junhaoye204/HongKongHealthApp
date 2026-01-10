import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var localStore: LocalStore
    @EnvironmentObject var authManager: AuthManager
    @State private var showSettings = false
    @State private var showLogoutConfirm = false
    @State private var isEditingName = false
    @State private var showIconPicker = false

    private let availableIcons = [
        "person.circle.fill","leaf.circle.fill","heart.circle.fill",
        "star.circle.fill","flame.circle.fill","mountain.2.circle.fill"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    statsGrid
                    achievementsSection
                    moodHistoryButton
                    settingsButton

                    Button("登出") { showLogoutConfirm = true }
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("我的")
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selectedIcon: $userProfile.profileIcon, availableIcons: availableIcons, onSelect: { newIcon in
                    userProfile.updateProfileIcon(newIcon: newIcon)
                })
            }
            .alert("確認登出？", isPresented: $showLogoutConfirm) {
                Button("確認", role: .destructive) { authManager.logout() }
                Button("取消", role: .cancel) {}
            } message: { Text("你確定要登出嗎？") }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Button { showIconPicker = true } label: {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color.green.opacity(0.2), Color.green.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    Image(systemName: userProfile.profileIcon)
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                }
            }

            if isEditingName {
                TextField("顯示名稱", text: $userProfile.name, onCommit: {
                    userProfile.updateName(newName: userProfile.name)
                    isEditingName = false
                })
                .multilineTextAlignment(.center)
                .font(.title2.bold())
                .padding(.horizontal)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Text(userProfile.name)
                    .font(.title2.bold())
                    .onTapGesture { isEditingName = true }
            }

            Text("等級 \(userProfile.achievementLevel)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .shadow(color: .gray.opacity(0.2), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(title: "總運動日", value: "\(userProfile.totalWorkoutDays)", icon: "calendar")
            StatCard(title: "總卡路里", value: "\(userProfile.totalCaloriesBurned)", icon: "flame.fill")
            StatCard(title: "行山次數", value: "\(userProfile.totalHikes)", icon: "mountain.2.fill")
            StatCard(title: "連續天數", value: "\(userProfile.streakDays)", icon: "checkmark.circle.fill")
        }
        .padding(.horizontal)
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("成就").font(.headline).padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    AchievementBadge(achievement: Achievement(title: "首次打卡", icon: "star.fill", isUnlocked: true))
                    AchievementBadge(achievement: Achievement(title: "連續7日", icon: "flame.fill", isUnlocked: true))
                    AchievementBadge(achievement: Achievement(title: "行山高手", icon: "mountain.2.fill", isUnlocked: false))
                    AchievementBadge(achievement: Achievement(title: "健康飲食", icon: "leaf.fill", isUnlocked: true))
                }
                .padding(.horizontal)
            }
        }
    }

    private var moodHistoryButton: some View {
        NavigationLink(destination: MoodHistoryView()) {
            HStack {
                Image(systemName: "chart.bar.fill").foregroundColor(.pink)
                Text("心情與壓力歷史").font(.headline)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.secondary)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.08)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }
        .padding(.horizontal)
    }

    private var settingsButton: some View {
        Button(action: { showSettings = true }) {
            HStack {
                Image(systemName: "gearshape.fill").foregroundColor(.gray)
                Text("設定").font(.headline)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.secondary)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.08)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }
        .padding(.horizontal)
    }
}

struct IconPickerView: View {
    @Binding var selectedIcon: String
    let availableIcons: [String]
    let onSelect: (String) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                    ForEach(availableIcons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                            onSelect(icon)
                            dismiss()
                        } label: {
                            Image(systemName: icon)
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                                .frame(width: 80, height: 80)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("選擇頭像")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon).foregroundColor(.white).padding(8).background(Color.green).clipShape(RoundedRectangle(cornerRadius: 8))
                Spacer()
            }
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(value).font(.headline).bold()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    var body: some View {
        VStack {
            Image(systemName: achievement.icon)
                .font(.title)
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
            Text(achievement.title).font(.caption)
        }
        .frame(width: 100)
    }
}