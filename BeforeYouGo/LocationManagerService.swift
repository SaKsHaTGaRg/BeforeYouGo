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

    private let dataStore: AppDataStore
    private let historyStore: HistoryStore
    private let checklistViewModel: ChecklistViewModel
    private let notificationService: NotificationService

    init(
    dataStore: AppDataStore,
    historyStore: HistoryStore,
    checklistViewModel: ChecklistViewModel,
    notificationService: NotificationService
    ) {
        let locationManager = CLLocationManager()
        self.manager = locationManager
        self.authorizationStatus = locationManager.authorizationStatus
        self.dataStore = dataStore
        self.historyStore = historyStore
        self.checklistViewModel = checklistViewModel
        self.notificationService = notificationService

        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
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

    @discardableResult
    func startMonitoring(for place: Place) -> Bool {
        switch authorizationStatus {
        case .notDetermined:
            requestPermission()
            lastEventMessage = "Allow location permission first, then enable the place again."
            return false

        case .restricted, .denied:
            lastEventMessage = "Permission not granted"
            return false

        case .authorizedWhenInUse:
            requestAlwaysPermissionIfNeeded()
            lastEventMessage = "Please allow Always Location to enable geofence monitoring."
            return false

        case .authorizedAlways:
            break

        @unknown default:
            lastEventMessage = "Unknown permission state"
            return false
        }

        guard let region = circularRegion(for: place) else {
            lastEventMessage = "Missing coordinates for \(place.name)"
            return false
        }

        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            lastEventMessage = "Monitoring not available"
            return false
        }

        placeMap[region.identifier] = place
        manager.startMonitoring(for: region)
        lastEventMessage = "Started monitoring \(place.name)"
        return true
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
            _ = startMonitoring(for: place)
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

    private func persistedPlace(for regionIdentifier: String) -> Place? {
        dataStore.fetchPlaces().first { $0.id.uuidString == regionIdentifier }
    }

    private func sendExitReminder(for place: Place) {
        let items = checklistViewModel.enabledItems(for: place.id)
        let titles = items.map { $0.title }

        if let reminder = ReminderBuilder.build(for: place, items: items) {
            notificationService.sendNotification(
                title: reminder.title,
                body: reminder.body
            )
        }

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
            lastEventMessage = "While Using App permission granted. Enable Always Location for geofence monitoring."
        case .denied:
            lastEventMessage = "Permission denied"
        case .restricted:
            lastEventMessage = "Location access restricted"
        case .notDetermined:
            lastEventMessage = "Location permission not decided yet"
        @unknown default:
            lastEventMessage = "Unknown permission state"
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let place = placeMap[region.identifier] {
            lastEventMessage = "Exited \(place.name)"
            sendExitReminder(for: place)
            return
        }

        if let recoveredPlace = persistedPlace(for: region.identifier) {
            placeMap[region.identifier] = recoveredPlace
            lastEventMessage = "Exited \(recoveredPlace.name)"
            sendExitReminder(for: recoveredPlace)
            return
        }

        lastEventMessage = "Unknown region triggered"
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastEventMessage = "Error: \(error.localizedDescription)"
    }

    func locationManager(_ manager: CLLocationManager,
    monitoringDidFailFor region: CLRegion?,
    withError error: Error) {
        if let region {
            placeMap.removeValue(forKey: region.identifier)
        }
        lastEventMessage = "Monitoring failed: \(error.localizedDescription)"
    }
}
