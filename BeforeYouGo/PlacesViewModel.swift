import SwiftUI
import Combine

@MainActor
final class PlacesViewModel: ObservableObject {
    @Published var places: [Place] = [] {
        didSet {
            savePlaces()
        }
    }

    private let storageKey = "saved_places"

    init() {
        loadPlaces()
    }

    func addPlace(
        name: String,
        radiusMeters: Double,
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        locationSource: Place.LocationSource = .unknown
    ) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let newPlace = Place(
            name: trimmedName,
            isEnabled: false,
            radiusMeters: radiusMeters,
            address: address,
            latitude: latitude,
            longitude: longitude,
            locationSource: locationSource
        )

        places.append(newPlace)
    }

    func updatePlace(
        id: UUID,
        name: String,
        radiusMeters: Double,
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        locationSource: Place.LocationSource = .unknown
    ) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        guard let index = places.firstIndex(where: { $0.id == id }) else { return }

        places[index].name = trimmedName
        places[index].radiusMeters = radiusMeters
        places[index].address = address
        places[index].latitude = latitude
        places[index].longitude = longitude
        places[index].locationSource = locationSource
    }

    func togglePlace(_ place: Place) {
        guard let index = places.firstIndex(where: { $0.id == place.id }) else { return }
        places[index].isEnabled.toggle()
    }

    func deletePlaces(at offsets: IndexSet) {
        places.remove(atOffsets: offsets)
    }

    private func savePlaces() {
        do {
            let data = try JSONEncoder().encode(places)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save places: \(error.localizedDescription)")
        }
    }

    private func loadPlaces() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            places = []
            return
        }

        do {
            places = try JSONDecoder().decode([Place].self, from: data)
        } catch {
            print("Failed to load places: \(error.localizedDescription)")
            places = []
        }
    }
}
