import SwiftUI
import Combine

@MainActor
final class PlacesViewModel: ObservableObject {
    @Published var places: [Place] = []

    private let dataStore: AppDataStore

    init(dataStore: AppDataStore) {
        self.dataStore = dataStore
        loadPlaces()
    }

    func addPlace(
    name: String,
    radiusMeters: Double,
    address: String? = nil,
    latitude: Double? = nil,
    longitude: Double? = nil,
    locationSource: Place.LocationSource = .unknown,
    reminderMessage: String? = nil
    ) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let trimmedReminder = reminderMessage?.trimmingCharacters(in: .whitespacesAndNewlines)

        let newPlace = Place(
            name: trimmedName,
            isEnabled: false,
            radiusMeters: radiusMeters,
            address: address,
            latitude: latitude,
            longitude: longitude,
            locationSource: locationSource,
            reminderMessage: trimmedReminder?.isEmpty == true ? nil : trimmedReminder
        )

        dataStore.savePlace(newPlace)
        loadPlaces()
    }

    func updatePlace(
    id: UUID,
    name: String,
    radiusMeters: Double,
    address: String? = nil,
    latitude: Double? = nil,
    longitude: Double? = nil,
    locationSource: Place.LocationSource = .unknown,
    reminderMessage: String? = nil
    ) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        guard let existing = places.first(where: { $0.id == id }) else { return }
        let trimmedReminder = reminderMessage?.trimmingCharacters(in: .whitespacesAndNewlines)

        let updated = Place(
            id: existing.id,
            name: trimmedName,
            isEnabled: existing.isEnabled,
            radiusMeters: radiusMeters,
            address: address,
            latitude: latitude,
            longitude: longitude,
            locationSource: locationSource,
            reminderMessage: trimmedReminder?.isEmpty == true ? nil : trimmedReminder
        )

        dataStore.savePlace(updated)
        loadPlaces()
    }

    func togglePlace(_ place: Place) {
        guard let existing = places.first(where: { $0.id == place.id }) else { return }

        let updated = Place(
            id: existing.id,
            name: existing.name,
            isEnabled: !existing.isEnabled,
            radiusMeters: existing.radiusMeters,
            address: existing.address,
            latitude: existing.latitude,
            longitude: existing.longitude,
            locationSource: existing.locationSource,
            reminderMessage: existing.reminderMessage
        )

        dataStore.savePlace(updated)
        loadPlaces()
    }

    func deletePlaces(at offsets: IndexSet) {
        let placesToDelete = offsets.map { places[$0] }

        for place in placesToDelete {
            dataStore.deleteChecklistItems(for: place.id)
            dataStore.deletePlace(id: place.id)
        }

        loadPlaces()
    }

    private func loadPlaces() {
        places = dataStore.fetchPlaces()
    }
}
