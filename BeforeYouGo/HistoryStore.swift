//
//  HistoryStore.swift
//  BeforeYouGo
//
//  Created by Artem Basko on 2026-02-07.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class HistoryStore: ObservableObject {
    @Published private(set) var events: [HistoryEvent] = []

    private let dataStore: AppDataStore

    init(dataStore: AppDataStore) {
        self.dataStore = dataStore
        load()
    }

    func add(
    placeName: String,
    checklistName: String,
    checklistItems: [String],
    exitTime: Date = Date()
    ) {
        let event = HistoryEvent(
            placeName: placeName,
            exitTime: exitTime,
            checklistName: checklistName,
            checklistItems: checklistItems
        )

        dataStore.saveHistoryEvent(event)
        load()
    }

    func clear() {
        dataStore.clearHistory()
        load()
    }

    private func load() {
        events = dataStore.fetchHistoryEvents()
    }
}
