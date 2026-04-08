import SwiftUI
import CoreLocation

struct PlacesListView: View {
    @EnvironmentObject var vm: PlacesViewModel
    @EnvironmentObject var locationService: LocationManagerService

    @State private var showAddPlace = false
    @State private var editingPlace: Place?
    @State private var showPermissionAlert = false

    var body: some View {
        VStack(spacing: 0) {
            if vm.places.isEmpty {
                emptyStateView
            } else {
                placesList
            }

            if !locationService.lastEventMessage.isEmpty {
                statusBanner
            }

            addPlaceButton
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Places")
        .sheet(isPresented: $showAddPlace) {
            NavigationStack {
                AddPlaceView()
                    .environmentObject(vm)
            }
        }
        .sheet(item: $editingPlace) { place in
            NavigationStack {
                AddPlaceView(existingPlace: place)
                    .environmentObject(vm)
            }
        }
        .alert("Location Permission Needed", isPresented: $showPermissionAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please allow location access so region monitoring can work.")
        }
        .onAppear {
            locationService.restartMonitoring(for: vm.places)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("No places added yet")
                .font(.headline)

            Text("Tap the button below to add your first place.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
    }

    private var placesList: some View {
        List {
            ForEach(vm.places) { place in
                NavigationLink {
                    ChecklistView(place: place)
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(place.name)
                                .font(.headline)

                            Text("Radius: \(Int(place.radiusMeters)) m")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if let address = place.address, !address.isEmpty {
                                Text(address)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }

                            monitoringStatusText(for: place)
                        }

                        Spacer(minLength: 8)

                        VStack(spacing: 12) {
                            Button {
                                editingPlace = place
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.plain)

                            Toggle(
                                "",
                                isOn: Binding(
                                    get: { place.isEnabled },
                                    set: { newValue in
                                        handleToggleChange(for: place, newValue: newValue)
                                    }
                                )
                            )
                            .labelsHidden()
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete(perform: deletePlaces)
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private func monitoringStatusText(for place: Place) -> some View {
        let status = monitoringStatus(for: place)

        Label(status.text, systemImage: status.symbol)
            .font(.caption2)
            .foregroundStyle(status.color)
    }

    private func monitoringStatus(for place: Place) -> (text: String, symbol: String, color: Color) {
        if !place.hasCoordinates {
            return ("Saved, but no location is selected yet.", "mappin.slash", .orange)
        }

        if locationService.isMonitoring(place) {
            return ("Monitoring is active for this place.", "location.circle.fill", .green)
        }

        if !place.isEnabled {
            return ("Saved, but monitoring is turned off.", "pause.circle", .secondary)
        }

        switch locationService.authorizationStatus {
        case .denied, .restricted:
            return ("Enabled, but location permission is blocked.", "exclamationmark.triangle.fill", .red)
        case .notDetermined:
            return ("Enabled, but location permission has not been granted yet.", "questionmark.circle", .orange)
        case .authorizedWhenInUse:
            return ("Enabled, but Always Location access is still needed for geofence monitoring.", "lock.shield", .orange)
        case .authorizedAlways:
            return ("Enabled, but monitoring has not started yet.", "clock.arrow.circlepath", .orange)
        @unknown default:
            return ("Enabled, but monitoring status is unavailable.", "questionmark.circle", .orange)
        }
    }

    private var statusBanner: some View {
        Text(locationService.lastEventMessage)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
    }

    private var addPlaceButton: some View {
        Button {
            showAddPlace = true
        } label: {
            HStack {
                Image(systemName: "plus")
                Text("Add Place")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(.white)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }

    private func handleToggleChange(for place: Place, newValue: Bool) {
        if newValue {
            switch locationService.authorizationStatus {
            case .denied, .restricted:
                showPermissionAlert = true
                return

            case .notDetermined:
                locationService.requestPermission()
                showPermissionAlert = true
                return

            case .authorizedWhenInUse, .authorizedAlways:
                break

            @unknown default:
                showPermissionAlert = true
                return
            }

            let started = locationService.startMonitoring(for: place)

            if started {
                vm.togglePlace(place)
            }

        } else {
            locationService.stopMonitoring(for: place)
            vm.togglePlace(place)
        }
    }

    private func deletePlaces(at offsets: IndexSet) {
        let placesToDelete = offsets.map { vm.places[$0] }

        for place in placesToDelete {
            locationService.stopMonitoring(for: place)
        }

        vm.deletePlaces(at: offsets)
    }
}
