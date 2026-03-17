import Foundation

struct FuelPrice: Identifiable {
    let id = UUID()
    let type: String
    let currentPrice: Double
    let predictedChange: Double
    let effectiveDate: String
    
    var formattedPrice: String {
        String(format: "R%.2f/L", currentPrice)
    }
    
    var formattedChange: String {
        let sign = predictedChange >= 0 ? "+" : ""
        return "\(sign)R\(String(format: "%.2f", predictedChange))"
    }
    
    var isPositive: Bool {
        predictedChange >= 0
    }
}

struct FuelData {
    static let current: [FuelPrice] = [
        FuelPrice(type: "Petrol 93", currentPrice: 21.45, predictedChange: -0.35, effectiveDate: "April 1, 2026"),
        FuelPrice(type: "Petrol 95", currentPrice: 21.75, predictedChange: -0.32, effectiveDate: "April 1, 2026"),
        FuelPrice(type: "Diesel 50ppm", currentPrice: 19.85, predictedChange: -0.45, effectiveDate: "April 1, 2026"),
        FuelPrice(type: "Diesel 500ppm", currentPrice: 19.60, predictedChange: -0.42, effectiveDate: "April 1, 2026"),
        FuelPrice(type: "Illuminating Paraffin", currentPrice: 14.20, predictedChange: -0.28, effectiveDate: "April 1, 2026")
    ]
}
