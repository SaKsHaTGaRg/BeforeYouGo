//
//  PlaceModel.swift
//  BeforeYouGo
//
//  Created by Ivan Barnash on 2026-03-12
//

import Foundation
import SwiftData

@Model
final class PlaceModel {
    var id: UUID
    var name: String
    var isEnabled: Bool
    var radiusMeters: Double
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var locationSourceRaw: String

    init(
    id: UUID = UUID(),
    name: String,
    isEnabled: Bool = true,
    radiusMeters: Double = 100,
    address: String? = nil,
    latitude: Double? = nil,
    longitude: Double? = nil,
    locationSourceRaw: String = Place.LocationSource.unknown.rawValue
    ) {
        self.id = id
        self.name = name
        self.isEnabled = isEnabled
        self.radiusMeters = radiusMeters
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.locationSourceRaw = locationSourceRaw
    }

    var hasCoordinates: Bool {
        latitude != nil && longitude != nil
    }

    var locationSource: Place.LocationSource {
        get { Place.LocationSource(rawValue: locationSourceRaw) ?? .unknown }
        set { locationSourceRaw = newValue.rawValue }
    }
}

extension PlaceModel {
    func toPlace() -> Place {
        Place(
            id: id,
            name: name,
            isEnabled: isEnabled,
            radiusMeters: radiusMeters,
            address: address,
            latitude: latitude,
            longitude: longitude,
            locationSource: locationSource
        )
    }

    func update(from place: Place) {
        id = place.id
        name = place.name
        isEnabled = place.isEnabled
        radiusMeters = place.radiusMeters
        address = place.address
        latitude = place.latitude
        longitude = place.longitude
        locationSource = place.locationSource
    }
}

extension Place {
    func toModel() -> PlaceModel {
        PlaceModel(
            id: id,
            name: name,
            isEnabled: isEnabled,
            radiusMeters: radiusMeters,
            address: address,
            latitude: latitude,
            longitude: longitude,
            locationSourceRaw: locationSource.rawValue
        )
    }
}