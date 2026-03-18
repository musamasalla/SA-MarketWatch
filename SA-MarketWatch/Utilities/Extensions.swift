//
//  Extensions.swift
//  SA Market Watch
//
//  Utility extensions
//

import Foundation
import SwiftUI

// MARK: - Double Formatting

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
    
    var shortZarString: String {
        if self >= 1_000_000 {
            return String(format: "R%.1fM", self / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "R%.1fK", self / 1_000)
        } else if self >= 1 {
            return String(format: "R%.2f", self)
        } else {
            return String(format: "R%.4f", self)
        }
    }
    
    var compactString: String {
        if self >= 1_000_000_000 {
            return String(format: "%.1fB", self / 1_000_000_000)
        } else if self >= 1_000_000 {
            return String(format: "%.1fM", self / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.1fK", self / 1_000)
        }
        return String(format: "%.2f", self)
    }
}

// MARK: - Date Formatting

extension Date {
    var timeAgoString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

// MARK: - View Modifiers

extension View {
    /// Standard card appearance
    func cardStyle(padding: CGFloat = SASpacing.md) -> some View {
        self
            .padding(padding)
            .background(Color.saCardBackground)
            .cornerRadius(SARadius.medium)
            .saShadowLight()
    }
    
    /// Hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Conditional modifier
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Array Extensions

extension Array where Element == Double {
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
    
    var max: Double? {
        self.max()
    }
    
    var min: Double? {
        self.min()
    }
}

// MARK: - String Extensions

extension String {
    var capitalizedFirst: String {
        prefix(1).uppercased() + dropFirst()
    }
    
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Color Helpers

extension Color {
    /// Color based on positive/negative value
    static func marketColor(_ value: Double) -> Color {
        if value > 0 { return .saBull }
        if value < 0 { return .saBear }
        return .saNeutral
    }
    
    /// Background color for market card based on sentiment
    static func marketBackground(_ value: Double) -> Color {
        if value > 0 { return .saBull.opacity(0.05) }
        if value < 0 { return .saBear.opacity(0.05) }
        return .saSurfaceSecondary
    }
}
