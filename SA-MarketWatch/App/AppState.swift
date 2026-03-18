//
//  AppState.swift
//  SA Market Watch
//
//  Central app state management
//

import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    // MARK: - Onboarding
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var currentOnboardingStep: Int = 0
    
    // MARK: - User Preferences
    @Published var selectedCurrency: String {
        didSet {
            UserDefaults.standard.set(selectedCurrency, forKey: "selectedCurrency")
        }
    }
    
    @Published var refreshInterval: Int {
        didSet {
            UserDefaults.standard.set(refreshInterval, forKey: "refreshInterval")
        }
    }
    
    // MARK: - Theme
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    @Published var useLargeText: Bool {
        didSet {
            UserDefaults.standard.set(useLargeText, forKey: "useLargeText")
        }
    }
    
    // MARK: - Notifications
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    @Published var hapticFeedback: Bool {
        didSet {
            UserDefaults.standard.set(hapticFeedback, forKey: "hapticFeedback")
        }
    }
    
    // MARK: - UI State
    @Published var selectedTab: TabItem = .crypto
    @Published var isRefreshing: Bool = false
    @Published var showingAlertCreator: Bool = false
    @Published var showingCoinSearch: Bool = false
    
    // MARK: - Sync State
    @Published var lastSyncDate: Date?
    @Published var isOffline: Bool = false
    @Published var offlineMessage: String?
    
    // MARK: - Notification Badge Counts
    @Published var triggeredAlertsCount: Int = 0
    
    // MARK: - Tab Items
    enum TabItem: String, CaseIterable {
        case crypto = "Crypto"
        case fuel = "Fuel"
        case news = "News"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .crypto: return "bitcoinsign.circle"
            case .fuel: return "fuelpump"
            case .news: return "newspaper"
            case .settings: return "gearshape"
            }
        }
        
        var selectedIcon: String {
            switch self {
            case .crypto: return "bitcoinsign.circle.fill"
            case .fuel: return "fuelpump.fill"
            case .news: return "newspaper.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    // MARK: - Currencies
    static let availableCurrencies: [(code: String, flag: String, name: String)] = [
        ("zar", "🇿🇦", "ZAR"),
        ("usd", "🇺🇸", "USD"),
        ("eur", "🇪🇺", "EUR"),
        ("gbp", "🇬🇧", "GBP"),
        ("btc", "₿", "BTC")
    ]
    
    static let refreshIntervals: [(seconds: Int, label: String)] = [
        (30, "30s"),
        (60, "1 min"),
        (120, "2 min"),
        (300, "5 min")
    ]
    
    // MARK: - Init
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.selectedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "zar"
        self.refreshInterval = UserDefaults.standard.integer(forKey: "refreshInterval") == 0 ? 60 : UserDefaults.standard.integer(forKey: "refreshInterval")
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.useLargeText = UserDefaults.standard.bool(forKey: "useLargeText")
        self.notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") == nil ? true : UserDefaults.standard.bool(forKey: "notificationsEnabled")
        self.hapticFeedback = UserDefaults.standard.object(forKey: "hapticFeedback") == nil ? true : UserDefaults.standard.bool(forKey: "hapticFeedback")
    }
    
    // MARK: - Methods
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        currentOnboardingStep = 0
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        currentOnboardingStep = 0
    }
    
    func nextOnboardingStep(totalSteps: Int) {
        if currentOnboardingStep < totalSteps - 1 {
            currentOnboardingStep += 1
        }
    }
    
    func previousOnboardingStep() {
        if currentOnboardingStep > 0 {
            currentOnboardingStep -= 1
        }
    }
    
    func markSyncComplete() {
        lastSyncDate = Date()
        isOffline = false
        offlineMessage = nil
    }
    
    func markOffline(reason: String? = nil) {
        isOffline = true
        offlineMessage = reason ?? "No internet connection. Showing cached data."
    }
    
    func resetToDefaults() {
        selectedCurrency = "zar"
        refreshInterval = 60
        notificationsEnabled = true
        hapticFeedback = true
        isDarkMode = false
        useLargeText = false
    }
    
    var formattedLastSync: String {
        guard let lastSyncDate else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: lastSyncDate, relativeTo: Date())
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let cryptoPricesUpdated = Notification.Name("cryptoPricesUpdated")
    static let fuelPricesUpdated = Notification.Name("fuelPricesUpdated")
    static let newsUpdated = Notification.Name("newsUpdated")
    static let priceAlertTriggered = Notification.Name("priceAlertTriggered")
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}
