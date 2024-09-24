//
//  QuoteListView.swift
//  Ember Bus
//
//  Created by Stephen Clark on 11/09/2024.
//

import SwiftUI

struct QuotesListView: View {
    @StateObject private var quotesViewModel = QuotesViewModel()
    @State private var showErrorToast: Bool = false
    @State private var toastMessage: String = ""

    var body: some View {
        NavigationView {
            VStack {
                if !quotesViewModel.isConnected {
                    Text("No internet connection. Please check your network settings.")
                        .foregroundColor(.red)
                        .padding()
                } else if quotesViewModel.isLoading && quotesViewModel.quotes == nil {
                    ProgressView("Loading...")
                } else if let quotes = quotesViewModel.quotes {
                    List(quotes) { quote in
                        Button(action: {
                            if let tripUid = quote.legs.first?.tripUid {
                                quotesViewModel.fetchTrip(for: tripUid)
                            }
                        }) {
                            QuoteRowView(quote: quote)
                        }
                    }
                    .refreshable {
                        quotesViewModel.fetchQuotes(for: 13, destination: 42)
                    }
                } else if let error = quotesViewModel.errorMessage, quotesViewModel.quotes == nil {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("Fetching quotes...")
                }
            }
            .navigationTitle("Trips")
            .onAppear {
                quotesViewModel.fetchQuotes(for: 13, destination: 42)
            }
            .background(
                NavigationLink(
                    destination: quotesViewModel.selectedTrip.map { trip in
                        BusMapView(tripId: quotesViewModel.selectedTripUid ?? "")
                    },
                    isActive: Binding<Bool>(
                        get: { quotesViewModel.selectedTrip != nil },
                        set: { newValue in
                            if !newValue {
                                quotesViewModel.selectedTrip = nil
                                quotesViewModel.selectedTripUid = nil
                            }
                        }
                    )
                ) {
                    EmptyView()
                }
            )
            // Overlay for Toast Messages
            .overlay(
                VStack {
                    Spacer()
                    if showErrorToast {
                        ToastView(
                            message: toastMessage,
                            icon: "exclamationmark.triangle.fill",
                            backgroundColor: .red,
                            isShowing: $showErrorToast              
                        )
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.5), value: showErrorToast) // Animate
            )

            // Observe errorMessage changes to show toast
            .onChange(of: quotesViewModel.errorMessage) { newError in
                if let error = newError {
                    toastMessage = error
                    withAnimation {
                        showErrorToast = true
                    }
                    // Hide the toast after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showErrorToast = false
                        }
                        // Optionally, clear the error message in ViewModel
                        quotesViewModel.errorMessage = nil
                    }
                }
            }
        }
    }
}


struct QuoteRowView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            if let leg = quote.legs.first {
                Text("\(leg.origin.name) -> \(leg.destination.name)")
                    .bold()
                    .padding(.bottom, 5)

                Grid(alignment: .leading, verticalSpacing: 8.0) {
                    GridRow {
                        Text("Number Plate:").bold()
                        Text("\(leg.description.numberPlate ?? "No Plate")")
                    }
                    GridRow {
                        Text("Departure:").bold()
                        Text("\(leg.departure.scheduled?.formattedTime() ?? "Unknown")")
                    }
                    GridRow {
                        Text("Arrival:").bold()
                        Text("\(leg.arrival.scheduled?.formattedTime() ?? "Unknown")")
                    }
                }
            } else {
                Text("No trip details available")
            }
        }
    }
}
