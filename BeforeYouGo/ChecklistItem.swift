//
//  ChecklistItem.swift
//  
//
//  Created by Ivan Barnash on 2026-02-02.
//
import Foundation

struct ChecklistItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var isEnabled: Bool
    var isPinned: Bool

    init(id: UUID = UUID(), title: String, isEnabled: Bool = true, isPinned: Bool = false)
    {
        self.id = id
        self.title = title
        self.isEnabled = isEnabled
        self.isPinned = isPinned
    }
}
