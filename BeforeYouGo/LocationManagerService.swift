import Foundation
import CoreLocation
import Combine
import UserNotifications

@MainActor
final class LocationManagerService: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastEventMessage: String = ""

    private let manager: CLLocationManager
    private var regionNameMap: [String: String] = [:]

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
        locationManager.allowsBackgroundLocationUpdates = false
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startMonitoring(for place: Place) {
        guard let region = circularRegion(for: place) else {
            lastEventMessage = "Could not monitor \(place.name). Missing coordinates."
            return
        }

        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            lastEventMessage = "Region monitoring is not available on this device."
            return
        }

        regionNameMap[region.identifier] = place.name
        manager.startMonitoring(for: region)
        lastEventMessage = "Started monitoring \(place.name)"
        objectWillChange.send()
    }

    func stopMonitoring(for place: Place) {
        guard let region = monitoredRegion(for: place.id.uuidString) else {
            lastEventMessage = "No monitored region found for \(place.name)"
            return
        }

        manager.stopMonitoring(for: region)
        regionNameMap.removeValue(forKey: region.identifier)
        lastEventMessage = "Stopped monitoring \(place.name)"
        objectWillChange.send()
    }

    func restartMonitoring(for places: [Place]) {
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }

        regionNameMap.removeAll()

        for place in places where place.isEnabled {
            startMonitoring(for: place)
        }

        objectWillChange.send()
    }

    func circularRegion(for place: Place) -> CLCircularRegion? {
        guard let latitude = place.latitude,
              let longitude = place.longitude else {
            return nil
        }

        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let radius = max(50, min(place.radiusMeters, 1000))

        let region = CLCircularRegion(
            center: center,
            radius: radius,
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
        manager.monitoredRegions.first(where: { $0.identifier == identifier })
    }

    private func regionDisplayName(for identifier: String) -> String {
        regionNameMap[identifier] ?? identifier
    }

    private func enabledChecklistItems() -> [ChecklistItem] {
        checklistViewModel.items.filter { $0.isEnabled }
    }

    private func sendExitReminder(for placeName: String) {
        let enabledItems = enabledChecklistItems()
        let checklistName = "\(placeName) Checklist"
        let checklistTitles = enabledItems.map { $0.title }

        let notificationBody: String
        if checklistTitles.isEmpty {
            notificationBody = "You left \(placeName). No enabled checklist items."
        } else {
            notificationBody = "You left \(placeName). Don’t forget: " + checklistTitles.joined(separator: ", ")
        }

        notificationService.sendNotification(
            title: "Checklist Reminder",
            body: notificationBody
        )

        historyStore.add(
            placeName: placeName,
            checklistName: checklistName,
            checklistItems: checklistTitles,
            exitTime: Date()
        )
    }
}

extension LocationManagerService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        objectWillChange.send()

        switch manager.authorizationStatus {
        case .authorizedAlways:
            lastEventMessage = "Location permission: Always"
        case .authorizedWhenInUse:
            lastEventMessage = "Location permission: While Using App"
        case .denied:
            lastEventMessage = "Location permission denied"
        case .restricted:
            lastEventMessage = "Location permission restricted"
        case .notDetermined:
            lastEventMessage = "Location permission not determined"
        @unknown default:
            lastEventMessage = "Unknown location permission status"
        }
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        lastEventMessage = "Started monitoring \(regionDisplayName(for: region.identifier))"
        objectWillChange.send()
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let placeName = regionDisplayName(for: region.identifier)
        lastEventMessage = "Exited region for \(placeName)"
        print("didExitRegion fired for: \(region.identifier)")

        sendExitReminder(for: placeName)

        objectWillChange.send()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastEventMessage = "Location manager failed: \(error.localizedDescription)"
        objectWillChange.send()
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        lastEventMessage = "Monitoring failed: \(error.localizedDescription)"
        objectWillChange.send()
    }
}
