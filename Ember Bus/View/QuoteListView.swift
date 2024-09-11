//
//  QuoteListView.swift
//  Ember Bus
//
//  Created by Stephen Clark on 11/09/2024.
//

import SwiftUI

struct QuotesListView: View {
    @StateObject private var quotesViewModel = QuotesViewModel()
    @State private var selectedTrip: Trip? // This will hold the fetched trip
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let quotes = quotesViewModel.quotes {
                List(quotes) { quote in
                    Button(action: {
                        // Fetch the trip data when a quote is selected
                        if let tripUid = quote.legs.first?.tripUid {
                            fetchTrip(tripUid: tripUid)
                        }
                    }) {
                        VStack(alignment: .leading) {
                            Text("Origin: \(quote.legs.first?.origin.name ?? "Origin")")
                            Text("Destination: \(quote.legs.first?.destination.name ?? "Destination")")

                            Text("Operator: \(quote.legs.first?.description.descriptionOperator ?? "Description")")
                            Text("Number Plate: \(quote.legs.first?.description.numberPlate ?? "No Plate")")
                            Text("Departure: \(quote.legs.first?.departure.scheduled?.description ?? Date().description)")
                            Text("Unique Trip Id: \(quote.legs.first?.tripUid ?? "")")
                        }
                    }
                }
            } else if let error = quotesViewModel.errorMessage {
                Text("Error: \(error)")
            } else {
                Text("Fetching quotes...")
            }
        }
        .onAppear {
            // Get the current date components for 7 AM on the current date
            let calendar = Calendar.current
            let now = Date()
            
            // Create the 7 AM date
            var startComponents = calendar.dateComponents([.year, .month, .day], from: now)
            startComponents.hour = 7
            startComponents.minute = 0
            let departureFrom = calendar.date(from: startComponents) ?? now
            
            // Create the "2 hours after now" date, ensuring it's still within today
            var twoHoursLater = calendar.date(byAdding: .hour, value: 2, to: now) ?? now
            if !calendar.isDate(twoHoursLater, inSameDayAs: now) {
                // If the calculated time goes to the next day, set it to the end of today (23:59:59)
                var endComponents = calendar.dateComponents([.year, .month, .day], from: now)
                endComponents.hour = 23
                endComponents.minute = 59
                twoHoursLater = calendar.date(from: endComponents) ?? now
            }

            // Fetch quotes within this time range
            quotesViewModel.fetchQuotes(origin: 13, destination: 42, departureFrom: departureFrom, departureTo: twoHoursLater)
        }
        .sheet(item: $selectedTrip) { trip in
             Text("TEST")
            //TripView(trip: trip)
        }
    }

    // Fetch the trip from the API based on the tripUid
    func fetchTrip(tripUid: String) {
        APIManager.shared.fetchTrip(tripId: tripUid) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let trip):
                    self.selectedTrip = trip
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
