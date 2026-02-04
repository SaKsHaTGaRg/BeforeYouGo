//
//  Place.swift
//  BeforeYouGo
//
//  Created by Sakshat Garg on 2026-02-01.
//

import SwiftUI


struct Place: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var isEnabled: Bool
    var radiusMeters: Double

    init(id: UUID = UUID(),
         name: String,
         isEnabled: Bool = true,
         radiusMeters: Double = 100) {
        self.id = id
        self.name = name
        self.isEnabled = isEnabled
        self.radiusMeters = radiusMeters
    }
}
