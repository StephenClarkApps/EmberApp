//
//  NetworkMonitor.swift
//  Ember Bus
//
//  Created by Stephen Clark on 19/09/2024.
//

import Network
import Combine

protocol NetworkMonitoring: ObservableObject {
    var isConnected: Bool { get }
    var isConnectedPublisher: Published<Bool>.Publisher { get } // Add a publisher
    func startMonitoring()
    func stopMonitoring()
}


class NetworkMonitor: ObservableObject, NetworkMonitoring {
    @Published var isConnected: Bool = true

    private var monitor: NWPathMonitor
    private var queue = DispatchQueue.global()

    init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
            }
        }
        startMonitoring()
    }

    var isConnectedPublisher: Published<Bool>.Publisher { $isConnected } // Return the publisher

    func startMonitoring() {
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}


