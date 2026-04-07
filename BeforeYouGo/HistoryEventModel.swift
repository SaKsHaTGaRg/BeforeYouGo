//
//  HistoryEventModel.swift
//  BeforeYouGo
//
//  Created by Ivan Barnash on 2026-03-12
//


import Foundation
import SwiftData

@Model
final class HistoryEventModel {
    var id: UUID
    var placeName: String
    var exitTime: Date
    var checklistName: String
    var checklistItems: [String]

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

extension HistoryEventModel {
    func toHistoryEvent() -> HistoryEvent {
        HistoryEvent(
            id: id,
            placeName: placeName,
            exitTime: exitTime,
            checklistName: checklistName,
            checklistItems: checklistItems
        )
    }

    func update(from event: HistoryEvent) {
        id = event.id
        placeName = event.placeName
        exitTime = event.exitTime
        checklistName = event.checklistName
        checklistItems = event.checklistItems
    }
}

extension HistoryEvent {
    func toModel() -> HistoryEventModel {
        HistoryEventModel(
            id: id,
            placeName: placeName,
            exitTime: exitTime,
            checklistName: checklistName,
            checklistItems: checklistItems
        )
    }
}