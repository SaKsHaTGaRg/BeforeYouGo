//
//  ChecklistViewModel.swift
//  
//
//  Created by Ivan Barnash on 2026-02-02.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ChecklistViewModel: ObservableObject {
    @Published var items: [ChecklistItem] = []

    private let dataStore: AppDataStore
    private(set) var currentPlaceId: UUID?

    init(dataStore: AppDataStore) {
        self.dataStore = dataStore
    }

    var pinned: [ChecklistItem] {
        items.filter { $0.isPinned }.sorted { $0.sortOrder < $1.sortOrder }
    }

    var notPinned: [ChecklistItem] {
        items.filter { !$0.isPinned }.sorted { $0.sortOrder < $1.sortOrder }
    }

    func loadItems(for placeId: UUID) {
        currentPlaceId = placeId
        items = dataStore.fetchChecklistItems(for: placeId)
        normalizeSortOrders()
    }

    func enabledItems(for placeId: UUID) -> [ChecklistItem] {
        dataStore.fetchEnabledChecklistItems(for: placeId)
    }

    func addItem(_ title: String) {
        guard let placeId = currentPlaceId else { return }

        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newItem = ChecklistItem(
            placeId: placeId,
            title: trimmed,
            isEnabled: true,
            isPinned: false,
            customMessage: nil,
            sortOrder: nextSortOrder()
        )

        items.append(newItem)
        persistAll()
    }

    func updateMessage(for item: ChecklistItem, message: String) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        items[index].customMessage = trimmed.isEmpty ? nil : trimmed
        dataStore.saveChecklistItem(items[index])
    }

    func toggleEnabled(_ item: ChecklistItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isEnabled.toggle()
        dataStore.saveChecklistItem(items[index])
    }

    func togglePinned(_ item: ChecklistItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isPinned.toggle()
        normalizeSortOrders()
        persistAll()
    }

    func movePinned(from source: IndexSet, to destination: Int) {
        var section = pinned
        section.move(fromOffsets: source, toOffset: destination)

        let others = notPinned
        reassign(section: section, isPinned: true)
        reassign(section: others, isPinned: false)

        persistAll()
    }

    func moveNotPinned(from source: IndexSet, to destination: Int) {
        var section = notPinned
        section.move(fromOffsets: source, toOffset: destination)

        let pinnedItems = pinned
        reassign(section: pinnedItems, isPinned: true)
        reassign(section: section, isPinned: false)

        persistAll()
    }

    func delete(_ item: ChecklistItem) {
        items.removeAll { $0.id == item.id }
        dataStore.deleteChecklistItem(id: item.id)
        normalizeSortOrders()
        persistAll()
    }

    private func nextSortOrder() -> Int {
        (items.map(\.sortOrder).max() ?? -1) + 1
    }

    private func normalizeSortOrders() {
        let pinnedItems = pinned.enumerated().map { offset, item in
            var updated = item
            updated.sortOrder = offset
            return updated
        }

        let notPinnedItems = notPinned.enumerated().map { offset, item in
            var updated = item
            updated.sortOrder = offset
            return updated
        }

        let combined = pinnedItems + notPinnedItems

        for updated in combined {
            if let index = items.firstIndex(where: { $0.id == updated.id }) {
                items[index] = updated
            }
        }
    }

    private func reassign(section: [ChecklistItem], isPinned: Bool) {
        for (offset, item) in section.enumerated() {
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index].isPinned = isPinned
                items[index].sortOrder = offset
            }
        }
    }

    private func persistAll() {
        dataStore.saveChecklistItems(items)

        if let currentPlaceId {
            items = dataStore.fetchChecklistItems(for: currentPlaceId)
        }
    }
}
    
