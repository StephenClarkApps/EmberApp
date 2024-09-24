//
//  EB+CLLocationCoordinate2D.swift
//  Ember Bus
//
//  Created by Stephen Clark on 22/09/2024.
//

import CoreLocation

// Extension to make CLLocationCoordinate2D conform to the Equatable protocol
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
