//
//  HistoryView.swift
//  BeforeYouGo
//
//  Created by Artem Basko on 2026-02-07.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var store = HistoryStore()

    var body: some View {
        List {
            if store.events.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "clock")
                        .font(.system(size: 34))
                        .foregroundStyle(.secondary)
                    Text("No history yet")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                ForEach(store.events) { event in
                    NavigationLink {
                        HistoryDetailView(event: event)
                    } label: {
                        HistoryRow(event: event)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("History")
        .toolbar {
            if !store.events.isEmpty {
                Button("Clear") {
                    store.clear()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

private struct HistoryRow: View {
    let event: HistoryEvent

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.placeName)
                    .font(.headline)

                Text("Exited at \(event.exitTime.formatted(date: .omitted, time: .shortened))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Triggered: \(event.checklistName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
        )
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
    }
}

private struct HistoryDetailView: View {
    let event: HistoryEvent

    var body: some View {
        List {
            Section("Exit") {
                Text(event.placeName)
                Text(event.exitTime.formatted(date: .abbreviated, time: .shortened))
            }

            Section("Checklist") {
                Text(event.checklistName)
                ForEach(event.checklistItems, id: \.self) { item in
                    Text(item)
                }
            }
        }
        .navigationTitle("Details")
    }
}
