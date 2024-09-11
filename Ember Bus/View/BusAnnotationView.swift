//
//  BusAnnotationView.swift
//  Ember Bus
//
//  Created by Stephen Clark on 10/09/2024.
//

import CoreLocation
import SwiftUI

struct BusAnnotationView: View {
    var trip: Trip
    @Binding var isCalloutVisible: Bool  // Use Binding to control visibility from parent

    var body: some View {
        ZStack {
            // Bus Icon
            Button(action: {
                withAnimation {
                    isCalloutVisible.toggle()
                }
            }) {
                Image(systemName: "bus.fill")
                    .foregroundColor(.green)
                    .padding(5)
                    .background(Color(UIColor.systemBackground))  // Adapts to light/dark mode
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }

            // Callout View - Uses dynamic data from the Trip object
            if isCalloutVisible {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(trip.description.routeNumber) from \(trip.route.first?.location.name ?? "Unknown") to \(trip.route.last?.location.name ?? "Unknown")")
                        .font(.body)
                        .foregroundColor(Color.primary)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Last updated: \(trip.vehicle.gps.lastUpdated?.description ?? "")")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    Text("Next Stop: \(trip.route.last?.location.name ?? "Unknown")")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Text("Scheduled: \(trip.route.last?.departure?.scheduled ?? Date())")
                            .font(.footnote)
                            .foregroundColor(Color.primary)
                            .fontWeight(.semibold)
                        Text("On time")  // Placeholder
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.leading, 8)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))  // Adapts to light/dark mode
                .cornerRadius(12)
                .shadow(radius: 5)
                .frame(width: 280)
                .fixedSize(horizontal: false, vertical: true)
                .offset(y: -135)  // Position the callout above the bus icon
                .transition(.scale)  // Smooth appearance/disappearance
            }
        }
    }
}


//struct BusAnnotationView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Use a sample Trip for the preview
//        let sampleTrip = Trip(
//            route: [Route(id: 1, departure: TripArrival(scheduled: Date(), actual: nil, estimated: Date()), arrival: TripArrival(scheduled: Date(), actual: nil, estimated: Date()), location: Location(id: 1, type: "STOP_POINT", name: "Dundee", regionName: "Dundee", code: "DUN", codeDetail: "Greenmarket", detailedName: "Greenmarket", lon: -2.9747, lat: 56.4561, googlePlaceId: "ChIJqR8vVb5chkgRK2nyU6tGED0", atcoCode: "640014188", timezone: "Europe/London", zone: [], heading: 0, areaId: 13, direction: nil, localName: nil), allowBoarding: true, allowDropOff: false, bookingCutOffMins: 0, preBookedOnly: false, skipped: false, stopReplacement: nil)],
//            vehicle: Vehicle(bicycle: 0, wheelchair: 0, seat: 0, id: 1, plateNumber: "SG23 ORT", name: "Yutong Coach", hasWifi: true, hasToilet: true, type: "coach", brand: "Ember", colour: "Black", isBackupVehicle: false, ownerId: 1, gps: Gps(lastUpdated: Date(), longitude: -3.0, latitude: 56.0, heading: 0)),
//            description: Description(routeNumber: "E1", patternId: 1, calendarDate: "2024-09-11", type: "public", isCancelled: false, routeId: 1)
//        )
//        
//        BusAnnotationView(trip: sampleTrip, isCalloutVisible: false)
//            .previewLayout(.sizeThatFits)
//            .padding()
//            .background(Color.gray.opacity(0.2))
//    }
//}
