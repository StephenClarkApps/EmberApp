//
//  QuotesViewModel.swift
//  Ember Bus
//
//  Created by Stephen Clark on 11/09/2024.
//

import Combine
import SwiftUI

class QuotesViewModel: ObservableObject {
    @Published var quotes: [Quote]?
    @Published var errorMessage: String?
    @Published var selectedTrip: Trip? // Store selected trip
    @Published var isLoading: Bool = false // Loading state
    @Published var currentlySelectedUuid: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchQuotes(for origin: Int, destination: Int) {
        let departureFrom = getStartOfDayTime(for: 7)
        let departureTo = getTwoHoursAfterNowOrEndOfDay()

        isLoading = true
        APIManager.shared.fetchQuotes(origin: origin, destination: destination, departureFrom: departureFrom, departureTo: departureTo) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let quotesResponse):
                    self.quotes = quotesResponse.quotes
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchTrip(for tripUid: String) {
        self.currentlySelectedUuid = tripUid
        isLoading = true
        APIManager.shared.fetchTrip(tripId: tripUid) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let trip):
                    self.selectedTrip = trip
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // Move helper functions here from the view
    private func getStartOfDayTime(for hour: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = 0
        return calendar.date(from: components) ?? now
    }

    private func getTwoHoursAfterNowOrEndOfDay() -> Date {
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
}
