//
//  NotificationManager.swift
//  SA Market Watch
//
//  Local notification management for price alerts
//

import UserNotifications
import SwiftUI

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            await MainActor.run {
                self.authorizationStatus = granted ? .authorized : .denied
                self.notificationsEnabled = granted
            }
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    // MARK: - Price Alert Notifications
    
    func sendPriceAlert(coinName: String, coinSymbol: String, currentPrice: Double, targetPrice: Double, isAbove: Bool) {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🔔 Price Alert: \(coinName)"
        content.body = "\(coinSymbol.uppercased()) is now \(isAbove ? "above" : "below") R\(formatPrice(targetPrice)) (now R\(formatPrice(currentPrice)))"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "PRICE_ALERT"
        
        // Immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "price_alert_\(coinSymbol)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
    
    // MARK: - Scheduled Refresh Notification
    
    func scheduleRefreshSummary(coins: [(name: String, change: Double)]) {
        guard notificationsEnabled, !coins.isEmpty else { return }
        
        let movers = coins.filter { abs($0.change) > 5 }
        guard !movers.isEmpty else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "📊 Market Update"
        
        let topMover = movers.max(by: { abs($0.change) < abs($1.change) })!
        let direction = topMover.change >= 0 ? "📈" : "📉"
        content.body = "\(direction) \(topMover.name) moved \(String(format: "%.1f", abs(topMover.change)))% today"
        content.sound = .default
        content.categoryIdentifier = "MARKET_UPDATE"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "market_update_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Utilities
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: price)) ?? String(format: "%.2f", price)
    }
}
