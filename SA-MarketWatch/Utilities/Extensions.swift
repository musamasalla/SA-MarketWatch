import Foundation
import SwiftUI

extension Double {
    var zarString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "ZAR"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "R\(self)"
    }
    
    var percentString: String {
        let sign = self >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", self))%"
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
    }
}

extension Color {
    static let saGreen = Color(red: 0.0, green: 0.47, blue: 0.27)
    static let saGold = Color(red: 0.85, green: 0.65, blue: 0.13)
}
