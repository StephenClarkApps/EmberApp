//
//  APIError.swift
//  Ember Bus
//
//  Created by Stephen Clark on 23/09/2024.
//

import Foundation

// MARK: - APIError
enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case clientError(statusCode: Int)
    case serverError(statusCode: Int)
    case unexpectedStatusCode(Int)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .networkError(let error):
            return error.localizedDescription
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .clientError(let statusCode):
            return "Client error with status code: \(statusCode)."
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)."
        case .unexpectedStatusCode(let statusCode):
            return "Unexpected status code: \(statusCode)."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
