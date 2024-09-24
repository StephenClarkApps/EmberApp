//
//  Constants.swift
//  Ember Bus
//
//  Created by Stephen Clark on 17/09/2024.
//

import Foundation

struct EBConstants {
    static let baseURL = "https://api.ember.to/v1"
    
    struct Endpoints {
        static let quotes = "/quotes/"
        static let trips = "/trips/"
    }
    
    struct API {
        static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        static let timeZone = "UTC"
    }
    
    enum UserDefaultsKeys {
        static let autoDismissCallout = "autoDismissCallout"
        static let autoPollEnabled = "autoPollEnabled"
        static let defaultZoomLevel = "defaultZoomLevel"
    }
    
    struct Toast {
        static let dismissDurationSeconds: Double = 3
    }
}

