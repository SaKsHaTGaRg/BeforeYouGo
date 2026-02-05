//
//  ChecklistView.swift
//  
//
//  Created by Ivan Barnash on 2026-02-02.
//

import SwiftUI

struct ChecklistView: View {
    
    @StateObject private var viewModel = ChecklistViewModel()
    @State private var newItemText: String = ""
    
    var body: some View {
        List{
            addRow
            if !viewModel.items.isEmpty {
                Section("Pinned reminders"){
                    ForEach(viewModel.pinned){
                        item in row(item)
                    }
                    .onMove(perform: viewModel.movePinned)
                }
            }
            Section("Checklist"){
                ForEach(viewModel.notPinned){
                    item in row (item)
                }
                .onMove(perform: viewModel.moveNotPinned)
            }
        }
        .navigationTitle("Checklist")
        .toolbar {
            EditButton()
        }
    }
    private var addRow: some View {
        HStack{
            TextField("New item", text: $newItemText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()
                .submitLabel(.done)
                .onSubmit(addItem)
            Button{
                addItem()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
            }
            .disabled(newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
    private func addItem() {
        viewModel.addItem(newItemText)
        newItemText=""
    }
    private func row(_ item: ChecklistItem) -> some View {
        HStack(spacing:12){
            Button{
                viewModel.toggleEnabled(item)
            } label:{
                Image(systemName:item.isEnabled ? "checkmark.circle.fill":"circle").font(.title3)
            }
            .buttonStyle(.plain)
            
            Text(item.title).foregroundStyle(item.isEnabled ? .primary : .secondary)
            Spacer()
            Button{
                viewModel.togglePinned(item)
            } label:{
                Image(systemName:item.isPinned ? "pin.fill" : "pin")
            }
            .buttonStyle(.plain)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe:true){
            Button(role:.destructive){
                viewModel.delete(item)
            } label:{
                Label("Delete",systemImage:"trash")
            }
        }
    }
}

