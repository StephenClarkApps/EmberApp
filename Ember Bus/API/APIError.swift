//
//  APIError.swift
//  Ember Bus
//
//  Created by Stephen Clark on 23/09/2024.
//

import Foundation

// MARK: - APIError
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case clientError(Int)
    case serverError(Int)
    case unexpectedStatusCode(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL.", comment: "")
        case .invalidResponse:
            return NSLocalizedString("Invalid response from the server.", comment: "")
        case .networkError(let error):
            return NSLocalizedString("Network error: \(error.localizedDescription)", comment: "")
        case .decodingError(let error):
            return NSLocalizedString("Decoding error: \(error.localizedDescription)", comment: "")
        case .clientError(let statusCode):
            return NSLocalizedString("Client error with status code \(statusCode).", comment: "")
        case .serverError(let statusCode):
            return NSLocalizedString("Server error with status code \(statusCode).", comment: "")
        case .unexpectedStatusCode(let statusCode):
            return NSLocalizedString("Unexpected status code \(statusCode).", comment: "")
        }
    }
}
