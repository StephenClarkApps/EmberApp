//
//  Ember_BusTests.swift
//  Ember BusTests
//
//  Created by Stephen Clark on 10/09/2024.
//

import XCTest
@testable import Ember_Bus

final class Ember_BusTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testQuotesDecoding() {
        // Load the JSON file from the test bundle
        guard let url = Bundle(for: type(of: self)).url(forResource: "ExampleQuotes", withExtension: "json") else {
            XCTFail("Missing file: ExampleQuotes.json")
            return
        }
        
        do {
            // Read the data from the file
            let data = try Data(contentsOf: url)
            
            // Attempt to decode the JSON into the Quotes struct
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601 // Assuming the date is in ISO 8601 format
            
            let quotes = try decoder.decode(Quotes.self, from: data)
            
            // Assert that the quotes array is not empty
            XCTAssertFalse(quotes.quotes.isEmpty, "Quotes array should not be empty")
            
            // Further assertions based on the expected content of your JSON file
            if let firstQuote = quotes.quotes.first {
                XCTAssertEqual(firstQuote.availability.seat, 17, "Expected 17 seats available")
                XCTAssertEqual(firstQuote.prices.adult, 850, "Expected adult price of 850")
            }
            
        } catch {
            XCTFail("Failed to decode Quotes JSON: \(error.localizedDescription)")
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
