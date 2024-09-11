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
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchQuotes(origin: Int, destination: Int, departureFrom: Date, departureTo: Date) {
        APIManager.shared.fetchQuotes(origin: origin, destination: destination, departureFrom: departureFrom, departureTo: departureTo) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let quotesResponse):
                    self.quotes = quotesResponse.quotes
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
