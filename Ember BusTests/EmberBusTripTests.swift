//
//  EmberBusTripTests.swift
//  Ember BusTests
//
//  Created by Stephen Clark on 10/09/2024.
//

import XCTest
@testable import Ember_Bus

final class EmberBusTripTests: XCTestCase {

    private var trip: Trip!

    override func setUpWithError() throws {
        // Given: Load the trip data from the JSON file
        guard let url = Bundle(for: type(of: self)).url(forResource: "ExampleTrip", withExtension: "json") else {
            XCTFail("Missing file: ExampleTrip.json")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            self.trip = try decoder.decode(Trip.self, from: data)
        } catch {
            XCTFail("Failed to decode Trip JSON: \(error.localizedDescription)")
        }
    }

    override func tearDownWithError() throws {
        // Cleanup after each test
        trip = nil
    }
    
    // MARK: - User Story 1: Display a Bus’s Current Location
    func test_whenWeGetTrip_WeGetBusCurrentLocation() {
        // Given: A decoded trip object

        // When: Accessing the vehicle GPS location
        let gps = trip.vehicle.gps

        // Then: Assert that the GPS location is correct
        XCTAssertEqual(gps.latitude, 56.48389, "Expected bus latitude to be 56.48389")
        XCTAssertEqual(gps.longitude, -2.89383, "Expected bus longitude to be -2.89383")
        XCTAssertEqual(gps.heading, 20, "Expected bus heading to be 20 degrees")
    }

    // MARK: - User Story 2: Display Scheduled & Estimated Times at Each Stop
    func test_whenWeGetTrip_weGetScheduledAndEstimatedTimesAtEachStop() {
        // Given: A decoded trip object

        // When: Accessing the first route segment
        guard let firstRoute = trip.route.first else {
            XCTFail("No route data available to test")
            return
        }

        // Then: Verify scheduled and estimated times for the first stop
        XCTAssertEqual(firstRoute.departure?.scheduled ?? Date(), ISO8601DateFormatter().date(from: "2024-09-10T11:40:00+00:00"), "Expected scheduled departure time")
        XCTAssertEqual(firstRoute.arrival?.estimated ?? Date(), ISO8601DateFormatter().date(from: "2024-09-10T11:40:00+00:00"), "Expected estimated arrival time")
    }

    // MARK: - User Story 3: Highlight the Next Stop and ETA
    func test_whenWeGetTrip_weGetTheNextStopAndETA() {
        // Given: A decoded trip object

        // When: Accessing the second route segment (assuming it's the next stop after the first)
        guard trip.route.count > 1 else {
            XCTFail("Not enough route data to test next stop")
            return
        }
        let nextStop = trip.route[1]

        // Then: Verify the next stop and its estimated arrival time
        XCTAssertEqual(nextStop.location.name, "Dundee West", "Expected next stop to be Dundee West")
        XCTAssertEqual(nextStop.arrival?.estimated ?? Date(), ISO8601DateFormatter().date(from: "2024-09-10T11:54:27+00:00"), "Expected estimated arrival time for next stop")
    }

    // MARK: - User Story 4: Show Seat, Wheelchair, and Bicycle Availability
    func test_whenWeGetTrip_weGetAvailabilities() {
        // Given: A decoded trip object

        // When: Accessing vehicle information
        let vehicle = trip.vehicle

        // Then: Verify seat, wheelchair, and bicycle availability
        XCTAssertEqual(vehicle.seat, 40, "Expected 40 seats available on the bus")
        XCTAssertEqual(vehicle.wheelchair, 1, "Expected 1 wheelchair space available on the bus")
        XCTAssertEqual(vehicle.bicycle, 2, "Expected 2 bicycle spaces available on the bus")
    }

    // MARK: - User Story 5: Notify About Route Disruptions or Changes
    func test_whenWeGetTrip_WeGetInfoOnRouteChanges() {
        // Given: A decoded trip object

        // When: Accessing the stop replacement for the last stop (if any)
        guard let lastRoute = trip.route.last else {
            XCTFail("No route data available to test")
            return
        }

        if let stopReplacement = lastRoute.stopReplacement {
            // Then: Verify that there are route changes due to disruptions
            XCTAssertFalse(stopReplacement.isCancelled, "The stop should not be cancelled")
            XCTAssertEqual(stopReplacement.description, "Due to a road closure your service will call at George Street instead of St Andrew Square. We're sorry for any inconvenience.", 
                           "Expected route disruption notice")
        }
    }

    // MARK: - User Story 7: Tap for More Information on Bus or Stop
    func test_whenWeGetTrip_WeGetMoreInfo() {
        // Given: A decoded trip object

        // When: Accessing vehicle and stop details
        guard let firstRoute = trip.route.first else {
            XCTFail("No route data available to test")
            return
        }
        let vehicle = trip.vehicle

        // Then: Verify the bus and stop information
        XCTAssertEqual(vehicle.brand, "Ember", "Expected bus brand to be Ember")
        XCTAssertEqual(vehicle.plateNumber, "SG72 NCA", "Expected bus plate number to be SG72 NCA")
        XCTAssertEqual(firstRoute.location.name, "Dundee Greenmarket", "Expected first stop to be Dundee Greenmarket")
        XCTAssertEqual(firstRoute.location.googlePlaceId, "ChIJqR8vVb5chkgRK2nyU6tGED0", "Expected Google Place ID for first stop")
    }
}
