import Foundation

struct CryptoPrice: Identifiable, Codable {
    let id: String
    let symbol: String
    let name: String
    let currentPrice: Double
    let priceChangePercentage24h: Double
    let marketCap: Double
    let totalVolume: Double
    let image: String
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case marketCap = "market_cap"
        case totalVolume = "total_volume"
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "ZAR"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: currentPrice)) ?? "R\(currentPrice)"
    }
    
    var formattedChange: String {
        let sign = priceChangePercentage24h >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", priceChangePercentage24h))%"
    }
    
    var isPositive: Bool {
        priceChangePercentage24h >= 0
    }
}
