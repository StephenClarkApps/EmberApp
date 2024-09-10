//
//  EmberBusQuotesTests.swift
//  Ember BusTests
//
//  Created by Stephen Clark on 10/09/2024.
//

import XCTest
@testable import Ember_Bus


final class EmberBusQuotesTests: XCTestCase {

    private var quotes: Quotes!

    override func setUpWithError() throws {
        // Covering our GIVEN -  Load the JSON data and decode it
        guard let url = Bundle(for: type(of: self)).url(forResource: "ExampleQuotes", withExtension: "json") else {
            XCTFail("Missing file: ExampleQuotes.json")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            self.quotes = try decoder.decode(Quotes.self, from: data)
        } catch {
            XCTFail("Failed to decode Quotes JSON: \(error.localizedDescription)")
        }
    }

    override func tearDownWithError() throws {
        // Clear the decoded quotes data
        quotes = nil
    }
    
    // MARK: - User Story 4: Show Seat, Wheelchair, and Bicycle Availability
    func test_whenFetchingQuotes_WeSeeSeatAvaliabilityEtc() {
        // Given: A decoded quotes object

        // When: Accessing the first quote
        guard let firstQuote = quotes.quotes.first else {
            XCTFail("No quotes available to test")
            return
        }

        // Then: Verify seat, wheelchair, and bicycle availability
        XCTAssertEqual(firstQuote.availability.seat, 17, "Expected 17 seats available")
        XCTAssertEqual(firstQuote.availability.wheelchair, 1, "Expected 1 wheelchair spot available")
        XCTAssertEqual(firstQuote.availability.bicycle, 1, "Expected 1 bicycle space available")
    }

    // MARK: - User Story 2: Display Scheduled & Estimated Times at Each Stop
    func test_whenFetchingQuotes_WeSeeScheduledAndEstimatedTimesAtStops() {
        // Given: A decoded quotes object

        // When: Accessing the first leg of the first quote
        guard let firstQuote = quotes.quotes.first, let firstLeg = firstQuote.legs.first else {
            XCTFail("No legs available to test")
            return
        }

        // Then: Verify scheduled and estimated times
        XCTAssertEqual(firstLeg.departure.scheduled, ISO8601DateFormatter().date(from: "2024-09-10T10:40:00+00:00"), "Expected scheduled departure time at origin")
        XCTAssertEqual(firstLeg.arrival.estimated, ISO8601DateFormatter().date(from: "2024-09-10T12:53:36+00:00"), "Expected estimated arrival time at destination")
    }

    // MARK: - User Story 7: Tap for More Information on Bus or Stop
    func test_whenFetchingQuotes_WeHaveMoreInformationToShow() {
        // Given: A decoded quotes object

        // When: Accessing the first leg of the first quote
        guard let firstQuote = quotes.quotes.first, let firstLeg = firstQuote.legs.first else {
            XCTFail("No legs available to test")
            return
        }

        // Then: Verify the bus brand and number plate
        XCTAssertEqual(firstLeg.description.brand, "Ember", "Expected bus brand to be Ember")
        XCTAssertEqual(firstLeg.description.numberPlate, "SG23 ORN", "Expected number plate to match")
    }

    // MARK: - User Story 5: Notify About Route Disruptions or Changes
    func test_whenFetchingQuotes_weGetInfoAboutRouteDisruptions() {
        // Given: A decoded quotes object

        // When: Accessing the stop replacement of the first leg's destination
        guard let firstQuote = quotes.quotes.first, let firstLeg = firstQuote.legs.first, let stopReplacement = firstLeg.destination.stopReplacement else {
            XCTFail("No stop replacement available to test")
            return
        }

        // Then: Verify if there is a stop replacement due to disruption
        XCTAssertFalse(stopReplacement.isCancelled, "The stop should not be cancelled")
        XCTAssertEqual(stopReplacement.description, "Due to a road closure your service will call at George Street instead of St Andrew Square. We're sorry for any inconvenience.", "Expected route disruption notice")
    }
}
