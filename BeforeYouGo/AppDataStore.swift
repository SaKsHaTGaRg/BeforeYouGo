//
//  AppDataStore.swift
//  BeforeYouGo
//
//  Created by Ivan Barnash on 2026-03-12
//

import Foundation
import SwiftData

@MainActor
final class AppDataStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - PLACES

    func fetchPlaces() -> [Place] {
        let descriptor = FetchDescriptor<PlaceModel>(
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            let models = try context.fetch(descriptor)
            return models.map { $0.toPlace() }
        } catch {
            debugLog("Failed to fetch places: \(error.localizedDescription)")
            return []
        }
    }

    func savePlace(_ place: Place) {
        let placeID = place.id

        let descriptor = FetchDescriptor<PlaceModel>(
            predicate: #Predicate { $0.id == placeID }
        )

        do {
            let models = try context.fetch(descriptor)

            if let existing = models.first {
                existing.update(from: place)
            } else {
                context.insert(place.toModel())
            }

            try context.save()
        } catch {
            debugLog("Failed to save place \(place.name): \(error.localizedDescription)")
        }
    }

    func deletePlace(id: UUID) {
        let placeID = id

        let descriptor = FetchDescriptor<PlaceModel>(
            predicate: #Predicate { $0.id == placeID }
        )

        do {
            let models = try context.fetch(descriptor)

            if let model = models.first {
                context.delete(model)
                try context.save()
            }
        } catch {
            debugLog("Failed to delete place \(id): \(error.localizedDescription)")
        }
    }

    // MARK: - CHECKLIST

    func fetchChecklistItems(for placeId: UUID) -> [ChecklistItem] {
        let pid = placeId

        let descriptor = FetchDescriptor<ChecklistItemModel>(
            predicate: #Predicate { $0.placeId == pid },
            sortBy: [SortDescriptor(\.sortOrder)]
        )

        do {
            let models = try context.fetch(descriptor)
            return models.map { $0.toChecklistItem() }
        } catch {
            debugLog("Failed to fetch checklist items for place \(placeId): \(error.localizedDescription)")
            return []
        }
    }

    func fetchEnabledChecklistItems(for placeId: UUID) -> [ChecklistItem] {
        fetchChecklistItems(for: placeId).filter { $0.isEnabled }
    }

    func saveChecklistItem(_ item: ChecklistItem) {
        let itemID = item.id

        let descriptor = FetchDescriptor<ChecklistItemModel>(
            predicate: #Predicate { $0.id == itemID }
        )

        do {
            let models = try context.fetch(descriptor)

            if let existing = models.first {
                existing.update(from: item)
            } else {
                context.insert(item.toModel())
            }

            try context.save()
        } catch {
            debugLog("Failed to save checklist item \(item.title): \(error.localizedDescription)")
        }
    }

    func saveChecklistItems(_ items: [ChecklistItem]) {
        for item in items {
            saveChecklistItem(item)
        }

        do {
            try context.save()
        } catch {
            debugLog("Failed to save checklist items batch: \(error.localizedDescription)")
        }
    }

    func deleteChecklistItem(id: UUID) {
        let itemID = id

        let descriptor = FetchDescriptor<ChecklistItemModel>(
            predicate: #Predicate { $0.id == itemID }
        )

        do {
            let models = try context.fetch(descriptor)

            if let model = models.first {
                context.delete(model)
                try context.save()
            }
        } catch {
            debugLog("Failed to delete checklist item \(id): \(error.localizedDescription)")
        }
    }

    func deleteChecklistItems(for placeId: UUID) {
        let pid = placeId

        let descriptor = FetchDescriptor<ChecklistItemModel>(
            predicate: #Predicate { $0.placeId == pid }
        )

        do {
            let models = try context.fetch(descriptor)

            for model in models {
                context.delete(model)
            }

            try context.save()
        } catch {
            debugLog("Failed to delete checklist items for place \(placeId): \(error.localizedDescription)")
        }
    }

    // MARK: - HISTORY

    func fetchHistoryEvents() -> [HistoryEvent] {
        let descriptor = FetchDescriptor<HistoryEventModel>(
            sortBy: [SortDescriptor(\.exitTime, order: .reverse)]
        )

        do {
            let models = try context.fetch(descriptor)
            return models.map { $0.toHistoryEvent() }
        } catch {
            debugLog("Failed to fetch history events: \(error.localizedDescription)")
            return []
        }
    }

    func saveHistoryEvent(_ event: HistoryEvent) {
        context.insert(event.toModel())

        do {
            try context.save()
        } catch {
            debugLog("Failed to save history event for \(event.placeName): \(error.localizedDescription)")
        }
    }

    func clearHistory() {
        let descriptor = FetchDescriptor<HistoryEventModel>()

        do {
            let models = try context.fetch(descriptor)

            for model in models {
                context.delete(model)
            }

            try context.save()
        } catch {
            debugLog("Failed to clear history: \(error.localizedDescription)")
        }
    }

    // MARK: - Debug

    private func debugLog(_ message: String) {
        #if DEBUG
        print("[AppDataStore] \(message)")
        #endif
    }
}
