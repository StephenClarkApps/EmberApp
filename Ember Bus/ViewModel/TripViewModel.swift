//
//  TripViewModel.swift
//  Ember Bus
//
//  Created by Stephen Clark on 11/09/2024.
//

import Foundation
import Combine
import CoreLocation

class TripViewModel: ObservableObject {
    // MARK: - PROPERTIES
    @Published var trip: Trip?
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: APIServiceProtocol
    private let tripId: String
    
    init(tripId: String, apiService: APIServiceProtocol = APIManager.shared) {
        self.tripId = tripId
        self.apiService = apiService
        fetchTripData()
    }
    
    func fetchTripData() {
        apiService.fetchTrip(tripId: tripId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    Log.shared.error("Failed to fetch trip data: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] trip in
                self?.trip = trip
                Log.shared.info("Trip data fetched successfully.")
            })
            .store(in: &cancellables)
    }
    
    // 1. Current Location
    func getCurrentLocation() -> CLLocationCoordinate2D? {
        guard let gps = trip?.vehicle.gps else {
            Log.shared.error("GPS data not available.")
            return nil
        }
        return CLLocationCoordinate2D(latitude: gps.latitude, longitude: gps.longitude)
    }

    // 2. Get Route Stops for Map Annotations
    func getRouteStops() -> [IdentifiableCoordinate] {
        return trip?.route.compactMap { stop in
            if let lat = stop.location.lat, let lon = stop.location.lon {
                return IdentifiableCoordinate(id: stop.location.name ?? "-", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
            return nil
        } ?? []
    }

    
    // 2. Stop Times
    func getStopTimes() -> [(location: String, scheduled: Date?, estimated: Date?)] {
        return trip?.route.map { stop in
            (location: stop.location.name ?? "Unknown Location",
             scheduled: stop.arrival?.scheduled,
             estimated: stop.arrival?.estimated)
        } ?? []
    }

    /// getNextStop() method to return the next upcoming stop
    func getNextStop() -> (location: String, estimatedArrival: Date?, scheduledArrival: Date?)? {
        let currentDate = Date()
        
        // Filter to find the next unskipped stop, based on estimated times
        return trip?.route.first { stop in
            // Skip any stops that are marked as skipped
            guard stop.skipped == false else { return false }
            
            // Check estimated time if available, otherwise fall back to scheduled
            if let estimatedArrival = stop.arrival?.estimated {
                return estimatedArrival > currentDate
            } else if let scheduledArrival = stop.arrival?.scheduled {
                return scheduledArrival > currentDate
            }
            return false
        }.map { stop in
            // Return the next stop information
            (location: stop.location.name ?? "Unknown Location",
             estimatedArrival: stop.arrival?.estimated,
             scheduledArrival: stop.arrival?.scheduled)
        }
    }

    // 3. Next Stop Information
    struct NextStopInfo {
        let scheduledArrivalTime: String
        let estimatedArrivalTime: String
        let locationName: String
        let isRunningLate: Bool
    }

    func getNextStopInfo() -> NextStopInfo? {
        guard let nextStop = getNextStop() else { return nil }
        let scheduledArrivalTime = nextStop.scheduledArrival?.formattedTime() ?? "Unknown"
        let estimatedArrivalTime = nextStop.estimatedArrival?.formattedTime() ?? "Unknown"
        let locationName = nextStop.location
        let isRunningLate: Bool
        if let scheduled = nextStop.scheduledArrival, let estimated = nextStop.estimatedArrival {
            isRunningLate = estimated.timeIntervalSince(scheduled) > 120
        } else {
            isRunningLate = false
        }

        return NextStopInfo(
            scheduledArrivalTime: scheduledArrivalTime,
            estimatedArrivalTime: estimatedArrivalTime,
            locationName: locationName,
            isRunningLate: isRunningLate
        )
    }

    // 4. Availability
    func getAvailability() -> (seats: Int, wheelchairs: Int, bicycles: Int) {
        return (seats: trip?.vehicle.seat ?? 0,
                wheelchairs: trip?.vehicle.wheelchair ?? 0,
                bicycles: trip?.vehicle.bicycle ?? 0)
    }
    
    // 5. Route Disruptions
    func hasRouteDisruptions() -> Bool {
        guard let theTrip = trip else { return false }
        return theTrip.route.contains { stop in stop.skipped }
    }
    
    // 6. Last Known Location
    func getLastKnownLocation() -> CLLocationCoordinate2D? {
        guard let gps = trip?.vehicle.gps, gps.lastUpdated != nil else { return nil }
        return CLLocationCoordinate2D(latitude: gps.latitude, longitude: gps.longitude)
    }
    
    // 7. Stop & Bus Details
    func getStopDetails(for stopId: Int) -> Route? {
        return trip?.route.first { $0.id == stopId }
    }
    
    func getBusDetails() -> Vehicle? {
        return trip?.vehicle
    }

    // Time Status
    enum TimeStatus {
        case onTime
        case runningLate
        case unknown
    }

    var timeStatus: TimeStatus {
        guard let scheduled = trip?.route.last?.arrival?.scheduled,
              let estimated = trip?.route.last?.arrival?.estimated else {
            return .unknown
        }
        let difference = estimated.timeIntervalSince(scheduled)
        return difference > 120 ? .runningLate : .onTime
    }

    // Route Information
    func getRouteInfo() -> (departureTime: String, fromLocation: String, toLocation: String)? {
        guard let trip = trip else {
            Log.shared.error("Trip data not available.")
            return nil
        }

        // Filter out skipped stops
        let activeRoutes = trip.route.filter { !$0.skipped }
        Log.shared.debug("Active routes count: \(activeRoutes.count)")

        // Find the origin stop: first stop where allowBoarding == true
        let originStop = activeRoutes.first(where: { $0.allowBoarding })
        Log.shared.debug("Origin stop: \(originStop?.location.name ?? "Unknown")")

        // Find the destination stop: last stop where allowDropOff == true
        let destinationStop = activeRoutes.last(where: { $0.allowDropOff })
        Log.shared.debug("Destination stop: \(destinationStop?.location.name ?? "Unknown")")

        // Check if originStop and destinationStop are available
        guard let origin = originStop, let destination = destinationStop else {
            Log.shared.error("Origin or destination stop not available.")
            return nil
        }

        let departureTime = origin.departure?.scheduled?.formattedTime() ?? "Unknown"
        let fromLocation = origin.location.name ?? "Unknown"
        let toLocation = destination.location.name ?? "Unknown"

        Log.shared.debug("Departure Time: \(departureTime)")
        Log.shared.debug("From Location: \(fromLocation)")
        Log.shared.debug("To Location: \(toLocation)")

        return (departureTime: departureTime, fromLocation: fromLocation, toLocation: toLocation)
    }

}
