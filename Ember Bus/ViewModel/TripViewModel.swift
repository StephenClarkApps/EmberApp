//
//  TripViewModel.swift
//  Ember Bus
//
//  Created by Stephen Clark on 11/09/2024.
//

import Foundation
import Combine

class TripViewModel: ObservableObject {
    @Published var trip: Trip?
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func getTrip(tripId: String) {
        APIManager.shared.fetchTrip(tripId: tripId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let trip):
                    self?.trip = trip
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
