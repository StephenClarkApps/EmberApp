//
//  APIServiceProtocol.swift
//  Ember Bus
//
//  Created by Stephen Clark on 23/09/2024.
//

import Foundation
import Combine

protocol APIServiceProtocol {
    func fetchQuotes(origin: Int, destination: Int, departureFrom: Date, departureTo: Date) -> AnyPublisher<QuotesResponse, APIError>
    func fetchTrip(tripId: String) -> AnyPublisher<Trip, APIError>
}
