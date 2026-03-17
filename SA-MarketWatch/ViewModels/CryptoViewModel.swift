import Foundation
import SwiftUI

@MainActor
class CryptoViewModel: ObservableObject {
    @Published var prices: [CryptoPrice] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    private let api = APIService.shared
    
    var zarrate: Double = 18.50 // Default fallback
    
    func fetchPrices() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let cryptoTask = api.fetchCryptoPrices()
            async let zarTask = api.fetchZARRate()
            
            let (fetched, zar) = try await (cryptoTask, zarTask)
            prices = fetched
            zarrate = zar
            lastUpdated = Date()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await fetchPrices()
    }
    
    var formattedLastUpdate: String {
        guard let lastUpdated else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: lastUpdated, relativeTo: Date())
    }
}
