//
//  BusAnnotationView.swift
//  Ember Bus
//
//  Created by Stephen Clark on 10/09/2024.
//

import SwiftUI
import Combine

struct BusAnnotationView: View {
    @EnvironmentObject var viewModel: TripViewModel
    @Binding var isCalloutVisible: Bool

    // For dynamic time display
    @State private var timeSinceUpdate: String = "Updating..."
    @State private var timerSubscription: AnyCancellable?

    // For error handling
    @State private var showToast: Bool = false

    // For observing settings
    @AppStorage("autoDismissCallout") private var autoDismissCallout: Bool = true

    var body: some View {
        ZStack {
            // Bus Icon Button
            Button(action: {
                withAnimation {
                    isCalloutVisible.toggle()
                }
            }) {
                Image(systemName: "bus.fill")
                    .foregroundColor(.green)
                    .padding(5)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }

            if isCalloutVisible {
                ZStack {
                    // Callout Content
                    VStack(alignment: .leading, spacing: 8) {
                        // Route Information
                        if let routeInfo = viewModel.getRouteInfo() {
                            Text("\(routeInfo.departureTime) from \(routeInfo.fromLocation) to \(routeInfo.toLocation)")
                                .font(.body)
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                                .lineLimit(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text("Route information not available")
                                .font(.body)
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                        }

                        // Dynamic Time Since Update
                        Text("Location updated \(timeSinceUpdate)")
                            .font(.footnote)
                            .foregroundColor(.secondary)

                        Divider()

                        // Next Stop Information
                        HStack(spacing: 15) {
                            VStack(alignment: .leading) {
                                Text("Next Stop")
                                    .font(.footnote)
                                    .foregroundColor(.primary)
                                    .fontWeight(.semibold)
                                if let nextStopInfo = viewModel.getNextStopInfo() {
                                    Text(nextStopInfo.scheduledArrivalTime)  // Display ETA
                                        .font(.title3)
                                        .fontWeight(.regular)
                                        .foregroundColor(.primary)
                                    Text("Est. \(nextStopInfo.estimatedArrivalTime)")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundColor(nextStopInfo.isRunningLate ? .red : .green)
                                } else {
                                    Text("No upcoming stops")
                                        .font(.title3)
                                        .fontWeight(.regular)
                                        .foregroundColor(.primary)
                                }
                            }

                            VStack(alignment: .leading)  {
                                Text("") // Deliberately blank
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.semibold)
                                if let nextStopInfo = viewModel.getNextStopInfo() {
                                    Text(nextStopInfo.locationName)
                                        .font(.title3)
                                        .fontWeight(.regular)
                                        .foregroundColor(.primary)
                                    Text("Stop Details")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("No upcoming stops")
                                        .font(.title3)
                                        .fontWeight(.regular)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .frame(width: 280)
                    .fixedSize(horizontal: false, vertical: true)

                    // Pointer Shape
                    PointerShape()
                        .fill(Color(UIColor.systemBackground))
                        .frame(width: 40, height: 20)
                        .offset(y: 100)
                }
                .offset(y: -135)
                .transition(.opacity)
                .onAppear {
                    startTimer()
                }
                .onDisappear {
                    stopTimer()
                }
                // Move the tap gesture to a background overlay to avoid interfering with the button
                .background(
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if autoDismissCallout {
                                withAnimation {
                                    isCalloutVisible = false
                                }
                            }
                        }
                )
            }

            if showToast, let errorMessage = viewModel.errorMessage {
                ToastView(
                    message: errorMessage,
                    icon: "exclamationmark.triangle.fill",
                    backgroundColor: .red,
                    isShowing: $showToast
                )
                .onTapGesture {
                    withAnimation {
                        self.showToast = false
                    }
                    viewModel.errorMessage = nil
                }
                .padding(.top, 50)  
            }

        }
        .onReceive(viewModel.$errorMessage) { errorMessage in
            if errorMessage != nil {
                withAnimation {
                    self.showToast = true
                }
            }
        }
    }

    // Timer management functions
    private func startTimer() {
        updateTimeSinceUpdate()  // Update immediately on appear
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                updateTimeSinceUpdate()
            }
    }

    private func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    private func updateTimeSinceUpdate() {
        guard let lastUpdated = viewModel.trip?.vehicle.gps.lastUpdated else {
            timeSinceUpdate = "Unknown"
            return
        }

        let timeInterval = Date().timeIntervalSince(lastUpdated)
        timeSinceUpdate = formatTimeInterval(timeInterval)
    }

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let seconds = Int(interval)
        if seconds < 60 {
            return "just now"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else {
            let hours = seconds / 3600
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        }
    }
}

// Custom Pointer Shape
struct PointerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: -5))
        path.addLine(to: CGPoint(x: rect.width / 2, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: -5))
        path.closeSubpath()
        return path
    }
}


// Preview struct for Xcode
struct BusAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample Trip for preview
        let sampleTrip = Trip(
            route: [Route(id: 1, departure: TripArrival(scheduled: Date(), actual: nil, estimated: Date().addingTimeInterval(160)), arrival: TripArrival(scheduled: Date(), actual: nil, estimated: Date().addingTimeInterval(160)), location: Location(id: 1, type: "STOP_POINT", name: "Dundee", regionName: "Dundee", code: "DUN", codeDetail: "Greenmarket", detailedName: "Greenmarket", lon: -2.9747, lat: 56.4561, googlePlaceId: "ChIJqR8vVb5chkgRK2nyU6tGED0", atcoCode: "640014188", timezone: "Europe/London", zone: [], heading: 0, areaId: 13, direction: nil, localName: nil), allowBoarding: true, allowDropOff: false, bookingCutOffMins: 0, preBookedOnly: false, skipped: false, stopReplacement: nil)],
            vehicle: Vehicle(bicycle: 0, wheelchair: 0, seat: 0, id: 1, plateNumber: "SG23 ORT", name: "Yutong Coach", hasWifi: true, hasToilet: true, type: "coach", brand: "Ember", colour: "Black", isBackupVehicle: false, ownerId: 1, gps: Gps(lastUpdated: Date().addingTimeInterval(-300), longitude: -3.0, latitude: 56.0, heading: 0)),
            description: Description(routeNumber: "E1", patternId: 1, calendarDate: "2024-09-11", type: "public", isCancelled: false, routeId: 1)
        )

        let viewModel = MockTripViewModel(trip: sampleTrip)

        BusAnnotationView(isCalloutVisible: .constant(true))
            .environmentObject(viewModel)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.gray.opacity(0.2))
    }
}

// Mock TripViewModel for Preview
class MockTripViewModel: TripViewModel {
    init(trip: Trip) {
        super.init(tripId: "")
        self.trip = trip
    }

    override func fetchTripData() {
        // Do nothing in mock
    }
}
