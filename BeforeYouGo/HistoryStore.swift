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

    private let key = "beforeyougo.history.events"

    init() {
        load()
    }

    func add(placeName: String, checklistName: String, checklistItems: [String], exitTime: Date = Date()) {
        let event = HistoryEvent(
            placeName: placeName,
            exitTime: exitTime,
            checklistName: checklistName,
            checklistItems: checklistItems
        )
        events.insert(event, at: 0)
        save()
    }

    func clear() {
        events = []
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            events = try JSONDecoder().decode([HistoryEvent].self, from: data)
        } catch {
            events = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(events)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            // ignore for now
        }
    }
}
