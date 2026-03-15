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

    //PLACES
    func fetchPlaces() -> [Place] {
        let descriptor = FetchDescriptor<PlaceModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        let models = (try? context.fetch(descriptor)) ?? []
        return models.map { $0.toPlace() }
    }

    func savePlace(_ place: Place) {
        let descriptor = FetchDescriptor<PlaceModel>(
            predicate: #Predicate { $0.id == place.id }
        )

        if let existing = try? context.fetch(descriptor).first, let existing {
            existing.update(from: place)
        } else {
            context.insert(place.toModel())
        }

        try? context.save()
    }

    func deletePlace(id: UUID) {
        let descriptor = FetchDescriptor<PlaceModel>(
            predicate: #Predicate { $0.id == id }
        )

        if let model = try? context.fetch(descriptor).first, let model {
            context.delete(model)
            try? context.save()
        }
    }

    //CHECKLIST
    func fetchChecklistItems() -> [ChecklistItem] {
        let descriptor = FetchDescriptor<ChecklistItemModel>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        let models = (try? context.fetch(descriptor)) ?? []
        return models.map { $0.toChecklistItem() }
    }

    func saveChecklistItem(_ item: ChecklistItem) {
        let descriptor = FetchDescriptor<ChecklistItemModel>(
            predicate: #Predicate { $0.id == item.id }
        )

        if let existing = try? context.fetch(descriptor).first, let existing {
            existing.update(from: item)
        } else {
            context.insert(item.toModel())
        }

        try? context.save()
    }

    func saveChecklistItems(_ items: [ChecklistItem]) {
        for item in items {
            saveChecklistItem(item)
        }
        try? context.save()
    }

    func deleteChecklistItem(id: UUID) {
        let descriptor = FetchDescriptor<ChecklistItemModel>(
            predicate: #Predicate { $0.id == id }
        )

        if let model = try? context.fetch(descriptor).first, let model {
            context.delete(model)
            try? context.save()
        }
    }

    //HISTORY
    func fetchHistoryEvents() -> [HistoryEvent] {
        let descriptor = FetchDescriptor<HistoryEventModel>(
            sortBy: [SortDescriptor(\.exitTime, order: .reverse)]
        )
        let models = (try? context.fetch(descriptor)) ?? []
        return models.map { $0.toHistoryEvent() }
    }

    func saveHistoryEvent(_ event: HistoryEvent) {
        context.insert(event.toModel())
        try? context.save()
    }

    func clearHistory() {
        let descriptor = FetchDescriptor<HistoryEventModel>()
        let models = (try? context.fetch(descriptor)) ?? []

        for model in models {
            context.delete(model)
        }

        try? context.save()
    }
}