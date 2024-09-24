//
//  EmberBusApp.swift
//  Ember Bus
//
//  Created by Stephen Clark on 22/09/2024.
//

import SwiftUI

@main
struct EmberBusApp: App {
    @StateObject private var settings = Settings()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(settings)
        }
    }
}
