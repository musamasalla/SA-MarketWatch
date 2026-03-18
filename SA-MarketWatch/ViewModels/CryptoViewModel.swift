import Foundation
import SwiftUI

@MainActor
class CryptoViewModel: ObservableObject {
    @Published var prices: [CryptoPrice] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    @Published var isOffline = false
    
    private let api = APIService.shared
    
    var zarrate: Double = 18.50
    
    func fetchPrices(for watchlist: WatchlistStore? = nil) async {
        isLoading = true
        errorMessage = nil
        isOffline = false
        
        do {
            let ids = watchlist?.coinIds ?? ["bitcoin", "ethereum", "ripple", "litecoin", "cardano", "solana", "polkadot", "dogecoin", "avalanche-2", "tron"]
            
            async let cryptoTask = api.fetchCryptoPrices(ids: ids)
            async let zarTask = api.fetchZARRate()
            
            let (fetched, zar) = try await (cryptoTask, zarTask)
            prices = fetched
            zarrate = zar
            lastUpdated = Date()
        } catch {
            errorMessage = error.localizedDescription
            isOffline = true
            
            // Try offline cache
            if let cached: [CryptoPrice] = OfflineCache.load(forKey: "crypto_prices") {
                prices = cached
                errorMessage = nil
                isOffline = true
            }
        }
        
        isLoading = false
    }
    
    func refresh(for watchlist: WatchlistStore? = nil) async {
        await fetchPrices(for: watchlist)
    }
    
    var formattedLastUpdate: String {
        guard let lastUpdated else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: lastUpdated, relativeTo: Date())
    }
}
