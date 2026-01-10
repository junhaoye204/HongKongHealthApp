import SwiftUI

struct TrailCard: View {
    let trail: Trail
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(trail.name).bold()
                Text("\(trail.difficulty) • \(trail.estimatedTime)")
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Text("\(trail.distance, specifier: "%.1f") 公里")
                .font(.caption).foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}