//
//  SA_MarketWatchApp.swift
//  SA Market Watch
//
//  Refactored with Design System + App State
//

import SwiftUI

@main
struct SA_MarketWatchApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var cryptoVM = CryptoViewModel()
    @StateObject private var fuelVM = FuelViewModel()
    @StateObject private var newsVM = NewsViewModel()
    @StateObject private var watchlist = WatchlistStore()
    @StateObject private var alertStore = AlertStore()
    @StateObject private var hapticManager = HapticManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    init() {
        SATabBarAppearance.configure()
        SANavigationBarAppearance.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(cryptoVM)
                .environmentObject(fuelVM)
                .environmentObject(newsVM)
                .environmentObject(watchlist)
                .environmentObject(alertStore)
                .environmentObject(hapticManager)
                .environmentObject(notificationManager)
                .environmentObject(networkMonitor)
                .preferredColorScheme(appState.isDarkMode ? .dark : .light)
        }
    }
}
