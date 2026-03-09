//
//  MapPickerView.swift
//  BeforeYouGo
//
//  Created by Sakshat Garg on 2026-03-09.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapPickerView: View {
    let initialCoordinate: CLLocationCoordinate2D?
    let onLocationPicked: (CLLocationCoordinate2D, String?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var resolvedAddress: String = ""
    @State private var isResolvingAddress = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                MapReader { proxy in
                    Map(position: $cameraPosition) {
                        if let selectedCoordinate {
                            Marker("Selected Place", coordinate: selectedCoordinate)
                        }
                    }
                    .mapControls {
                        MapCompass()
                        MapPitchToggle()
                        MapUserLocationButton()
                    }
                    .onTapGesture(coordinateSpace: .local) { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            selectCoordinate(coordinate)
                        }
                    }
                }

                Text("Tap anywhere on the map to choose a location")
                    .font(.subheadline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 12)
            }
            .navigationTitle("Pick on Map")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                bottomPanel
            }
            .onAppear {
                if let initialCoordinate {
                    selectedCoordinate = initialCoordinate
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: initialCoordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )
                }
            }
        }
    }

    private var bottomPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let selectedCoordinate {
                Text("Selected Coordinates")
                    .font(.headline)

                Text("Lat: \(selectedCoordinate.latitude.formatted(.number.precision(.fractionLength(5))))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Lon: \(selectedCoordinate.longitude.formatted(.number.precision(.fractionLength(5))))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if isResolvingAddress {
                    ProgressView("Finding address...")
                        .font(.caption)
                } else if !resolvedAddress.isEmpty {
                    Text(resolvedAddress)
                        .font(.subheadline)
                }
            } else {
                Text("No location selected yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }

                Spacer()

                Button("Use This Location") {
                    guard let selectedCoordinate else { return }
                    onLocationPicked(selectedCoordinate, resolvedAddress.isEmpty ? nil : resolvedAddress)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedCoordinate == nil)
            }
        }
        .padding()
        .background(.thinMaterial)
    }

    private func selectCoordinate(_ coordinate: CLLocationCoordinate2D) {
        selectedCoordinate = coordinate
        cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
        reverseGeocode(coordinate)
    }

    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        isResolvingAddress = true
        resolvedAddress = ""

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            DispatchQueue.main.async {
                isResolvingAddress = false
                resolvedAddress = placemarks?.first?.compactAddress ?? ""
            }
        }
    }
}

private extension CLPlacemark {
    var compactAddress: String {
        [
            name,
            locality,
            administrativeArea,
            postalCode,
            country
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }
}
