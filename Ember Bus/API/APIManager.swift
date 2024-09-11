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
    
    // Method for fetching quotes, previously added.
    func fetchQuotes(origin: Int, destination: Int, departureFrom: Date, departureTo: Date, completion: @escaping (Result<[Quote], Error>) -> Void) {
        let dateFormatter = ISO8601DateFormatter()
        let departureFromStr = dateFormatter.string(from: departureFrom)
        let departureToStr = dateFormatter.string(from: departureTo)
        
        let urlStr = "\(baseURL)/quotes/?origin=\(origin)&destination=\(destination)&departure_date_from=\(departureFromStr)&departure_date_to=\(departureToStr)"
        
        guard let url = URL(string: urlStr) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            do {
                let quotes = try JSONDecoder().decode([Quote].self, from: data)
                completion(.success(quotes))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // Method for fetching a specific trip
    func fetchTrip(tripId: String, completion: @escaping (Result<Trip, Error>) -> Void) {
        let urlStr = "\(baseURL)/trips/\(tripId)/"
        
        guard let url = URL(string: urlStr) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            do {
                let trip = try JSONDecoder().decode(Trip.self, from: data)
                completion(.success(trip))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
