//
//  SettingsView.swift
//  Ember Bus
//
//  Created by Stephen Clark on 11/09/2024.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - PROPERTIES

    @EnvironmentObject var settings: Settings  // Use a setting env object allowing this to be observed for live updates
    @State private var enableMoreInfo: Bool = true

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // MARK: - HEADER
            VStack(alignment: .center, spacing: 5) {
                Image("EmberLogo")
                    .resizable()
                    .scaledToFill()
                    .padding(.top)
                    .frame(width: 100, height: 80, alignment: .center)
                    .shadow(color: Color("ColorBlackTransparentLight"), radius: 8, x: 0, y: 4)
            }
            .padding()

            Form {
                // MARK: - SECTION #1
                Section(header: Text("General Settings")) {
                    Toggle("Auto Dismiss Callout", isOn: $settings.autoDismissCallout)

                    VStack {
                        Text("Default Map Zoom Level")
                        Slider(value: $settings.defaultZoomLevel, in: 0.01...0.7, step: 0.03)
                    }
                    
                    Toggle("Auto Poll Trip Data", isOn: $settings.autoPollEnabled)
                }

                // MARK: - SECTION #2
                Section(header: Text("Application")) {
                    if enableMoreInfo {
                        HStack {
                            Text("Product").foregroundColor(Color.gray)
                            Spacer()
                            Text("Ember Bus")
                        }
                        HStack {
                            Text("Compatibility").foregroundColor(Color.gray)
                            Spacer()
                            Text("iPhone & iPad")
                        }
                        HStack {
                            Text("Developer").foregroundColor(Color.gray)
                            Spacer()
                            Text("Stephen Clark")
                        }
                        HStack {
                            Text("Website").foregroundColor(Color.gray)
                            Spacer()
                            Text("https://www.steveclarkapps.com/")
                        }
                        HStack {
                            Text("Version").foregroundColor(Color.gray)
                            Spacer()
                            Text("1.0.0")
                        }
                    } else {
                        HStack {
                            Text("Product").foregroundColor(Color.gray)
                            Spacer()
                            Text("Ember Bus")
                        }
                    }
                }
            }
        }
        .frame(maxWidth: 640)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(Settings())
    }
}
