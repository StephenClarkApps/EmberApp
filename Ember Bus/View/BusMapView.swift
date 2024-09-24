//
//  BusMapView.swift
//  Ember Bus
//
//  Created by Stephen Clark on 10/09/2024.
//

import Combine
import SwiftUI
import MapKit

struct BusMapView: View {
    @StateObject private var viewModel: TripViewModel
    @State private var mapRegion: MKCoordinateRegion
    @State private var busCoordinate: IdentifiableCoordinate
    @State private var isCalloutVisible = false
    @State private var userHasMovedMap = false
    @State private var isProgrammaticRegionChange = false  // New flag
    @State private var mapZoom: Double = 0.05
    @State private var showStopList: Bool = false

    // Use @AppStorage to observe changes in UserDefaults
    @AppStorage("autoDismissCallout") private var autoDismissCallout: Bool = UserDefaults.standard.autoDismissCallout
    @AppStorage("autoPollEnabled") private var autoPollEnabled: Bool = UserDefaults.standard.autoPollEnabled
    @AppStorage("defaultZoomLevel") private var defaultZoomLevel: Double = UserDefaults.standard.defaultZoomLevel

    @State private var timer: AnyCancellable?

    init(tripId: String) {
        _viewModel = StateObject(wrappedValue: TripViewModel(tripId: tripId))
        _mapRegion = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        _busCoordinate = State(initialValue: IdentifiableCoordinate(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)))
    }

    var body: some View {
        VStack {
            // Slider for controlling the map's zoom level
            VStack {
                let zoomDistance = zoomLevelToDistance(mapZoom)
                Text("Zoom Level: \(zoomDistance)")

                Slider(value: $mapZoom, in: 0.01...0.7, step: 0.03)
                    .padding()
                    .onChange(of: mapZoom) { newValue in
                        Log.shared.info("Zoom level adjusted to: \(newValue)")
                        updateMapZoom()
                    }
            }
            .onAppear {
                // Initialize mapZoom from defaultZoomLevel
                mapZoom = defaultZoomLevel
            }
            .onChange(of: defaultZoomLevel) { newValue in
                mapZoom = newValue
                updateMapZoom()
            }

            // Map with bus annotation
            Map(coordinateRegion: $mapRegion, annotationItems: [busCoordinate]) { coordinate in
                MapAnnotation(coordinate: coordinate.coordinate) {
                    BusAnnotationView(isCalloutVisible: $isCalloutVisible)
                        .environmentObject(viewModel)
                        .onTapGesture {
                            Log.shared.info("Bus tapped. Showing callout.")
                            isCalloutVisible = true
                        }
                }
            }
            .mapStyle(.standard)
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .sheet(isPresented: $showStopList) {
                                   // Present StopListView as a sheet
                                   if let trip = viewModel.trip {
                                       StopListView(trip: trip)
                                   } else {
                                       Text("Trip data is unavailable.")
                                   }
                               }
            .onMapCameraChange(frequency: .onEnd) { context in
                Log.shared.info("onMapCameraChange triggered")

                if isProgrammaticRegionChange {
                    Log.shared.info("Map camera change was programmatic.")
                    isProgrammaticRegionChange = false
                } else {
                    Log.shared.info("User initiated map move. Tracking.")
                    userHasMovedMap = true
                    if autoDismissCallout {
                        Log.shared.info("User moved the map. Dismissing callout.")
                        isCalloutVisible = false
                    }
                }
            }
            
            // Info Button to navigate to StopListView
               Button(action: {
                   showStopList = true
               }) {
                   HStack {
                       Image(systemName: "info.circle")
                       Text("View Stops")
                   }
                   .frame(maxWidth: .infinity)
                   .padding()
                   .background(Color.blue)
                   .foregroundColor(.white)
                   .cornerRadius(8)
               }
               .padding(.top, 2)
               .padding(.leading, 15)
               .padding(.trailing, 15)
               .padding(.bottom, 8)

            if(!autoPollEnabled) {
                // Refresh Button
                Button(action: {
                    Log.shared.info("Refresh button tapped. Fetching updated trip data.")
                    viewModel.fetchTripData()
                }) {
                    Text("Refresh Trip Data")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 2)
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .padding(.bottom, 8)
            }
        }
        .onAppear {
            Log.shared.info("BusMapView appeared.")

            // Fetch trip data once when the view appears
            viewModel.fetchTripData()

            if autoPollEnabled {
                startAutoPolling()
            }
        }
        .onDisappear {
            stopAutoPolling()
        }
        .onReceive(viewModel.$trip) { trip in
            if let trip = trip, let newBusCoordinate = viewModel.getCurrentLocation() {
                updateBusCoordinate(newBusCoordinate)
            }
        }
        // Observe changes to autoPollEnabled
        .onChange(of: autoPollEnabled) { newValue in
            if newValue {
                Log.shared.info("Auto polling enabled.")
                startAutoPolling()
            } else {
                Log.shared.info("Auto polling disabled.")
                stopAutoPolling()
            }
        }
    }

    // Adjust the map's zoom level based on the slider value
    func updateMapZoom() {
        withAnimation(.easeInOut(duration: 1.0)) {
            mapRegion.span = MKCoordinateSpan(latitudeDelta: mapZoom, longitudeDelta: mapZoom)
        }
    }

    func setupMapForTrip() {
        if let busLocation = viewModel.getCurrentLocation() {
            Log.shared.info("Centering map on bus location: \(busLocation.latitude), \(busLocation.longitude)")
            busCoordinate = IdentifiableCoordinate(coordinate: busLocation)
            isProgrammaticRegionChange = true  // Set the flag
            withAnimation(.easeInOut(duration: 1.0)) {
                mapRegion.center = busLocation
                mapRegion.span = MKCoordinateSpan(latitudeDelta: mapZoom, longitudeDelta: mapZoom)
            }
        } else {
            Log.shared.error("Bus location is not available.")
        }
    }

    func updateBusCoordinate(_ newCoordinate: CLLocationCoordinate2D) {
        busCoordinate = IdentifiableCoordinate(coordinate: newCoordinate)
        if isCalloutVisible || !userHasMovedMap {
            setupMapForTrip()
        }
    }

    func startAutoPolling() {
        stopAutoPolling()  // Ensure any existing timer is canceled
        timer = Timer.publish(every: 10.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                viewModel.fetchTripData()
            }
    }

    func stopAutoPolling() {
        timer?.cancel()
        timer = nil
    }

    // Convert the zoom level (latitudeDelta) to distance in meters or kilometers
    func zoomLevelToDistance(_ zoomLevel: Double) -> String {
        let meters = zoomLevel * 111_000

        if meters >= 1000 {
            return String(format: "%.2f km", meters / 1000)
        } else {
            return String(format: "%.0f meters", meters)
        }
    }
}

// MARK: - IdentifiableCoordinate
struct IdentifiableCoordinate: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
