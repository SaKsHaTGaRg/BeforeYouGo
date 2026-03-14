//
//  HistoryEvent.swift
//  BeforeYouGo
//
//  Created by Artem Basko on 2026-02-07.
//

import Foundation

struct HistoryEvent: Identifiable, Codable, Equatable {
    let id: UUID
    let placeName: String
    let exitTime: Date
    let checklistName: String
    let checklistItems: [String]

    init(
        id: UUID = UUID(),
        placeName: String,
        exitTime: Date = Date(),
        checklistName: String,
        checklistItems: [String]
    ) {
        self.id = id
        self.placeName = placeName
        self.exitTime = exitTime
        self.checklistName = checklistName
        self.checklistItems = checklistItems
    }
}
