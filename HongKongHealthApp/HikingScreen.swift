import SwiftUI
import MapKit

struct HikingScreen: View {
    @EnvironmentObject var hikeTracker: HikeTracker
    @EnvironmentObject var localStore: LocalStore
    @State private var isTracking = false
    @State private var now = Date()

    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 22.3, longitude: 114.17),
        span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
    )

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let popularTrails = [
        Trail(name: "麥理浩徑第一段", difficulty: "中等", distance: 10.6, estimatedTime: "3-4小時",
              coordinate: CLLocationCoordinate2D(latitude: 22.3989, longitude: 114.321)),
        Trail(name: "衛奕信徑第二段", difficulty: "困難", distance: 13.5, estimatedTime: "5-6小時",
              coordinate: CLLocationCoordinate2D(latitude: 22.2572, longitude: 114.1925)),
        Trail(name: "龍脊", difficulty: "容易", distance: 8.5, estimatedTime: "2-3小時",
              coordinate: CLLocationCoordinate2D(latitude: 22.2270, longitude: 114.2397)),
        Trail(name: "獅子山", difficulty: "中等", distance: 5.5, estimatedTime: "2-3小時",
              coordinate: CLLocationCoordinate2D(latitude: 22.3426, longitude: 114.1931))
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    conqueredSection
                    mapSection
                    trackingSection
                    recentHikesSection
                    popularTrailsSection
                }
                .padding()
            }
            .navigationTitle("行山")
            .onReceive(timer) { input in now = input }
        }
    }

    private var conqueredSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "mountain.2.fill").font(.system(size: 50)).foregroundColor(.green)
            Text("已征服 \(localStore.hikes.count) 個山峰").font(.title2).bold()
            ProgressView(value: Double(localStore.hikes.count), total: 10).tint(.green)
            Text("總距離: \(localStore.hikes.map{$0.distance}.reduce(0,+), specifier: "%.1f") 公里")
                .font(.caption).foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.green.opacity(0.08)))
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("香港熱門行山地圖").font(.headline)
            Map(coordinateRegion: $mapRegion, showsUserLocation: true, annotationItems: popularTrails) { trail in
                MapAnnotation(coordinate: trail.coordinate) {
                    VStack {
                        VStack {
                            Image(systemName: "mountain.2.fill").foregroundStyle(.green).font(.title2)
                            Text(trail.name)
                                .font(.caption)
                                .padding(4)
                                .background(.white.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 4)
        }
    }

    private var trackingSection: some View {
        Group {
            if isTracking {
                VStack(spacing: 15) {
                    Text("行緊山...").font(.headline).foregroundColor(.green)
                    Text("距離: \(hikeTracker.totalDistance, specifier: "%.2f") 公里").font(.title3)
                    Text("時間: \(formatElapsed(hikeTracker.elapsedTime))").font(.title3).foregroundColor(.blue)
                    Button("停止追蹤") {
                        isTracking = false
                        hikeTracker.stopTracking()
                        let calories = Int(hikeTracker.totalDistance * 60)
                        let newHike = HikeEntry(distance: hikeTracker.totalDistance, calories: calories, duration: hikeTracker.elapsedTime)
                        localStore.addHike(newHike)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.green, lineWidth: 2))
            } else {
                Button(action: {
                    isTracking = true
                    hikeTracker.startTracking()
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("開始追蹤行山").fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(colors: [Color.green, Color.blue], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                }
                .onReceive(timer) { input in now = input }
            }
        }
    }

    private func formatElapsed(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var recentHikesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("最近行山紀錄").font(.headline)
            ForEach(localStore.hikes.prefix(3)) { hike in
                HStack {
                    Text(hike.date, style: .date)
                    Spacer()
                    Text("\(hike.distance, specifier: "%.1f") 公里 • \(hike.calories) kcal • \(formatElapsed(hike.duration))")
                        .font(.caption).foregroundColor(.secondary)
                }
            }
        }
    }

    private var popularTrailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("熱門路徑").font(.headline)
            ForEach(popularTrails) { trail in
                TrailCard(trail: trail)
            }
        }
    }
}