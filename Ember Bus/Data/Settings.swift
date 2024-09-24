//
//  Settings.swift
//  Ember Bus
//
//  Created by Stephen Clark on 22/09/2024.
//

import Foundation
import Combine

class Settings: ObservableObject {
    @Published var autoDismissCallout: Bool {
        didSet {
            UserDefaults.standard.set(autoDismissCallout, forKey: "autoDismissCallout")
        }
    }

    @Published var defaultZoomLevel: Double {
        didSet {
            UserDefaults.standard.set(defaultZoomLevel, forKey: "defaultZoomLevel")
        }
    }

    @Published var autoPollEnabled: Bool {
        didSet {
            UserDefaults.standard.set(autoPollEnabled, forKey: "autoPollEnabled")
        }
    }

    init() {
        self.autoDismissCallout = UserDefaults.standard.object(forKey: "autoDismissCallout") as? Bool ?? false
        self.defaultZoomLevel = UserDefaults.standard.object(forKey: "defaultZoomLevel") as? Double ?? 0.05
        self.autoPollEnabled = UserDefaults.standard.object(forKey: "autoPollEnabled") as? Bool ?? true
    }
}
