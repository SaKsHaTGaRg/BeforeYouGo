//
//  Untitled.swift
//  
//
//  Created by Ivan Barnash on 2026-02-02.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ChecklistViewModel: ObservableObject {
    
    @Published var items: [ChecklistItem] = [
        .init(title: "Keys", isEnabled: true, isPinned: true),
        .init(title: "Wallet", isEnabled: true, isPinned: true),
        .init(title: "Phone", isEnabled: true, isPinned: false),
        .init(title: "Power Bank", isEnabled: false, isPinned: false),
    ]
    var pinned: [ChecklistItem] {items.filter {$0.isPinned}}
    var notPinned: [ChecklistItem] {items.filter {!$0.isPinned}}
    
    func addItem(_ title:String){
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else {return}
        items.append(ChecklistItem(title:t))
    }
    func updateMessage(for item: ChecklistItem, message: String){
        guard let i = items.firstIndex(where: { $0.id == item.id }) else {return}
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        items[i].customMessage = trimmed.isEmpty ? nil : trimmed
    }
    func toggleEnabled(_ item:ChecklistItem){
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {return}
        items[index].isEnabled.toggle()
    }
    func togglePinned(_ item:ChecklistItem){
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {return}
        items[index].isPinned.toggle()
    }
    func movePinned(from source:IndexSet, to destination:Int ){
        var p = pinned
        p.move(fromOffsets:source, toOffset:destination)
        items = p + notPinned
    }
    func moveNotPinned(from source:IndexSet, to destination:Int ){
        var np = notPinned
        np.move(fromOffsets:source, toOffset:destination)
        items = pinned + np
    }
    func delete(_ item:ChecklistItem){
        items.removeAll{$0.id == item.id}
    }
}
    
    
