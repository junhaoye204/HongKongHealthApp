//
//  FoodCameraView.swift
//  HongKongHealthApp
//
//  Created by Ye on 16/1/2026.
//


import SwiftUI
import UIKit

struct FoodCameraView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localStore: LocalStore
    @State private var selectedImage: UIImage? = nil
    @State private var showPicker = false
    @State private var isAnalyzing = false
    @State private var suggestion: String = ""
    @State private var estimatedCalories: Int = 0
    @State private var saltWarning: String = ""
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var showSourceSelection = false
    @State private var showMoreDetails = false

    let onComplete: (MealEntry) -> Void

    var body: some View {
        NavigationStack {
            ZStack { imagePreview }
                .navigationTitle("飲食影相記錄")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") { dismiss() }
                    }
                }
                .fullScreenCover(isPresented: $showPicker) {
                    ImagePicker(selectedImage: $selectedImage, isShown: $showPicker, sourceType: sourceType)
                }
                .actionSheet(isPresented: $showSourceSelection) {
                    ActionSheet(title: Text("選擇來源"), message: nil, buttons: [
                        .default(Text("相機")) { sourceType = .camera; showPicker = true },
                        .default(Text("相簿")) { sourceType = .photoLibrary; showPicker = true },
                        .cancel(Text("取消"))
                    ])
                }
                .onChange(of: selectedImage) { newImage in
                    if newImage != nil { analyzeFood() }
                }
                .onChange(of: showMoreDetails) { if $0 { dismiss() } }
        }
    }

    private var imagePreview: some View {
        Group {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    if isAnalyzing {
                        ProgressView("AI 分析緊食物...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else if !suggestion.isEmpty {
                        suggestionCard
                    }
                    actionButtons.padding(.bottom, 40)
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    Text("準備好記錄你嘅餐單啦！")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    Button("選擇圖片") { showSourceSelection = true }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(.green)
                }
                .padding()
            }
        }
    }

    private var suggestionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI 分析結果").font(.headline)
            Text(suggestion).font(.body)
            HStack {
                Text("\(estimatedCalories) kcal").font(.title3.bold()).foregroundColor(.orange)
                Text(saltWarning)
                    .font(.subheadline)
                    .foregroundColor(saltWarning.contains("高") ? .red : .green)
            }
            Text("建議：\(estimatedCalories > 600 ? "份量多咗，考慮share或者留一半" : "份量適中，继续保持！")")
                .foregroundColor(.secondary)

            Button("向 AI 查詢更多詳情") {
                localStore.latestFoodDescription = suggestion
                showMoreDetails = true
            }
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    private var actionButtons: some View {
        HStack(spacing: 40) {
            Button("重新選擇") {
                selectedImage = nil
                suggestion = ""
                showSourceSelection = true
            }
            .buttonStyle(.bordered)

            Button("儲存記錄") {
                var meal = MealEntry(
                    name: suggestion.isEmpty ? "未知食物" : suggestion,
                    calories: estimatedCalories,
                    saltLevel: saltWarning.contains("高") ? "high" : "low"
                )
                if let image = selectedImage, let jpegData = image.jpegData(compressionQuality: 0.8) {
                    meal.imageData = jpegData
                }
                onComplete(meal)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }

    private func analyzeFood() {
        isAnalyzing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            isAnalyzing = false
            let foods = ["叉燒飯", "蒸魚", "青椒炒肉", "菠蘿油", "奶茶", "腸粉"]
            let randomFood = foods.randomElement() ?? "雜錦飯"
            suggestion = randomFood
            estimatedCalories = Int.random(in: 280...950)
            saltWarning = estimatedCalories > 650 || randomFood.contains("叉燒") || randomFood.contains("煎") ? "高鹽注意！" : "低鹽，健康選擇"
        }
    }
}