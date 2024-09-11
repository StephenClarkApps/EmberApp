//
//  BusAnnotationView.swift
//  Ember Bus
//
//  Created by Stephen Clark on 10/09/2024.
//

import CoreLocation
import SwiftUI

struct BusAnnotationView: View {
    
    // MARK: - PARAMS
    var bus: Bus
    @State private var showCallout = false

    // MARK: - VIEW BODY
    var body: some View {
        ZStack {
            // Bus Icon
            Button(action: {
                withAnimation {
                    showCallout.toggle()
                }
            }) {
                Image(systemName: "bus.fill")
                    .foregroundColor(.green)
                    .padding(5)
                    .background(Color(UIColor.systemBackground))  // Adapts to light/dark mode
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }

            // Callout View - similar to that on website (above the bus icon)
            if showCallout {
                VStack(alignment: .leading, spacing: 8) {
                    Text("19:47 from Edinburgh to Dundee")
                        .font(.headline)
                        .foregroundColor(Color.primary)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Location updated just now")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    Text("Next Stop")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Text("20:12")
                            .font(.title2)
                            .foregroundColor(Color.primary)
                            .fontWeight(.semibold)
                        Text("On time")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.leading, 8)
                    }
                    
                    Text("Edinburgh")
                        .font(.body)
                        .foregroundColor(Color.primary)
                        .fontWeight(.medium)
                    
                    Text("Ingliston P&R (Bus Stop)")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)
                }
                .padding()
                .background(Color(UIColor.systemBackground))  // Adapts to light/dark mode
                .cornerRadius(12)
                .shadow(radius: 5)
                .frame(width: 280)
                .fixedSize(horizontal: false, vertical: true)
                .offset(y: -125)  // Position the callout above the bus icon
                .transition(.scale)  // Smooth appearance/disappearance
            }
        }
    }
}

// MARK: - PREVIEW
struct BusAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BusAnnotationView(bus: Bus(id: 1, name: "Bus 101", coordinate: CLLocationCoordinate2D(latitude: 56.4561, longitude: -2.9747), lastUpdated: Date()))
                .previewLayout(.sizeThatFits)
                .padding()
                .background(Color.gray.opacity(0.2))
                .environment(\.colorScheme, .light)  // Light mode preview
            
            BusAnnotationView(bus: Bus(id: 1, name: "Bus 101", coordinate: CLLocationCoordinate2D(latitude: 56.4561, longitude: -2.9747), lastUpdated: Date()))
                .previewLayout(.sizeThatFits)
                .padding()
                .background(Color.gray.opacity(0.2))
                .environment(\.colorScheme, .dark)  // Dark mode preview
        }
    }
}
