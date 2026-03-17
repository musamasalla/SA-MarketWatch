import SwiftUI

@main
struct SA_MarketWatchApp: App {
    @StateObject private var cryptoVM = CryptoViewModel()
    @StateObject private var fuelVM = FuelViewModel()
    @StateObject private var newsVM = NewsViewModel()
    @StateObject private var watchlist = WatchlistStore()
    @StateObject private var alertStore = AlertStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cryptoVM)
                .environmentObject(fuelVM)
                .environmentObject(newsVM)
                .environmentObject(watchlist)
                .environmentObject(alertStore)
        }
    }
}
