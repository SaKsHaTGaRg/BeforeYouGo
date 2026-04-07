import Foundation
import CoreLocation
import Combine
import UserNotifications

@MainActor
final class LocationManagerService: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastEventMessage: String = ""

    private let manager: CLLocationManager
    private var placeMap: [String: Place] = [:]

    private let historyStore: HistoryStore
    private let checklistViewModel: ChecklistViewModel
    private let notificationService: NotificationService

    init(
        historyStore: HistoryStore,
        checklistViewModel: ChecklistViewModel,
        notificationService: NotificationService
    ) {
        let locationManager = CLLocationManager()
        self.manager = locationManager
        self.authorizationStatus = locationManager.authorizationStatus
        self.historyStore = historyStore
        self.checklistViewModel = checklistViewModel
        self.notificationService = notificationService

        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // Safeguard: only enable background updates if the app has the capability configured
        if let backgroundModes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String],
           backgroundModes.contains("location") {
            locationManager.allowsBackgroundLocationUpdates = true
        }
    }

    // MARK: - Permissions

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func requestAlwaysPermissionIfNeeded() {
        if authorizationStatus == .authorizedWhenInUse {
            manager.requestAlwaysAuthorization()
        }
    }

    // MARK: - Monitoring

    func syncMonitoring(with places: [Place]) {
        restartMonitoring(for: places)
    }

    func startMonitoring(for place: Place) {
        guard authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse else {
            lastEventMessage = "Permission not granted"
            return
        }

        guard let region = circularRegion(for: place) else {
            lastEventMessage = "Missing coordinates for \(place.name)"
            return
        }

        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            lastEventMessage = "Monitoring not available"
            return
        }

        placeMap[region.identifier] = place
        manager.startMonitoring(for: region)

        requestAlwaysPermissionIfNeeded()

        lastEventMessage = "Started monitoring \(place.name)"
    }

    func stopMonitoring(for place: Place) {
        guard let region = monitoredRegion(for: place.id.uuidString) else { return }

        manager.stopMonitoring(for: region)
        placeMap.removeValue(forKey: region.identifier)

        lastEventMessage = "Stopped monitoring \(place.name)"
    }

    func restartMonitoring(for places: [Place]) {
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }

        placeMap.removeAll()

        for place in places where place.isEnabled {
            startMonitoring(for: place)
        }
    }

    // MARK: - Helpers

    func circularRegion(for place: Place) -> CLCircularRegion? {
        guard let lat = place.latitude,
              let lon = place.longitude else { return nil }

        let region = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            radius: max(50, min(place.radiusMeters, 1000)),
            identifier: place.id.uuidString
        )
        region.notifyOnEntry = false
        region.notifyOnExit = true
        return region
    }

    func isMonitoring(_ place: Place) -> Bool {
        manager.monitoredRegions.contains { $0.identifier == place.id.uuidString }
    }

    private func monitoredRegion(for identifier: String) -> CLRegion? {
        manager.monitoredRegions.first { $0.identifier == identifier }
    }

    private func sendExitReminder(for place: Place) {
        let items = checklistViewModel.enabledItems(for: place.id)
        let titles = items.map { $0.title }

        let body = titles.isEmpty
            ? "You left \(place.name)"
            : "You left \(place.name). Don’t forget: \(titles.joined(separator: ", "))"

        notificationService.sendNotification(
            title: "Reminder",
            body: body
        )

        historyStore.add(
            placeName: place.name,
            checklistName: "\(place.name) Checklist",
            checklistItems: titles,
            exitTime: Date()
        )
    }
}

extension LocationManagerService: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedAlways:
            lastEventMessage = "Always permission granted"
        case .authorizedWhenInUse:
            lastEventMessage = "While Using App permission"
        case .denied:
            lastEventMessage = "Permission denied"
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let place = placeMap[region.identifier] else {
            lastEventMessage = "Unknown region triggered"
            return
        }

        lastEventMessage = "Exited \(place.name)"
        sendExitReminder(for: place)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastEventMessage = "Error: \(error.localizedDescription)"
    }

    func locationManager(_ manager: CLLocationManager,
                         monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        lastEventMessage = "Monitoring failed: \(error.localizedDescription)"
    }
}
