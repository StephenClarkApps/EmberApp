//
//  QuotesViewModel.swift
//  Ember Bus
//
//  Created by Stephen Clark on 11/09/2024.
//

import Combine
import SwiftUI

class QuotesViewModel: ObservableObject {
    // Published properties
    @Published var quotes: [Quote]?
    @Published var errorMessage: String?
    @Published var selectedTrip: Trip?
    @Published var isLoading: Bool = false
    @Published var isConnected: Bool = true
    @Published var selectedTripUid: String?

    private var cancellables = Set<AnyCancellable>()
    private let networkMonitor: any NetworkMonitoring
    private let quoteService: QuoteServiceProtocol

    init(networkMonitor: any NetworkMonitoring = NetworkMonitor(), quoteService: QuoteServiceProtocol = QuoteService()) {
        self.networkMonitor = networkMonitor
        self.quoteService = quoteService

        // Observe network connectivity using the publisher
        networkMonitor.isConnectedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                self?.isConnected = connected
                if !connected {
                    self?.errorMessage = "No internet connection. Please check your network settings."
                }
            }
            .store(in: &cancellables)
    }

    // Fetch quotes for the given origin and destination
    func fetchQuotes(for origin: Int, destination: Int) {
        guard isConnected else {
            self.errorMessage = "No internet connection. Please check your network settings."
            return
        }

        isLoading = true
        let now = Date()
        let startOfToday = Date.startOfToday
        let endOfToday = Date.endOfToday

        quoteService.fetchQuotes(origin: origin, destination: destination, departureFrom: startOfToday, departureTo: endOfToday)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    // Do nothing
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] quotesResponse in
                self?.quotes = quotesResponse.quotes.filter { quote in
                    self?.isValidQuote(quote, currentDate: now) ?? false
                }
            })
            .store(in: &cancellables)
    }

    // Fetch trip details for the selected trip UID
    func fetchTrip(for tripUid: String) {
        guard isConnected else {
            self.errorMessage = "No internet connection. Please check your network settings."
            return
        }

        isLoading = true
        self.selectedTripUid = tripUid // Store the selected trip UUID
        quoteService.fetchTrip(tripId: tripUid)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    // Do nothing
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] trip in
                self?.selectedTrip = trip
            })
            .store(in: &cancellables)
    }

    // Validates if the quote is for today and hasn't already departed
    private func isValidQuote(_ quote: Quote, currentDate: Date = Date()) -> Bool {
        guard let firstLeg = quote.legs.first,
              let tripStart = firstLeg.departure.scheduled,
              let tripEnd = firstLeg.arrival.scheduled else { return false }

        return Calendar.current.isDate(tripStart, inSameDayAs: currentDate) && tripEnd >= currentDate
    }
}


