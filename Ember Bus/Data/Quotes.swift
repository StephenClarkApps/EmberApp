//
//  Quotes.swift
//  Ember Bus
//
//  Created by Stephen Clark on 10/09/2024.
//

/*
 Process: use Postman to generate a query to the endpoint
 https://api.ember.to/v1/quotes/?origin=13&destination=42&departure_date_from=2024-09-10T10:15:22Z&departure_date_to=2024-09-10T14:15:22Z
 
 I then parsed the response using https://app.quicktype.io/
 
 I then removed all the overly specific classes it had generated for parameters which might have more options then those that were
 returned in this particular query. So mostly this is removing the custom classes and replacing with String (assuming the presence
 of this parameter). We can refer then to the API documentation, or carry out further testing to insure that when a paramter is
 optional (and may not be returned) that we mark it as such. 
 
 If we're not using explicit coding keys, we can instead use the decode from snakecase decoding stategy to ensure correct decode
 from the JSON responses.
 */


import Foundation

// MARK: - Quotes
struct Quotes: Codable {
    let quotes: [Quote]
    let minCardTransaction: Int

    enum CodingKeys: String, CodingKey {
        case quotes
        case minCardTransaction
    }
}

// MARK: - Quote
struct Quote: Codable {
    let availability: Availability
    let prices: Prices
    let legs: [Leg]
    let bookable: Bool
}

// MARK: - Availability
struct Availability: Codable {
    let seat, wheelchair, bicycle: Int
}

// MARK: - Leg
struct Leg: Codable {
    let type, tripUid: String
    let addsCapacityForTripUid: String? // Unknown
    let origin, destination: Destination
    let departure, arrival: Arrival
    let description: BusDescription
    let tripType: String

    enum CodingKeys: String, CodingKey {
        case type
        case tripUid
        case addsCapacityForTripUid
        case origin, destination, departure, arrival, description
        case tripType
    }
}

// MARK: - Arrival
struct Arrival: Codable {
    let scheduled, actual, estimated: Date
}

// MARK: - Description
// MARK: - BusDescription
struct BusDescription: Codable {
    let brand: String
    let descriptionOperator: String // Renamed property
    let destinationBoard, numberPlate: String
    let vehicleType, colour: String
    let amenities: Amenities
    let isElectric: Bool

    enum CodingKeys: String, CodingKey {
        case brand
        case descriptionOperator = "operator" // Map the "operator" key to the "descriptionOperator" property as is reserved swift keyword
        case destinationBoard
        case numberPlate
        case vehicleType
        case colour, amenities
        case isElectric
    }
}


// MARK: - Amenities
struct Amenities: Codable {
    let hasWifi, hasToilet: Bool

    enum CodingKeys: String, CodingKey {
        case hasWifi
        case hasToilet
    }
}

// MARK: - Destination
struct Destination: Codable {
    let id: Int
    let atcoCode: String
    let detailedName: String
    let googlePlaceId: String
    let lat, lon: Double
    let name: String
    let regionName: String
    let type: String
    let code: String
    let codeDetail: String
    let timezone: String
    let heading: Int
    let zone: [Zone]
    let stopReplacement: StopReplacement?
    let areaId, locationTimeId, bookingCutOffMins: Int
    let preBookedOnly, skipped: Bool
    let bookable: Date

    enum CodingKeys: String, CodingKey {
        case id
        case atcoCode
        case detailedName
        case googlePlaceId
        case lat, lon, name
        case regionName
        case type, code
        case codeDetail
        case timezone, heading, zone
        case stopReplacement
        case areaId
        case locationTimeId 
        case bookingCutOffMins
        case preBookedOnly
        case skipped, bookable
    }
}




// MARK: - StopReplacement
struct StopReplacement: Codable {
    let useStopName, isCancelled: Bool
    let arrivalDelay, originalLocationId, replacementLocationId: Int
    let description: String

    enum CodingKeys: String, CodingKey {
        case useStopName
        case isCancelled
        case arrivalDelay
        case originalLocationId
        case replacementLocationId
        case description
    }
}

// MARK: - Zone (Same in both responses from Quotes and from Trip so can just use one data class)
struct Zone: Codable {
    let longitude, latitude: Double
}

// MARK: - Prices
struct Prices: Codable {
    let adult, child, youngChild, concession: Int
    let seat, wheelchair, bicycle: Int

    enum CodingKeys: String, CodingKey {
        case adult, child
        case youngChild
        case concession, seat, wheelchair, bicycle
    }
}
