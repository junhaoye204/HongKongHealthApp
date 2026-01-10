import SwiftUI
import UIKit

struct MealDetailView: View {
    let meal: MealEntry

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                imageSection
                detailsSection
            }
        }
        .navigationTitle("餐單詳情")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var imageSection: some View {
        Group {
            if let data = meal.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 100))
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(meal.name).font(.title.bold())
            Text("\(meal.calories) kcal").font(.title2).foregroundColor(.orange)
            Text(meal.saltLevel.capitalized)
                .font(.headline)
                .foregroundColor(meal.saltLevel == "high" ? .red : .green)
            Text(meal.date, style: .date).font(.subheadline).foregroundColor(.secondary)
            Text(meal.date, style: .time).font(.subheadline).foregroundColor(.secondary)
        }
        .padding()
    }
}