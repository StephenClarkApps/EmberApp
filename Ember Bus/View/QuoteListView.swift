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
            let departureFrom = getStartOfDayTime(for: 7)
            let departureTo = getTwoHoursAfterNowOrEndOfDay()
            quotesViewModel.fetchQuotes(origin: 13, destination: 42, departureFrom: departureFrom, departureTo: departureTo)
        }
        .alert(item: $selectedTrip) { trip in
            Alert(
                title: Text("Trip Fetched"),
                message: Text("Trip for vehicle: \(trip.vehicle.name)"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // Helper function to get the start of day time (7 AM)
    func getStartOfDayTime(for hour: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = 0
        return calendar.date(from: components) ?? now
    }

    // Helper function to calculate two hours after the current time
    func getTwoHoursAfterNowOrEndOfDay() -> Date {
        let calendar = Calendar.current
        let now = Date()
        var twoHoursLater = calendar.date(byAdding: .hour, value: 2, to: now) ?? now

        if !calendar.isDate(twoHoursLater, inSameDayAs: now) {
            var endOfDayComponents = calendar.dateComponents([.year, .month, .day], from: now)
            endOfDayComponents.hour = 23
            endOfDayComponents.minute = 59
            twoHoursLater = calendar.date(from: endOfDayComponents) ?? now
        }
        return twoHoursLater
    }

    // Fetch the trip from the API based on the tripUid
    func fetchTrip(tripUid: String) {
        APIManager.shared.fetchTrip(tripId: tripUid) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let trip):
                    print("Successfully fetched trip: \(trip)")
                    self.selectedTrip = trip
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Error fetching trip: \(error.localizedDescription)")
                }
            }
        }
    }

}
