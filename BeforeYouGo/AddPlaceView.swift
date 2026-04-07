//
//  AddPlaceView.swift
//  BeforeYouGo
//
//  Created by Sakshat Garg on 2026-02-01.
//

import SwiftUI
import CoreLocation
import Combine

struct AddPlaceView: View {
    @EnvironmentObject var vm: PlacesViewModel
    @EnvironmentObject var locationService: LocationManagerService
    @Environment(\.dismiss) private var dismiss

    private let existingPlace: Place?

    @State private var placeName: String
    @State private var radius: Double

    @State private var addressText: String
    @State private var selectedLatitude: Double?
    @State private var selectedLongitude: Double?
    @State private var selectedAddress: String
    @State private var selectedSource: Place.LocationSource
    @State private var reminderMessage: String

    @State private var showMapPicker = false
    @State private var locationError: String?
    @State private var isSearchingAddress = false

    @StateObject private var currentLocationHelper = CurrentLocationHelper()

    init(existingPlace: Place? = nil) {
        self.existingPlace = existingPlace
        _placeName = State(initialValue: existingPlace?.name ?? "")
        _radius = State(initialValue: existingPlace?.radiusMeters ?? 150)
        _addressText = State(initialValue: existingPlace?.address ?? "")
        _selectedLatitude = State(initialValue: existingPlace?.latitude)
        _selectedLongitude = State(initialValue: existingPlace?.longitude)
        _selectedAddress = State(initialValue: existingPlace?.address ?? "")
        _selectedSource = State(initialValue: existingPlace?.locationSource ?? .unknown)
        _reminderMessage = State(initialValue: existingPlace?.reminderMessage ?? "")
    }

    private var canSave: Bool {
        !placeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedLatitude != nil &&
        selectedLongitude != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            Form {
                Section("Place Name") {
                    TextField("e.g., Home", text: $placeName)
                }

                Section("Set Location") {
                    Button {
                        useCurrentLocation()
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Use Current Location")
                        }
                    }

                    Button {
                        showMapPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "map.fill")
                            Text("Pick on Map")
                        }
                    }
                }

                Section("Search Address") {
                    TextField("Enter address", text: $addressText)

                    Button {
                        searchAddress()
                    } label: {
                        HStack {
                            if isSearchingAddress {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text("Find Address")
                        }
                    }
                    .disabled(addressText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSearchingAddress)
                }

                Section("Alert Radius: \(Int(radius)) m") {
                    Slider(value: $radius, in: 50...500, step: 10)

                    HStack {
                        Text("50 m")
                        Spacer()
                        Text("500 m")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Section("Reminder Message") {
                    TextField("You left \(placeName.isEmpty ? "this place" : placeName)", text: $reminderMessage, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Selected Location") {
                    if let lat = selectedLatitude, let lon = selectedLongitude {
                        if !selectedAddress.isEmpty {
                            Text(selectedAddress)
                                .font(.body)
                        }

                        Text("Latitude: \(lat.formatted(.number.precision(.fractionLength(5))))")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("Longitude: \(lon.formatted(.number.precision(.fractionLength(5))))")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("Source: \(sourceLabel)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("No location selected yet.")
                            .foregroundStyle(.secondary)
                    }

                    if let locationError {
                        Text(locationError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showMapPicker) {
            MapPickerView(
                initialCoordinate: currentCoordinate
            ) { coordinate, resolvedAddress in
                selectedLatitude = coordinate.latitude
                selectedLongitude = coordinate.longitude
                selectedAddress = resolvedAddress ?? ""
                selectedSource = .mapSelection
                locationError = nil
            }
        }
        .onChange(of: currentLocationHelper.selectedLocation) { _, newValue in
            guard let newValue else { return }

            selectedLatitude = newValue.latitude
            selectedLongitude = newValue.longitude
            selectedAddress = newValue.address
            selectedSource = .currentLocation
            locationError = nil
        }
        .onChange(of: currentLocationHelper.errorMessage) { _, newValue in
            if let newValue {
                locationError = newValue
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.white)
            }

            Spacer()

            Text(existingPlace == nil ? "Add Place" : "Edit Place")
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
            .disabled(!canSave)
            .opacity(canSave ? 1.0 : 0.6)
        }
        .frame(height: 48)
        .padding(.horizontal, 12)
        .background(Color.blue)
    }

    private var currentCoordinate: CLLocationCoordinate2D? {
        guard let lat = selectedLatitude, let lon = selectedLongitude else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    private var sourceLabel: String {
        switch selectedSource {
        case .currentLocation:
            return "Current Location"
        case .typedAddress:
            return "Typed Address"
        case .mapSelection:
            return "Map Selection"
        case .unknown:
            return "Unknown"
        }
    }

    private func useCurrentLocation() {
        locationError = nil
        currentLocationHelper.requestCurrentLocation()
    }

    private func searchAddress() {
        let trimmed = addressText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isSearchingAddress = true
        locationError = nil

        CLGeocoder().geocodeAddressString(trimmed) { placemarks, error in
            DispatchQueue.main.async {
                isSearchingAddress = false

                if let error {
                    locationError = "Address search failed: \(error.localizedDescription)"
                    return
                }

                guard let placemark = placemarks?.first,
                      let location = placemark.location else {
                    locationError = "Could not find that address."
                    return
                }

                selectedLatitude = location.coordinate.latitude
                selectedLongitude = location.coordinate.longitude
                selectedAddress = placemark.compactAddress ?? trimmed
                selectedSource = .typedAddress
            }
        }
    }

    private func save() {
        let cleaned = placeName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            !cleaned.isEmpty,
            let lat = selectedLatitude,
            let lon = selectedLongitude
        else {
            return
        }

        if let existingPlace {
            vm.updatePlace(
                id: existingPlace.id,
                name: cleaned,
                radiusMeters: radius,
                address: selectedAddress.isEmpty ? nil : selectedAddress,
                latitude: lat,
                longitude: lon,
                locationSource: selectedSource,
                reminderMessage: reminderMessage
            )

            if existingPlace.isEnabled {
                locationService.stopMonitoring(for: existingPlace)

                if let updated = vm.places.first(where: { $0.id == existingPlace.id }) {
                    locationService.startMonitoring(for: updated)
                }
            }
        } else {
            vm.addPlace(
                name: cleaned,
                radiusMeters: radius,
                address: selectedAddress.isEmpty ? nil : selectedAddress,
                latitude: lat,
                longitude: lon,
                locationSource: selectedSource,
                reminderMessage: reminderMessage
            )
        }

        dismiss()
    }
}

struct SelectedLocationData: Equatable {
    let latitude: Double
    let longitude: Double
    let address: String
}

final class CurrentLocationHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var selectedLocation: SelectedLocationData?
    @Published var errorMessage: String?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestCurrentLocation() {
        errorMessage = nil

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Location permission is denied. Please enable it in Settings."
        @unknown default:
            errorMessage = "Location permission is unavailable."
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Location permission is denied. Please enable it in Settings."
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            errorMessage = "Could not get your current location."
            return
        }

        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let error {
                    self.errorMessage = "Reverse geocoding failed: \(error.localizedDescription)"
                    return
                }

                let address = placemarks?.first?.compactAddress ?? "Current Location"

                self.selectedLocation = SelectedLocationData(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    address: address
                )
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Could not get your current location: \(error.localizedDescription)"
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
