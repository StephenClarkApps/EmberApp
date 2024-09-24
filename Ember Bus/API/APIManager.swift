//
//  APIManager.swift
//  Ember Bus
//
//  Created by Stephen Clark on 10/09/2024.
//

import Foundation
import Combine

class APIManager: APIServiceProtocol {
    static let shared = APIManager()
    private let baseURL = EBConstants.baseURL
    private let session: URLSession
    
    // MARK: - Initializer
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Fetch Quotes
    func fetchQuotes(origin: Int, destination: Int, departureFrom: Date, departureTo: Date) -> AnyPublisher<QuotesResponse, APIError> {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let departureFromString = isoFormatter.string(from: departureFrom)
        let departureToString = isoFormatter.string(from: departureTo)
        
        var components = URLComponents(string: "\(baseURL)\(EBConstants.Endpoints.quotes)")!
        components.queryItems = [
            URLQueryItem(name: "origin", value: "\(origin)"),
            URLQueryItem(name: "destination", value: "\(destination)"),
            URLQueryItem(name: "departure_date_from", value: departureFromString),
            URLQueryItem(name: "departure_date_to", value: departureToString)
        ]
        
        guard let url = components.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .mapError { APIError.networkError($0) }
            .flatMap(maxPublishers: .max(1)) { output in
                self.handleResponse(output)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Fetch Trip
    func fetchTrip(tripId: String) -> AnyPublisher<Trip, APIError> {
        let urlStr = "\(baseURL)\(EBConstants.Endpoints.trips)\(tripId)/"
        
        guard let url = URL(string: urlStr) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .mapError { APIError.networkError($0) }
            .flatMap(maxPublishers: .max(1)) { output in
                self.handleResponse(output)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Response Handling
    private func handleResponse<T: Decodable>(_ output: URLSession.DataTaskPublisher.Output) -> AnyPublisher<T, APIError> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .customISO8601
        
        guard let response = output.response as? HTTPURLResponse else {
            return Fail(error: APIError.invalidResponse).eraseToAnyPublisher()
        }
        
        switch response.statusCode {
        case 200...299:
            return Just(output.data)
                .decode(type: T.self, decoder: decoder)
                .mapError { APIError.decodingError($0) }
                .eraseToAnyPublisher()
        case 400...499:
            return Fail(error: APIError.clientError(response.statusCode)).eraseToAnyPublisher()
        case 500...599:
            return Fail(error: APIError.serverError(response.statusCode)).eraseToAnyPublisher()
        default:
            return Fail(error: APIError.unexpectedStatusCode(response.statusCode)).eraseToAnyPublisher()
        }
    }
}

// MARK: - Custom Date Decoding Strategy
extension JSONDecoder.DateDecodingStrategy {
    static var customISO8601: JSONDecoder.DateDecodingStrategy {
        return .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withColonSeparatorInTimeZone]
            
            if let date = isoFormatter.date(from: dateString) {
                return date
            } else {
                isoFormatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]
                if let date = isoFormatter.date(from: dateString) {
                    return date
                } else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
                }
            }
        }
    }
}
