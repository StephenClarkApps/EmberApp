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

    init(trip: Trip, tripUuid: String) {
        _currentTripUuid = State(initialValue: tripUuid)

        // Initialize the bus coordinate based on the trip vehicle's GPS
        let initialBusCoordinate = CLLocationCoordinate2D(
            latitude: trip.vehicle.gps.latitude,
            longitude: trip.vehicle.gps.longitude
        )
        _busCoordinate = State(initialValue: initialBusCoordinate)

        // Initialize the map centered around the bus's current location
        _mapPosition = State(initialValue: .region(MKCoordinateRegion(
            center: initialBusCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )))
        _trip = State(initialValue: trip)
        
        Log.shared.info("BusMapView initialized. Initial Bus Coordinates: \(initialBusCoordinate.latitude), \(initialBusCoordinate.longitude)")
    }

    var body: some View {
        VStack {
            // Map with bus annotation
            Map(position: $mapPosition) {
                // Bus annotation with dynamic coordinate updates
                Annotation(trip.vehicle.name, coordinate: busCoordinate) {
                    BusAnnotationView(trip: trip, isCalloutVisible: $isCalloutVisible)
                        .onTapGesture {
                            // Show the callout when the bus is tapped
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
                // Detect user map movement and dismiss the callout
                if userHasMovedMap {
                    Log.shared.info("User moved the map. Dismissing callout.")
                    isCalloutVisible = false  // Dismiss the callout
                } else {
                    Log.shared.info("User initiated map move. Tracking.")
                    userHasMovedMap = true  // Mark that the user moved the map
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

    func setupMapForTrip() {
        // Log the centering event
        Log.shared.info("Centering map on bus location: \(busCoordinate.latitude), \(busCoordinate.longitude)")
        
        // Animate the map centering for smoother movement
        withAnimation(.easeInOut(duration: 1.0)) {
            mapPosition = .region(MKCoordinateRegion(
                center: busCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)  // Smaller delta for a more zoomed-in view
            ))
        }
    }


    // Fetch updated trip data and update the bus's location
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

                    // Check if callout is visible and move the annotation if necessary
                    if isCalloutVisible && previousBusCoordinate != newBusCoordinate {
                        Log.shared.info("Callout is visible, moving annotation to new location.")
                        self.busCoordinate = newBusCoordinate  // Move the bus annotation
                        setupMapForTrip()  // Re-center the map on the bus's new location
                    } else if !userHasMovedMap {
                        Log.shared.info("User hasn't moved the map. Re-centering.")
                        self.busCoordinate = newBusCoordinate
                        setupMapForTrip()
                    }

                    previousBusCoordinate = newBusCoordinate  // Track the bus's previous position
                    
                case .failure(let error):
                    Log.shared.error("Error fetching trip data: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
