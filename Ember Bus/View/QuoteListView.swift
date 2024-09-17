//
//  QuoteListView.swift
//  Ember Bus
//
//  Created by Stephen Clark on 11/09/2024.
//

import SwiftUI

struct QuotesListView: View {
    @StateObject private var quotesViewModel = QuotesViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if quotesViewModel.isLoading {
                    ProgressView("Loading...")
                } else if let quotes = quotesViewModel.quotes {
                    List(quotes) { quote in
                        Button(action: {
                            if let tripUid = quote.legs.first?.tripUid {
                                quotesViewModel.fetchTrip(for: tripUid)
                            }
                        }) {
                            VStack(alignment: .leading) {
                                Text("\(quote.legs.first?.origin.name ?? "Origin") -> \(quote.legs.first?.destination.name ?? "Destination")").bold()
                                Text("Number Plate: \(quote.legs.first?.description.numberPlate ?? "No Plate")")
                                Text("Departure: \(quote.legs.first?.departure.scheduled?.description ?? Date().description)")
                                Text("Arrival: \(quote.legs.first?.arrival.scheduled?.description ?? Date().description)")
//                                Text("Unique Trip Id: \(quote.legs.first?.tripUid ?? "")")
                            }
                        }
                    }
                } else if let error = quotesViewModel.errorMessage {
                    Text("Error: \(error)")
                } else {
                    Text("Fetching quotes...")
                }
            }
            .navigationTitle("Trips")
            .onAppear {
                quotesViewModel.fetchQuotes(for: 13, destination: 42)
            }
            // NavigationLink with proper handling
            .background(
                NavigationLink(
                    destination: quotesViewModel.selectedTrip.map { trip in
                        BusMapView(trip: trip, tripUuid: quotesViewModel.currentlySelectedUuid ?? "")
                    },
                    isActive: Binding<Bool>(
                        get: { quotesViewModel.selectedTrip != nil },
                        set: { newValue in
                            if !newValue { quotesViewModel.selectedTrip = nil }
                        }
                    )
                ) {
                    EmptyView() // Placeholder to trigger the navigation
                }
            )

        }
    }
}
