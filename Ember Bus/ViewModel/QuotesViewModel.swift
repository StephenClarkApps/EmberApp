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
    
    func fetchQuotes(origin: Int, destination: Int, departureFrom: Date, departureTo: Date) {
        let urlString = "https://api.ember.to/v1/quotes/?origin=\(origin)&destination=\(destination)&departure_date_from=\(departureFrom)&departure_date_to=\(departureTo)"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data returned"
                }
                return
            }
            
            do {
                let decodedQuotes = try JSONDecoder().decode([Quote].self, from: data)
                DispatchQueue.main.async {
                    self.quotes = decodedQuotes
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
}
