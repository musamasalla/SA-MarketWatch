//
//  NetworkMonitor.swift
//  SA Market Watch
//
//  Real-time network connectivity monitoring
//

import Foundation
import Network
import SwiftUI

@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published var isConnected: Bool = true
    @Published var connectionType: ConnectionType = .unknown
    @Published var isExpensive: Bool = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    enum ConnectionType: String {
        case wifi = "WiFi"
        case cellular = "Cellular"
        case ethernet = "Ethernet"
        case unknown = "Unknown"
        case none = "No Connection"
    }
    
    private init() {
        startMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                self?.isExpensive = path.isExpensive
                
                if path.usesInterfaceType(.wifi) {
                    self?.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self?.connectionType = .cellular
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self?.connectionType = .ethernet
                } else if path.status == .satisfied {
                    self?.connectionType = .unknown
                } else {
                    self?.connectionType = .none
                }
                
                // Notify app state
                NotificationCenter.default.post(
                    name: .networkStatusChanged,
                    object: nil,
                    userInfo: ["isConnected": path.status == .satisfied]
                )
            }
        }
        monitor.start(queue: queue)
    }
    
    func checkConnection() -> Bool {
        return isConnected
    }
}
