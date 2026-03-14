import SwiftUI

@main
struct BeforeYouGoApp: App {
    @StateObject private var vm: PlacesViewModel
    @StateObject private var historyStore: HistoryStore
    @StateObject private var checklistViewModel: ChecklistViewModel
    @StateObject private var locationService: LocationManagerService

    init() {
        let placesVM = PlacesViewModel()
        let historyStore = HistoryStore()
        let checklistVM = ChecklistViewModel()
        let notificationService = NotificationService()

        notificationService.requestPermission()

        _vm = StateObject(wrappedValue: placesVM)
        _historyStore = StateObject(wrappedValue: historyStore)
        _checklistViewModel = StateObject(wrappedValue: checklistVM)
        _locationService = StateObject(
            wrappedValue: LocationManagerService(
                historyStore: historyStore,
                checklistViewModel: checklistVM,
                notificationService: notificationService
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .environmentObject(historyStore)
                .environmentObject(checklistViewModel)
                .environmentObject(locationService)
        }
    }
}
