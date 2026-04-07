import Foundation

struct Place: Identifiable, Codable, Equatable {
    enum LocationSource: String, Codable {
        case currentLocation
        case typedAddress
        case mapSelection
        case unknown
    }

    let id: UUID
    var name: String
    var isEnabled: Bool
    var radiusMeters: Double

    var address: String?
    var latitude: Double?
    var longitude: Double?
    var locationSource: LocationSource
    var reminderMessage: String?

    init(
        id: UUID = UUID(),
        name: String,
        isEnabled: Bool = true,
        radiusMeters: Double = 100,
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        locationSource: LocationSource = .unknown,
        reminderMessage: String? = nil
    ) {
        self.id = id
        self.name = name
        self.isEnabled = isEnabled
        self.radiusMeters = radiusMeters
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.locationSource = locationSource
        self.reminderMessage = reminderMessage
    }

    var hasCoordinates: Bool {
        latitude != nil && longitude != nil
    }
}
