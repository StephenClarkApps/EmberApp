//
//  DateExtensionTests.swift
//  Ember BusTests
//
//  Created by Stephen Clark on 24/09/2024.
//

import XCTest
@testable import Ember_Bus

// MARK: - Date Extension Tests
class DateExtensionTests: XCTestCase {
    
    // MARK: - Format Date to "HH:mm" String
    func test_whenDateIsGiven_formattedTimeReturnsCorrectString() {
        // GIVEN: A specific date and time
        var dateComponents = DateComponents()
        dateComponents.year = 2023
        dateComponents.month = 10
        dateComponents.day = 1
        dateComponents.hour = 15
        dateComponents.minute = 30
        dateComponents.second = 0
        let calendar = Calendar.current
        guard let testDate = calendar.date(from: dateComponents) else {
            XCTFail("Failed to create test date from components.")
            return
        }
        
        // WHEN: formattedTime() is called on the date
        let formattedTime = testDate.formattedTime()
        
        // THEN: The returned string matches the expected "HH:mm" format
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        let expectedTime = formatter.string(from: testDate)
        
        XCTAssertEqual(formattedTime, expectedTime, "formattedTime() did not return the expected string.")
    }
    
    // MARK: - Retrieve Start of Today
    func test_whenStartOfTodayIsAccessed_itReturnsStartOfCurrentDay() {
        // GIVEN: The current date and calendar
        let now = Date()
        let calendar = Calendar.current
        let expectedStartOfToday = calendar.startOfDay(for: now)
        
        // WHEN: startOfToday is accessed
        let actualStartOfToday = Date.startOfToday
        
        // THEN: The startOfToday matches the expected start of the day
        XCTAssertEqual(actualStartOfToday, expectedStartOfToday, "startOfToday does not match the expected start of the day.")
    }
    
    // MARK: - Retrieve End of Today
    func test_whenEndOfTodayIsAccessed_itReturnsEndOfCurrentDay() {
        // GIVEN: The current date and calendar
        let now = Date()
        let calendar = Calendar.current
        guard let expectedEndOfToday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) else {
            XCTFail("Failed to calculate expected end of today.")
            return
        }
        
        // WHEN: endOfToday is accessed
        let actualEndOfToday = Date.endOfToday
        
        // THEN: The endOfToday matches the expected end of the day
        XCTAssertEqual(actualEndOfToday, expectedEndOfToday, "endOfToday does not match the expected end of the day.")
    }
    
    // MARK: - Format Various Dates to "HH:mm" String
    func test_whenVariousDatesAreGiven_formattedTimeReturnsExpectedStrings() {
        // GIVEN: A set of test dates with known times
        let testCases: [(year: Int, month: Int, day: Int, hour: Int, minute: Int, expected: String)] = [
            (2023, 1, 1, 0, 0, "00:00"),
            (2023, 6, 15, 12, 45, "12:45"),
            (2023, 12, 31, 23, 59, "23:59")
        ]
        let calendar = Calendar.current
        
        for testCase in testCases {
            // GIVEN: A specific date component
            var dateComponents = DateComponents()
            dateComponents.year = testCase.year
            dateComponents.month = testCase.month
            dateComponents.day = testCase.day
            dateComponents.hour = testCase.hour
            dateComponents.minute = testCase.minute
            dateComponents.second = 0
            guard let testDate = calendar.date(from: dateComponents) else {
                XCTFail("Failed to create test date from components for \(testCase).")
                continue
            }
            
            // WHEN: formattedTime() is called on the date
            let formattedTime = testDate.formattedTime()
            
            // THEN: The returned string matches the expected "HH:mm" format
            XCTAssertEqual(formattedTime, testCase.expected, "formattedTime() for \(testDate) did not return the expected string '\(testCase.expected)'.")
        }
    }
    
    // MARK: - Verify Start of Today When Already at Start of Day
    func test_whenStartOfTodayIsAccessedAtStartOfDay_itReturnsCorrectStartOfDay() {
        // GIVEN: A date representing the start of the day
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        guard let startOfDay = calendar.date(from: dateComponents) else {
            XCTFail("Failed to create start of day date.")
            return
        }
        
        // WHEN: startOfToday is accessed
        let actualStartOfToday = Date.startOfToday
        
        // THEN: The startOfToday matches the provided start of day date
        XCTAssertEqual(actualStartOfToday, startOfDay, "startOfToday does not correctly identify the start of the day.")
    }
    
    // MARK: - Verify End of Today Handles Edge Cases
    func test_whenEndOfTodayIsAccessed_itHandlesEdgeCasesCorrectly() {
        // GIVEN: The current date and calendar
        let now = Date()
        let calendar = Calendar.current
        guard let expectedEndOfToday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) else {
            XCTFail("Failed to calculate expected end of today for edge case.")
            return
        }
        
        // WHEN: endOfToday is accessed
        let actualEndOfToday = Date.endOfToday
        
        // THEN: The endOfToday matches the expected end of the day
        XCTAssertEqual(actualEndOfToday, expectedEndOfToday, "endOfToday does not correctly handle edge cases.")
    }
}
