import SwiftUI
import SwiftData

@main
struct BeforeYouGoApp: App {
    private let container: ModelContainer

    @StateObject private var vm: PlacesViewModel
    @StateObject private var historyStore: HistoryStore
    @StateObject private var checklistViewModel: ChecklistViewModel
    @StateObject private var locationService: LocationManagerService
    @StateObject private var notificationService: NotificationService

    init() {
        do {
            container = try ModelContainer(
                for: PlaceModel.self,
                ChecklistItemModel.self,
                HistoryEventModel.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        let dataStore = AppDataStore(context: ModelContext(container))
        let placesVM = PlacesViewModel(dataStore: dataStore)
        let historyStore = HistoryStore(dataStore: dataStore)
        let checklistVM = ChecklistViewModel(dataStore: dataStore)

        let notificationService = NotificationService()
        notificationService.requestPermission()

        _vm = StateObject(wrappedValue: placesVM)
        _historyStore = StateObject(wrappedValue: historyStore)
        _checklistViewModel = StateObject(wrappedValue: checklistVM)
        _notificationService = StateObject(wrappedValue: notificationService)
        _locationService = StateObject(
            wrappedValue: LocationManagerService(
                dataStore: dataStore,
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
                .environmentObject(notificationService)
                .onAppear {
                    locationService.syncMonitoring(with: vm.places)
                }
        }
        .modelContainer(container)
    }
}
