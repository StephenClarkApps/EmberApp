//
//  BusMapView.swift
//  Ember Bus
//
//  Created by Stephen Clark on 10/09/2024.
//

import SwiftUI
import MapKit

// Temporary placeholder Bus object
struct Bus: Identifiable {
    let id: Int
    let name: String
    var coordinate: CLLocationCoordinate2D
    let lastUpdated: Date
}


// MARK: - Bus Map View
struct BusMapView: View {
    @State private var mapPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 56.4561, longitude: -2.9747),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    
    @State private var buses = [
        Bus(id: 1, name: "Bus 101", coordinate: CLLocationCoordinate2D(latitude: 56.4561, longitude: -2.9747), lastUpdated: Date()),
        Bus(id: 2, name: "Bus 102", coordinate: CLLocationCoordinate2D(latitude: 56.4565, longitude: -2.9747), lastUpdated: Date())
    ]
    
    // To control when to hide the callout views
    @State private var selectedBus: Bus? = nil
    
    var body: some View {
        Map(position: $mapPosition) {
            ForEach(buses) { bus in
                Annotation(bus.name, coordinate: bus.coordinate) {
                    BusAnnotationView(bus: bus)
                        .onTapGesture {
                            selectedBus = bus
                        }
                }
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .onChange(of: mapPosition) { newValue in
            // Dismiss callout when the map moves
            selectedBus = nil
        }
        .onAppear {
            // Start live location updates
            
        } //: MAP
    }
}

struct BusMapView_Previews: PreviewProvider {
    static var previews: some View {
        BusMapView()
    }
}
