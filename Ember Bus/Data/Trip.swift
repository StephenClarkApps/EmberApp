//
//  Trip.swift
//  Ember Bus
//
//  Created by Stephen Clark on 10/09/2024.
//

import Foundation

// MARK: - Trip
struct Trip: Codable, Identifiable, Hashable {
    
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.id == rhs.id
    }
    
    let route: [Route]
    let vehicle: Vehicle
    let description: Description
    var id: String {
        return description.routeNumber
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
}


// MARK: - Description
struct Description: Codable {
    let routeNumber: String
    let patternId: Int
    let calendarDate, type: String
    let isCancelled: Bool
    let routeId: Int

    enum CodingKeys: String, CodingKey {
        case routeNumber
        case patternId
        case calendarDate
        case type
        case isCancelled
        case routeId
    }
}

// MARK: - Route
struct Route: Codable, Identifiable {
    let id: Int
    let departure, arrival: TripArrival?
    let location: Location
    let allowBoarding, allowDropOff: Bool
    let bookingCutOffMins: Int
    let preBookedOnly, skipped: Bool
    let stopReplacement: TripStopReplacement?

    enum CodingKeys: String, CodingKey {
        case id, departure, arrival, location
        case allowBoarding
        case allowDropOff
        case bookingCutOffMins
        case preBookedOnly
        case skipped
        case stopReplacement
    }
}

// MARK: - Arrival
struct TripArrival: Codable {
    let scheduled: Date?
    let actual: Date?
    let estimated: Date?
}

// MARK: - Location
struct Location: Codable {
    let id: Int
    let type: String
    let name, regionName, code, codeDetail: String?  // code seemed missing in some responses
    let detailedName: String?
    let lon, lat: Double?
    let googlePlaceId, atcoCode: String?  // Also, seem to miss google place id in some responses
    let timezone: String?
    let zone: [Zone]
    let heading, areaId: Int?
    let direction, localName: String?

    enum CodingKeys: String, CodingKey {
        case id, type, name
        case regionName
        case code
        case codeDetail
        case detailedName
        case lon, lat
        case googlePlaceId
        case atcoCode
        case timezone, zone, heading
        case areaId
        case direction
        case localName
    }
}

// MARK: - StopReplacement
struct TripStopReplacement: Codable {
    let description: String
    let originalLocationId: Int
    let originalLocationAtcoCode: String
    let replacementLocationId: Int
    let useStopName, isCancelled: Bool
    let arrivalDelay: Int

    enum CodingKeys: String, CodingKey {
        case description
        case originalLocationId
        case originalLocationAtcoCode
        case replacementLocationId
        case useStopName
        case isCancelled
        case arrivalDelay
    }
}

// MARK: - Vehicle
struct Vehicle: Codable {
    let bicycle, wheelchair, seat, id: Int
    let plateNumber, name: String
    let hasWifi, hasToilet: Bool
    let type, brand, colour: String
    let isBackupVehicle: Bool
    let ownerId: Int
    let gps: Gps

    enum CodingKeys: String, CodingKey {
        case bicycle, wheelchair, seat, id
        case plateNumber
        case name
        case hasWifi
        case hasToilet
        case type, brand, colour
        case isBackupVehicle
        case ownerId
        case gps
    }
}

// MARK: - Gps
struct Gps: Codable {
    let lastUpdated: Date? // Is this a date in a standard format
    let longitude, latitude: Double
    let heading: Int

    enum CodingKeys: String, CodingKey {
        case lastUpdated
        case longitude, latitude, heading
    }
}
