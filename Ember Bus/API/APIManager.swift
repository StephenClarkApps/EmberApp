//
//  APIManager.swift
//  Ember Bus
//
//  Created by Stephen Clark on 10/09/2024.
//

import Foundation
import Combine

// MARK: - APIManager
class APIManager: APIServiceProtocol {
    static let shared = APIManager()
    private let baseURL: String
    private let session: URLSession

    // MARK: - Initializer
    init(session: URLSession = .shared, baseURL: String = EBConstants.baseURL) {
        self.session = session
        self.baseURL = baseURL
    }

    // MARK: - Fetch Quotes
    func fetchQuotes(origin: Int, destination: Int, departureFrom: Date, departureTo: Date) -> AnyPublisher<QuotesResponse, APIError> {
        // Configure Date Formatter
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let departureFromString = isoFormatter.string(from: departureFrom)
        let departureToString = isoFormatter.string(from: departureTo)
        
        // Construct URL Components Safely
        guard var components = URLComponents(string: "\(baseURL)\(EBConstants.Endpoints.quotes)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        components.queryItems = [
            URLQueryItem(name: "origin", value: "\(origin)"),
            URLQueryItem(name: "destination", value: "\(destination)"),
            URLQueryItem(name: "departure_date_from", value: departureFromString),
            URLQueryItem(name: "departure_date_to", value: departureToString)
        ]
        
        guard let url = components.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // Create URLRequest if needed (e.g., setting headers)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Add headers if required
        // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: request)
            .retry(3) // Retry logic with 3 attempts
            .mapError { APIError.networkError($0) }
            .flatMap { [weak self] output -> AnyPublisher<QuotesResponse, APIError> in
                guard let self = self else {
                    return Fail(error: APIError.unknown).eraseToAnyPublisher()
                }
                return self.handleResponse(output)
            }
            .receive(on: DispatchQueue.main) // Ensure updates on main thread
            .eraseToAnyPublisher()
    }
    
    // MARK: - Fetch Trip
    func fetchTrip(tripId: String) -> AnyPublisher<Trip, APIError> {
        let urlStr = "\(baseURL)\(EBConstants.Endpoints.trips)\(tripId)/"
        
        guard let url = URL(string: urlStr) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // Create URLRequest if needed
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Add headers if required
        
        return session.dataTaskPublisher(for: request)
            .retry(3) // Retry logic with 3 attempts
            .mapError { APIError.networkError($0) }
            .flatMap { [weak self] output -> AnyPublisher<Trip, APIError> in
                guard let self = self else {
                    return Fail(error: APIError.unknown).eraseToAnyPublisher()
                }
                return self.handleResponse(output)
            }
            .receive(on: DispatchQueue.main) // Ensure updates on main thread
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
            // Optionally decode API-specific error message
            return Fail(error: APIError.clientError(statusCode: response.statusCode)).eraseToAnyPublisher()
        case 500...599:
            return Fail(error: APIError.serverError(statusCode: response.statusCode)).eraseToAnyPublisher()
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
            
            // Static formatters to improve performance
            struct Formatter {
                static let iso8601WithFractionalSeconds: ISO8601DateFormatter = {
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withColonSeparatorInTimeZone]
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    return formatter
                }()
                
                static let iso8601: ISO8601DateFormatter = {
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    return formatter
                }()
            }
            
            if let date = Formatter.iso8601WithFractionalSeconds.date(from: dateString) {
                return date
            } else if let date = Formatter.iso8601.date(from: dateString) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }
        }
    }
}
