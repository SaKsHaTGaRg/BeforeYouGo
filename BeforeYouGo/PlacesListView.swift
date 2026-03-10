import SwiftUI

struct PlacesListView: View {
    @EnvironmentObject var vm: PlacesViewModel
    @State private var showAddPlace = false
    @State private var editingPlace: Place?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerBar

                if vm.places.isEmpty {
                    emptyStateView
                } else {
                    placesList
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
                    }

                    Spacer()

                    Toggle(
                        "",
                        isOn: Binding(
                            get: { place.isEnabled },
                            set: { _ in vm.togglePlace(place) }
                        )
                    )
                    .labelsHidden()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    editingPlace = place
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: vm.deletePlaces)
        }
        .listStyle(.insetGrouped)
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
}
