//
//  APIManager.swift
//  Ember Bus
//
//  Created by Stephen Clark on 10/09/2024.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    private let baseURL = "https://api.ember.to/v1"
    
    // Fetch Quotes with a completion handler
    func fetchQuotes(origin: Int, destination: Int, departureFrom: Date, departureTo: Date, completion: @escaping (Result<Quotes, Error>) -> Void) {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let departureFromString = isoFormatter.string(from: departureFrom)
        let departureToString = isoFormatter.string(from: departureTo)
        
        let urlStr = "\(baseURL)/quotes/?origin=\(origin)&destination=\(destination)&departure_date_from=\(departureFromString)&departure_date_to=\(departureToString)"
        
        guard let url = URL(string: urlStr) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let quotesResponse = try decoder.decode(Quotes.self, from: data)
                completion(.success(quotesResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // Fetch Trip
    func fetchTrip(tripId: String, completion: @escaping (Result<Trip, Error>) -> Void) {
        let urlStr = "\(baseURL)/trips/\(tripId)/"  // There seems to be a forward slash at the end of the tripId for some unknown reason
        
        guard let url = URL(string: urlStr) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601  
                let trip = try decoder.decode(Trip.self, from: data)
                completion(.success(trip))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
