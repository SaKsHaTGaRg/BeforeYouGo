//
//  AddPlaceView.swift
//  BeforeYouGo
//
//  Created by Sakshat Garg on 2026-02-01.
//
import SwiftUI

struct AddPlaceView: View {
    @EnvironmentObject var vm: PlacesViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var placeName: String = ""
    @State private var radius: Double = 150

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                }

                Spacer()

                Text("Add Place")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    save()
                } label: {
                    Text("Save")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .disabled(placeName.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(placeName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
            }
            .frame(height: 48)
            .padding(.horizontal, 12)
            .background(Color.blue)

            Form {
                Section(header: Text("Place Name")) {
                    TextField("e.g., Home", text: $placeName)
                }

                Section(header: Text("Alert Radius: \(Int(radius)) m")) {
                    Slider(value: $radius, in: 50...500, step: 10)
                    HStack {
                        Text("50 m")
                        Spacer()
                        Text("500 m")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func save() {
        let cleaned = placeName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        vm.addPlace(name: cleaned, radiusMeters: radius)
        dismiss()
    }
}

