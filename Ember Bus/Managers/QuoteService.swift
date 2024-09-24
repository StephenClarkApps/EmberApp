//
//  QuoteService.swift
//  Ember Bus
//
//  Created by Stephen Clark on 19/09/2024.
//


import Foundation
import Combine


// MARK: - QuoteService
class QuoteService: QuoteServiceProtocol {
    func fetchQuotes(origin: Int, destination: Int, departureFrom: Date, departureTo: Date) -> AnyPublisher<QuotesResponse, APIError> {
        return APIManager.shared.fetchQuotes(
            origin: origin,
            destination: destination,
            departureFrom: departureFrom,
            departureTo: departureTo
        )
    }

    func fetchTrip(tripId: String) -> AnyPublisher<Trip, APIError> {
        return APIManager.shared.fetchTrip(tripId: tripId)
    }
}

