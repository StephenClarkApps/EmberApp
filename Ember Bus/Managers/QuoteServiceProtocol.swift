//
//  QuoteServiceProtocol.swift
//  Ember Bus
//
//  Created by Stephen Clark on 24/09/2024.
//

import Foundation
import Combine

// MARK: - QuoteServiceProtocol
protocol QuoteServiceProtocol {
    func fetchQuotes(origin: Int, destination: Int, departureFrom: Date, departureTo: Date) -> AnyPublisher<QuotesResponse, APIError>
    func fetchTrip(tripId: String) -> AnyPublisher<Trip, APIError>
}
