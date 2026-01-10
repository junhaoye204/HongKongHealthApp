import Foundation
import CoreLocation

final class HikeTracker: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private var lastLocation: CLLocation?

    @Published var totalDistance: Double = 0.0
    @Published var totalHikes: Int = 0
    @Published var startTime: Date? = nil

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        totalDistance = 0
        lastLocation = nil
        startTime = Date()
        locationManager.startUpdatingLocation()
        totalHikes += 1
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
        startTime = nil
    }

    var elapsedTime: TimeInterval {
        guard let start = startTime else { return 0 }
        return Date().timeIntervalSince(start)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        if let last = lastLocation {
            let delta = newLocation.distance(from: last) / 1000.0
            totalDistance += delta
        }
        lastLocation = newLocation
    }
}