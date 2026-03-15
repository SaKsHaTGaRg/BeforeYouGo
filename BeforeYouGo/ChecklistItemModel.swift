//
//  ChecklistItemModel.swift
//  BeforeYouGo
//
//  Created by Ivan Barnash on 2026-03-12
//

import Foundation
import SwiftData

@Model
final class ChecklistItemModel {
    var id: UUID
    var placeId: UUID
    var title: String
    var isEnabled: Bool
    var isPinned: Bool
    var customMessage: String?
    var sortOrder: Int

    init(
    id: UUID = UUID(),
    placeId: UUID,
    title: String,
    isEnabled: Bool = true,
    isPinned: Bool = false,
    customMessage: String? = nil,
    sortOrder: Int
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

extension ChecklistItemModel {
    func toChecklistItem() -> ChecklistItem {
        ChecklistItem(
            id: id,
            placeId: placeId,
            title: title,
            isEnabled: isEnabled,
            isPinned: isPinned,
            customMessage: customMessage,
            sortOrder: sortOrder
        )
    }

    func update(from item: ChecklistItem) {
        id = item.id
        placeId = item.placeId
        title = item.title
        isEnabled = item.isEnabled
        isPinned = item.isPinned
        customMessage = item.customMessage
        sortOrder = item.sortOrder
    }
}

extension ChecklistItem {
    func toModel() -> ChecklistItemModel {
        ChecklistItemModel(
            id: id,
            placeId: placeId,
            title: title,
            isEnabled: isEnabled,
            isPinned: isPinned,
            customMessage: customMessage,
            sortOrder: sortOrder
        )
    }
}