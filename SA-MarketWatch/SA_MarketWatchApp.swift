import SwiftUI

@main
struct SA_MarketWatchApp: App {
    @StateObject private var cryptoVM = CryptoViewModel()
    @StateObject private var fuelVM = FuelViewModel()
    @StateObject private var newsVM = NewsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cryptoVM)
                .environmentObject(fuelVM)
                .environmentObject(newsVM)
        }
    }
}
