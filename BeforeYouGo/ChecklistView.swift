//
//  ChecklistView.swift
//
//
//  Created by Ivan Barnash on 2026-02-02.
//

import SwiftUI

struct ChecklistView: View {
    let place: Place

    @EnvironmentObject var viewModel: ChecklistViewModel
    @State private var newItemText: String = ""
    @State private var expandedItemId: ChecklistItem.ID? = nil

    private var hasNoItems: Bool {
        viewModel.pinned.isEmpty && viewModel.notPinned.isEmpty
    }

    var body: some View {
        List {
            addRow

            if hasNoItems {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("No checklist items yet")
                            .font(.headline)

                        Text("Add items you want to remember when leaving this place.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }

            if !viewModel.pinned.isEmpty {
                Section("Pinned reminders") {
                    ForEach(viewModel.pinned) { item in
                        row(item)
                    }
                    .onMove(perform: viewModel.movePinned)
                }
            }

            Section("Checklist") {
                ForEach(viewModel.notPinned) { item in
                    row(item)
                }
                .onMove(perform: viewModel.moveNotPinned)
            }
        }
        .navigationTitle("\(place.name) Checklist")
        .toolbar {
            EditButton()
        }
        .onAppear {
            viewModel.loadItems(for: place.id)
        }
    }

    private var addRow: some View {
        HStack {
            TextField("New item", text: $newItemText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()
                .submitLabel(.done)
                .onSubmit(addItem)

            Button {
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
        newItemText = ""
    }

    private func row(_ item: ChecklistItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Button {
                    viewModel.toggleEnabled(item)
                } label: {
                    Image(systemName: item.isEnabled ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                }
                .buttonStyle(.plain)

                Text(item.title)
                    .foregroundStyle(item.isEnabled ? .primary : .secondary)

                Spacer()

                Button {
                    viewModel.togglePinned(item)
                } label: {
                    Image(systemName: item.isPinned ? "pin.fill" : "pin")
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.snappy) {
                        expandedItemId = (expandedItemId == item.id) ? nil : item.id
                    }
                } label: {
                    Image(systemName: expandedItemId == item.id ? "chevron.up" : "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            if expandedItemId == item.id {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Notification message")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField(
                        "Don't forget your \(item.title)!",
                        text: Binding(
                            get: { item.customMessage ?? "" },
                            set: { viewModel.updateMessage(for: item, message: $0) }
                        ),
                        axis: .vertical
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(2...4)

                    Text("Preview \(item.notification)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                viewModel.delete(item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
