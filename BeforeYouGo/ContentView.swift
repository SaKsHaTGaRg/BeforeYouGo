//
//  ContentView.swift
//  BeforeYouGo
//
//  Created by Sakshat Garg on 2026-02-01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
<<<<<<< HEAD
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
=======
        NavigationStack{
            ChecklistView()
        }
>>>>>>> 894d451 (added my screen)
    }
}

#Preview {
    ContentView()
}
