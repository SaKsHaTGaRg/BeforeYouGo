//
//  ChecklistItem.swift
//  
//
//  Created by Ivan Barnash on 2026-02-02.
//
import Foundation

struct ChecklistItem: Identifiable, Hashable {
    let id: UUID
    var placeId: UUID
    var title: String
    var isEnabled: Bool
    var isPinned: Bool
    var customMessage: String?
    var sortOrder: Int

    var notification: String {
        let trimmed = (customMessage ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Don't forget your \(title)!" : trimmed
    }

    init(
    id: UUID = UUID(),
    placeId: UUID,
    title: String,
    isEnabled: Bool = true,
    isPinned: Bool = false,
    customMessage: String? = nil,
    sortOrder: Int = 0
    ) {
        self.id = id
        self.placeId = placeId
        self.title = title
        self.isEnabled = isEnabled
        self.isPinned = isPinned
        self.customMessage = customMessage
        self.sortOrder = sortOrder
    }
}
