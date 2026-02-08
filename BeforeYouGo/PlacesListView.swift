//
//  PlacesListView.swift
//  BeforeYouGo
//
//  Created by Mansi on 2026-02-01.
//

import SwiftUI

struct PlacesListView: View {
    @EnvironmentObject var vm: PlacesViewModel
    @State private var showAddPlace = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.white)
                        .padding(.leading, 12)

                    Spacer()

                    Text("Places")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Spacer()

                    Text("History")
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.trailing, 12)
                }
                .frame(height: 48)
                .background(Color.blue)

                // List
                VStack(spacing: 12) {
                    ForEach($vm.places) { $place in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(place.name)
                                    .font(.headline)
                                Text("Radius: \(Int(place.radiusMeters)) m")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $place.isEnabled)
                                .labelsHidden()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                    }

                    Spacer()
                }
                .padding(.top, 16)
                .background(Color(.systemGroupedBackground))

                // Add button
                Button {
                    showAddPlace = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Place")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddPlace) {
                NavigationStack {
                    AddPlaceView()
                }
            }
        }
    }
}
