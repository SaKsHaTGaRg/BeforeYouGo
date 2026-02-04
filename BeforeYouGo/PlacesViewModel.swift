//
//  PlacesViewModel.swift
//  BeforeYouGo
//
//  Created by Sakshat Garg on 2026-02-01.
//

import SwiftUI
import Combine

@MainActor
final class PlacesViewModel: ObservableObject {
    @Published var places: [Place] = [
        Place(name: "Home", isEnabled: true, radiusMeters: 100),
        Place(name: "Work", isEnabled: false, radiusMeters: 200)
    ]

    func addPlace(name: String, radiusMeters: Double) {
        let newPlace = Place(name: name, radiusMeters: radiusMeters)
        places.append(newPlace)
    }
}

