//
//  StopListView.swift
//  Ember Bus
//
//  Created by Stephen Clark on 22/09/2024.
//

import SwiftUI

struct StopListView: View {
    // MARK: - PROPERTIES
    let trip: Trip
    
    // Computed property to get upcoming stops
    var upcomingStops: [Route] {
        let now = Date()
        return trip.route.filter { routePoint in
            if let scheduledArrival = routePoint.arrival?.scheduled {
                return scheduledArrival >= now
            } else if let scheduledDeparture = routePoint.departure?.scheduled {
                return scheduledDeparture >= now
            } else {
                return false
            }
        }
    }
    
    // MARK: - VIEW BODY
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 16) {
                Text("Vehicle Information")
                    .font(.title2)
                    .padding(.bottom, 8)
                    .padding(.top, 8)
                    .padding(.leading, 8)
                
                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 10) {
                    // Wheelchair Places
                    GridRow {
                        Text("Wheelchair Places:")
                            .bold()
                        Text("\(trip.vehicle.wheelchair)")
                    }
                    
                    // Bike Places
                    GridRow {
                        Text("Bike Places:")
                            .bold()
                        Text("\(trip.vehicle.bicycle)")
                    }
                    
                    // Seats
                    GridRow {
                        Text("Seats:")
                            .bold()
                        Text("\(trip.vehicle.seat)")
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 15)
            .padding(.trailing, 15)
            .padding(.top, 15)
            
            if upcomingStops.isEmpty {
                Text("No upcoming stops.")
                    .foregroundColor(.gray)
                    .italic()
                    .padding()
            } else {
                
                List {
                    
                    Text("Stops").font(.title2)
                    
                    ForEach(upcomingStops) { routePoint in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(routePoint.location.name ?? "Unknown Stop")
                                .font(.headline)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Scheduled Arrival:")
                                    Text("Scheduled Departure:")
                                }
                                VStack(alignment: .leading) {
                                    Text(formatTime(routePoint.arrival?.scheduled))
                                    Text(formatTime(routePoint.departure?.scheduled))
                                }
                            }
                            .font(.subheadline)
                            
                            if let estimatedArrival = routePoint.arrival?.estimated {
                                HStack {
                                    Text("Estimated Arrival:")
                                    Text(formatTime(estimatedArrival))
                                        .foregroundColor(.orange)
                                }
                                .font(.subheadline)
                            }
                            
                            if let estimatedDeparture = routePoint.departure?.estimated {
                                HStack {
                                    Text("Estimated Departure:")
                                    Text(formatTime(estimatedDeparture))
                                        .foregroundColor(.orange)
                                }
                                .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .navigationTitle("Bus Stop Timings")
    }
    
    // MARK: - HELPER FUNCTIONS
    
    /// Helper function to format dates
    func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
