//
//  ContentView.swift
//  BeforeYouGo
//
//  Created by Sakshat Garg on 2026-02-01.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ChecklistView()
            }
            .tabItem {
                Label("Checklist", systemImage: "checklist")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock")
            }
        }
    }
}

#Preview {
    ContentView()
}
