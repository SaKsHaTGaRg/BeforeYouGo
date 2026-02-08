//
//  BeforeYouGoApp.swift
//  BeforeYouGo
//
//  Created by Sakshat Garg on 2026-02-01.
//

import SwiftUI

@main
struct BeforeYouGoApp: App {
    @StateObject private var vm = PlacesViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
        }
    }
}

