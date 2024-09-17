//
//  BusMapView.swift
//  Ember Bus
//
//  Created by Stephen Clark on 10/09/2024.
//

import SwiftUI
import MapKit

struct BusMapView: View {
    @State private var mapPosition: MapCameraPosition
    @State private var trip: Trip
    @State private var currentTripUuid: String?
    @State private var busCoordinate: CLLocationCoordinate2D
    @State private var isCalloutVisible = false  // Track visibility for the bus callout
    @State private var userHasMovedMap = false  // Track user map movement
    @State private var previousBusCoordinate: CLLocationCoordinate2D?  // Track previous location of bus for comparison
    @State private var autoDismissCallout = true  // State to toggle automatic callout dismissal
    @State private var mapZoom: Double = 0.05  // New state for the zoom level

    init(trip: Trip, tripUuid: String) {
        _currentTripUuid = State(initialValue: tripUuid)

        let initialBusCoordinate = CLLocationCoordinate2D(
            latitude: trip.vehicle.gps.latitude,
            longitude: trip.vehicle.gps.longitude
        )
        _busCoordinate = State(initialValue: initialBusCoordinate)

        _mapPosition = State(initialValue: .region(MKCoordinateRegion(
            center: initialBusCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )))
        _trip = State(initialValue: trip)
        
        Log.shared.info("BusMapView initialized. Initial Bus Coordinates: \(initialBusCoordinate.latitude), \(initialBusCoordinate.longitude)")
    }

    var body: some View {
        VStack {
            // Toggle to enable/disable automatic callout dismissal
            Toggle("Auto Dismiss Callout", isOn: $autoDismissCallout)
                .padding()

            // Slider for controlling the map's zoom level
            VStack {
                // Convert zoom level to meters or kilometers for display
                let zoomDistance = zoomLevelToDistance(mapZoom)
                Text("Zoom Level: \(zoomDistance)")
                
                Slider(value: $mapZoom, in: 0.01...0.7, step: 0.03)  // Slider for zoom, with a range between 0.01 and 0.2
                    .padding()
                    .onChange(of: mapZoom) { newValue in
                        Log.shared.info("Zoom level adjusted to: \(newValue)")
                        updateMapZoom()
                    }
            }

            // Map with bus annotation
            Map(position: $mapPosition) {
                // Bus annotation with dynamic coordinate updates
                Annotation(trip.vehicle.name, coordinate: busCoordinate) {
                    BusAnnotationView(trip: trip, isCalloutVisible: $isCalloutVisible)
                        .onTapGesture {
                            Log.shared.info("Bus tapped. Showing callout.")
                            isCalloutVisible = true
                        }
                }

                // Route stop annotations
                ForEach(trip.route, id: \.id) { stop in
                    Annotation(stop.location.name ?? "", coordinate: CLLocationCoordinate2D(
                        latitude: stop.location.lat ?? 0.0,
                        longitude: stop.location.lon ?? 0.0
                    )) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle().stroke(Color.green, lineWidth: 2)
                            )
                    }
                }
            }
            .mapStyle(.standard)
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                Log.shared.info("onMapCameraChange triggered")
                
                if userHasMovedMap {
                    if autoDismissCallout {
                        Log.shared.info("User moved the map. Dismissing callout.")
                        isCalloutVisible = false
                    }
                } else {
                    Log.shared.info("User initiated map move. Tracking.")
                    userHasMovedMap = true
                }
            }

            // Refresh Button
            Button(action: {
                Log.shared.info("Refresh button tapped. Fetching updated trip data.")
                fetchUpdatedTripData()
            }) {
                Text("Refresh Trip Data")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            Log.shared.info("BusMapView appeared. Setting up map for the trip.")
            setupMapForTrip()
        }
    }

    // Adjust the map's zoom level based on the slider value
    func updateMapZoom() {
        withAnimation(.easeInOut(duration: 1.0)) {
            mapPosition = .region(MKCoordinateRegion(
                center: busCoordinate,
                span: MKCoordinateSpan(latitudeDelta: mapZoom, longitudeDelta: mapZoom)
            ))
        }
    }

    func setupMapForTrip() {
        Log.shared.info("Centering map on bus location: \(busCoordinate.latitude), \(busCoordinate.longitude)")
        withAnimation(.easeInOut(duration: 1.0)) {
            mapPosition = .region(MKCoordinateRegion(
                center: busCoordinate,
                span: MKCoordinateSpan(latitudeDelta: mapZoom, longitudeDelta: mapZoom)
            ))
        }
    }

    func fetchUpdatedTripData() {
        Log.shared.info("Fetching trip data for trip UUID: \(self.currentTripUuid ?? "unknown")")
        APIManager.shared.fetchTrip(tripId: self.currentTripUuid ?? "") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedTrip):
                    Log.shared.info("Trip data fetched successfully. Updating bus coordinates.")
                    self.trip = updatedTrip
                    
                    let newBusCoordinate = CLLocationCoordinate2D(
                        latitude: updatedTrip.vehicle.gps.latitude,
                        longitude: updatedTrip.vehicle.gps.longitude
                    )

                    if isCalloutVisible && previousBusCoordinate != newBusCoordinate {
                        Log.shared.info("Callout is visible, moving annotation to new location.")
                        self.busCoordinate = newBusCoordinate
                        setupMapForTrip()
                    } else if !userHasMovedMap {
                        Log.shared.info("User hasn't moved the map. Re-centering.")
                        self.busCoordinate = newBusCoordinate
                        setupMapForTrip()
                    }

                    previousBusCoordinate = newBusCoordinate
                    
                case .failure(let error):
                    Log.shared.error("Error fetching trip data: \(error.localizedDescription)")
                }
            }
        }
    }

    // Convert the zoom level (latitudeDelta) to distance in meters or kilometers
    func zoomLevelToDistance(_ zoomLevel: Double) -> String {
        // 1 degree of latitude is approximately 111 kilometers (111,000 meters)
        let meters = zoomLevel * 111_000
        
        if meters >= 1000 {
            return String(format: "%.2f km", meters / 1000)
        } else {
            return String(format: "%.0f meters", meters)
        }
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
