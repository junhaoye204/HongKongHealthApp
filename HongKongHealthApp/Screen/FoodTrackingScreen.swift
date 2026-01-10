//
//  FoodTrackingScreen.swift
//  HongKongHealthApp
//
//  Created by Ye on 16/1/2026.
//


import SwiftUI

struct FoodTrackingScreen: View {
    @EnvironmentObject var localStore: LocalStore
    @State private var showCamera = false
    @State private var userInput: String = ""
    @State private var chatHistory: [String] = []
    @State private var isThinking = false

    let conciergeAPI = DailyConciergeAPI()

    var body: some View {
        NavigationStack {
            List {
                quickRecordSection
                todayMealsSection
                modernAIChatSection
            }
            .navigationTitle("飲食記錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") { hideKeyboard() }.font(.headline)
                }
            }
            .sheet(isPresented: $showCamera) {
                FoodCameraView { newMeal in
                    localStore.addMeal(newMeal)
                    showCamera = false
                }
            }
            .hideKeyboardOnTap()
            .ignoresSafeArea(.keyboard)
            .gesture(DragGesture().onChanged { _ in hideKeyboard() })
            .onAppear {
                if !localStore.latestFoodDescription.isEmpty {
                    let query = "告訴我更多關於 \(localStore.latestFoodDescription) 的詳情，包括營養成分、健康建議和替代選擇。"
                    userInput = query
                    sendChat()
                    localStore.latestFoodDescription = ""
                }
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private var quickRecordSection: some View {
        Section(header: Text("快速記錄")) {
            Button(action: { showCamera = true }) {
                HStack {
                    Image(systemName: "camera.fill").font(.system(size: 24))
                    Text("影相記錄 (示範)").font(.headline)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var todayMealsSection: some View {
        Section(header: Text("今日飲食")) {
            ForEach(localStore.meals) { meal in
                NavigationLink {
                    MealDetailView(meal: meal)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(meal.name).bold()
                            Text("\(meal.calories) kcal • \(meal.saltLevel.capitalized)").font(.caption)
                        }
                        Spacer()
                        Text(meal.date, style: .time).font(.caption)
                    }
                }
            }
        }
    }

    private var modernAIChatSection: some View {
        Section {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(chatHistory.indices, id: \.self) { index in
                                let message = chatHistory[index]
                                let isUser = message.hasPrefix("You:")
                                HStack(alignment: .top, spacing: 12) {
                                    if !isUser {
                                        Image(systemName: "brain.head.profile")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .frame(width: 38, height: 38)
                                            .background(Circle().fill(Color.purple.gradient))
                                    }
                                    VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                                        Text(message)
                                            .padding(.horizontal, 16).padding(.vertical, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                    .fill(isUser ? Color.green.opacity(0.18) : Color.gray.opacity(0.15))
                                            )
                                            .foregroundColor(isUser ? .green : .primary)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                    .stroke(isUser ? Color.green.opacity(0.4) : Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                    if isUser {
                                        Image(systemName: "person.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .frame(width: 38, height: 38)
                                            .background(Circle().fill(Color.blue.gradient))
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
                                .padding(.horizontal, 12)
                                .id(index)
                            }
                            if isThinking {
                                HStack(spacing: 10) {
                                    ProgressView().scaleEffect(0.8)
                                    Text("AI 正在思考...").font(.subheadline).foregroundColor(.secondary).italic()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20).padding(.vertical, 8)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                    .onChange(of: chatHistory.count) { _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(chatHistory.count - 1, anchor: .bottom)
                        }
                    }
                }
                .frame(maxHeight: 420)

                HStack(spacing: 12) {
                    TextField("問我關於飲食、營養、健康建議...", text: $userInput, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 24).fill(Color(UIColor.secondarySystemBackground)))
                        .lineLimit(1...5)
                        .submitLabel(.send)
                        .onSubmit { sendChat() }

                    Button(action: { sendChat() }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .green)
                            .padding(8)
                            .contentShape(Circle())
                    }
                    .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .frame(minWidth: 60, minHeight: 60)
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }

    private func sendChat() {
        let trimmed = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let message = trimmed
        chatHistory.append("You: \(message)")
        userInput = ""
        isThinking = true
        conciergeAPI.chat(with: message) { result in
            DispatchQueue.main.async {
                isThinking = false
                switch result {
                case .success(let chatResponse):
                    let reply = chatResponse.choices?.first?.message?.content ?? "未能收到回覆"
                    chatHistory.append("Assistant: \(reply)")
                case .failure(let error):
                    chatHistory.append("錯誤: \(error.localizedDescription)")
                }
            }
        }
    }
}