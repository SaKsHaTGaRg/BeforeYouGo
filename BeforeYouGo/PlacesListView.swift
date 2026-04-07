import SwiftUI
 import CoreLocation

struct PlacesListView: View {
    @EnvironmentObject var vm: PlacesViewModel
    @EnvironmentObject var locationService: LocationManagerService

    @State private var showAddPlace = false
    @State private var editingPlace: Place?
    @State private var showPermissionAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerBar

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
            .navigationBarHidden(true)
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
    }

    private var headerBar: some View {
        HStack {
            Image(systemName: "gearshape")
            .foregroundStyle(.white)
            .padding(.leading, 12)

            Spacer()

            Text("Places")
            .font(.headline)
            .foregroundStyle(.white)

            Spacer()

            Text("History")
            .foregroundStyle(.white.opacity(0.8))
            .padding(.trailing, 12)
        }
        .frame(height: 48)
        .background(Color.blue)
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
                    HStack {
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

                        Spacer()

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
                    .padding(.vertical, 4)
                }
            }
            .onDelete(perform: deletePlaces)
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private func monitoringStatusText(for place: Place) -> some View {
        if !place.hasCoordinates {
            Text("No coordinates saved")
            .font(.caption2)
            .foregroundStyle(.orange)
        } else if locationService.isMonitoring(place) {
            Text("Monitoring active")
            .font(.caption2)
            .foregroundStyle(.green)
        } else if place.isEnabled {
            Text("Enabled, not currently monitored")
            .font(.caption2)
            .foregroundStyle(.orange)
        } else {
            Text("Monitoring off")
            .font(.caption2)
            .foregroundStyle(.secondary)
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
            if locationService.authorizationStatus == .denied ||
               locationService.authorizationStatus == .restricted {

                showPermissionAlert = true
                return
            }

            vm.togglePlace(place)

            if let updated = vm.places.first(where: { $0.id == place.id }) {
                locationService.startMonitoring(for: updated)
            }

        } else {
            vm.togglePlace(place)
            locationService.stopMonitoring(for: place)
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
