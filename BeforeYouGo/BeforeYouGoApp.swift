import SwiftUI

@main
struct BeforeYouGoApp: App {
    @StateObject private var vm = PlacesViewModel()
    @StateObject private var locationService = LocationManagerService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .environmentObject(locationService)
        }
    }
}
