//
//  QuoteListView.swift
//  Ember Bus
//
//  Created by Stephen Clark on 11/09/2024.
//

import SwiftUI

struct QuotesListView: View {
    @StateObject private var quotesViewModel = QuotesViewModel() // Updated to use @StateObject for ViewModel
    @State private var selectedQuote: Quote? // Make sure this matches the Identifiable requirement
    
    var body: some View {
        VStack {
            if let quotes = quotesViewModel.quotes {
                List(quotes) { quote in // Use the Identifiable conformance
                    Button(action: {
                        selectedQuote = quote
                    }) {
                        VStack(alignment: .leading) {
                            Text("Bus: \(quote.legs[0].tripUid)")
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
            // Fetch the quotes when the view appears
            quotesViewModel.fetchQuotes(origin: 13, destination: 42, departureFrom: Date(), departureTo: Date().addingTimeInterval(3600))
        }
        .sheet(item: $selectedQuote) { quote in
           // TripView(tripId: quote.id) // Once a quote is selected, show the TripView for the quote
        }
    }
}

