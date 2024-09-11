//
//  AppView.swift
//  Ember Bus
//
//  Created by Stephen Clark on 11/09/2024.
//

import SwiftUI

struct AppView: View {
  var body: some View {
    TabView {
//      BusMapView()
        QuotesListView()
        .tabItem({
          Image(systemName: "bus.fill")
          Text("Bus Map")
        })

      SettingsView()
        .tabItem({
          Image(systemName: "gearshape.fill")
          Text("Settings")
        })
    }
    .accentColor(Color.primary)
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView()
      .previewDevice("iPhone 13")
      .environment(\.colorScheme, .dark)
  }
}
