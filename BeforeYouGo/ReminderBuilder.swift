//
//  ReminderBuilder.swift
//  BeforeYouGo
//
//  Created by Ivan Barnash on 2026-04-07
//

import Foundation

struct ReminderContent {
    let title: String
    let body: String
}

enum ReminderBuilder {
    static func build(for place: Place, items: [ChecklistItem], itemLimit: Int = 5) -> ReminderContent? {
        let titles = items.map { $0.title }
        guard !titles.isEmpty else { return nil }
        let trimmedMessage = (place.reminderMessage ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let message = trimmedMessage.isEmpty ? "You left \(place.name)" : trimmedMessage
        let limit = max(1, itemLimit)
        let visibleTitles = Array(titles.prefix(limit))
        let remainingCount = titles.count - visibleTitles.count
        var itemList = visibleTitles.joined(separator: ", ")
        if remainingCount > 0 {
            itemList += ", +\(remainingCount) more"
        }

        return ReminderContent(
            title: "Reminder",
            body: "\(message) Items: \(itemList)"
        )
    }
}
