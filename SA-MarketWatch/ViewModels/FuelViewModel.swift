import Foundation
import SwiftUI

@MainActor
class FuelViewModel: ObservableObject {
    @Published var prices: [FuelPrice] = []
    @Published var selectedMonth: String = "April 2026"
    
    let months = ["March 2026", "April 2026", "May 2026"]
    
    init() {
        loadFuelData()
    }
    
    func loadFuelData() {
        prices = FuelData.current
    }
    
    var averageChange: Double {
        guard !prices.isEmpty else { return 0 }
        return prices.reduce(0) { $0 + $1.predictedChange } / Double(prices.count)
    }
    
    var formattedAverageChange: String {
        let sign = averageChange >= 0 ? "+" : ""
        return "\(sign)R\(String(format: "%.2f", averageChange))/L avg"
    }
    
    var isGoodNews: Bool {
        averageChange < 0
    }
}
