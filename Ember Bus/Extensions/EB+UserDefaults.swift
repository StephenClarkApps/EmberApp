//
//  EB-UserDefaults.swift
//  Ember Bus
//
//  Created by Stephen Clark on 17/09/2024.
//

import Foundation

// Extenstion to provide centralised place to track values we are stroing to defaults
extension UserDefaults {

    var autoDismissCallout: Bool {
        get {
            return bool(forKey: EBConstants.UserDefaultsKeys.autoDismissCallout)
        }
        set {
            set(newValue, forKey: EBConstants.UserDefaultsKeys.autoDismissCallout)
        }
    }
    
    var autoPollEnabled: Bool {
        get {
            return bool(forKey: EBConstants.UserDefaultsKeys.autoDismissCallout)
        }
        set {
            set(newValue, forKey: EBConstants.UserDefaultsKeys.autoDismissCallout)
        }
    }
    
    var defaultZoomLevel: Double {
        get {
            return double(forKey: EBConstants.UserDefaultsKeys.defaultZoomLevel)
        }
        set {
            set(newValue, forKey: EBConstants.UserDefaultsKeys.defaultZoomLevel)
        }
    }
    
    
}

