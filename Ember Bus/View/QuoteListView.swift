//
//  QuoteListView.swift
//  Ember Bus
//
//  Created by Stephen Clark on 11/09/2024.
//

import SwiftUI

struct QuotesListView: View {
        
    // MARK: - PROPERTIES
    @StateObject private var quotesViewModel = QuotesViewModel()
    @State private var showErrorToast: Bool = false
    @State private var toastMessage: String = ""

    // MARK: - VIEW BODY
    var body: some View {
        NavigationView {
            VStack {
                // Display a message when there's no internet connection
                if !quotesViewModel.isConnected {
                    Text("No internet connection. Please check your network settings.")
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center) // Ensures text wraps nicely
                }
                // Show a loading indicator while fetching data
                else if quotesViewModel.isLoading && quotesViewModel.quotes == nil {
                    ProgressView("Loading...")
                }
                // Display the list of quotes when data is available
                else if let quotes = quotesViewModel.quotes {
                    List(quotes) { quote in
                        Button(action: {
                            // Fetch trip details when a quote is tapped
                            if let tripUid = quote.legs.first?.tripUid {
                                quotesViewModel.fetchTrip(for: tripUid)
                            }
                        }) {
                            QuoteRowView(quote: quote)
                                .frame(maxWidth: .infinity, alignment: .leading) // Make the entire row tappable
                                .contentShape(Rectangle()) // Ensure the full cell area is tappable
                        }
                        .buttonStyle(PlainButtonStyle()) // Remove default button styling for a cleaner look
                    }
                    .refreshable {
                        // Allows users to pull-to-refresh the list
                        quotesViewModel.fetchQuotes(for: 13, destination: 42)
                    }
                }
                // Show an error message if fetching quotes fails
                else if let error = quotesViewModel.errorMessage, quotesViewModel.quotes == nil {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                }
                // Fallback message for unexpected states
                else {
                    Text("Fetching quotes...")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .navigationTitle("Trips")
            .onAppear {
                // Fetch quotes when the view appears
                quotesViewModel.fetchQuotes(for: 13, destination: 42)
            }
            .background(
                // Hidden NavigationLink to navigate to BusMapView when a trip is selected
                NavigationLink(
                    destination: quotesViewModel.selectedTrip.map { trip in
                        // Ensure tripId is non-optional; provide a default or handle nil appropriately
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
            // Overlay for displaying toast messages
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
                .padding(), // Adds padding to prevent the toast from touching screen edges
                alignment: .bottom
            )
            // Animate the appearance and disappearance of the toast
            .animation(.easeInOut(duration: 0.5), value: showErrorToast)
            // Observe changes to errorMessage to trigger the toast
            .onChange(of: quotesViewModel.errorMessage) { newError in
                if let error = newError {
                    toastMessage = error
                    withAnimation {
                        showErrorToast = true
                    }
                    // Automatically hide the toast after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showErrorToast = false
                        }
                        // Optionally, clear the error message in ViewModel to prevent repeated toasts
                        quotesViewModel.errorMessage = nil
                    }
                }
            }
        }
    }
}

// MARK: - QUOTE ROW VIEW
struct QuoteRowView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            if let leg = quote.legs.first {
                // Display origin and destination in a bold font
                Text("\(leg.origin.name) -> \(leg.destination.name)")
                    .bold()
                    .padding(.bottom, 5)

                // Use a Grid for structured information display
                Grid(alignment: .leading, verticalSpacing: 8.0) {
                    GridRow {
                        Text("Number Plate:").bold()
                        Text("\(leg.description.numberPlate)")
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
                .font(.subheadline) // Adjust font for better hierarchy
            } else {
                // Inform the user if trip details are unavailable
                Text("No trip details available")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8) // Adds vertical padding for better spacing
    }
}

// MARK: - PREVIEW PROVIDER
struct QuotesListView_Previews: PreviewProvider {
    static var previews: some View {
        // Providing a mock ViewModel with sample data for the preview
        QuotesListView()
            .environmentObject(QuotesViewModel())
            .previewDevice("iPhone 14")
    }
}
