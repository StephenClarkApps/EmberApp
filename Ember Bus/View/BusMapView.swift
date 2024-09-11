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
    @State private var trip: Trip  // Trip object passed in
    @State private var currentTripUuid: String?
    @State private var selectedBusLocation: CLLocationCoordinate2D?  // For showing bus callout
    
    init(trip: Trip, tripUuid: String) {
        _currentTripUuid = State(initialValue: tripUuid)
        
        // Initialize the map centered around the bus's current location or the first stop
        let busLocation = CLLocationCoordinate2D(
            latitude: trip.vehicle.gps.latitude,
            longitude: trip.vehicle.gps.longitude
        )
        _mapPosition = State(initialValue: .region(MKCoordinateRegion(
            center: busLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )))
        _trip = State(initialValue: trip)
    }
    
    var body: some View {
        VStack {
            // Map with bus and route annotations
            Map(position: $mapPosition) {
                // Bus annotation with callout using Annotation
                let busCoordinate = CLLocationCoordinate2D(latitude: trip.vehicle.gps.latitude, longitude: trip.vehicle.gps.longitude)
                
                Annotation(trip.vehicle.name, coordinate: busCoordinate) {
                    BusAnnotationView(trip: trip)
                        .onTapGesture {
                            selectedBusLocation = busCoordinate
                        }
                }

                // Generic route stop annotations without callout
                ForEach(trip.route, id: \.id) { stop in
                    Annotation(stop.location.name ?? "", coordinate: CLLocationCoordinate2D(
                        latitude: stop.location.lat ?? 0.0,
                        longitude: stop.location.lon ?? 0.0
                    )) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .mapStyle(.standard)
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            
            // Refresh Button
            Button(action: {
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
            setupMapForTrip()
        }
    }
    
    func setupMapForTrip() {
        let busCoordinate = CLLocationCoordinate2D(latitude: trip.vehicle.gps.latitude, longitude: trip.vehicle.gps.longitude)
        mapPosition = .region(MKCoordinateRegion(
            center: busCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    func fetchUpdatedTripData() {
        APIManager.shared.fetchTrip(tripId: self.currentTripUuid ?? "") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedTrip):
                    self.trip = updatedTrip
                    setupMapForTrip()
                case .failure(let error):
                    print("Error fetching trip data: \(error.localizedDescription)")
                }
            }
        }
    }
}
