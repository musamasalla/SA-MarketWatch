import SwiftUI

struct SettingsView: View {
    @AppStorage("currency") private var currency = "zar"
    @AppStorage("refreshInterval") private var refreshInterval = 60
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("hapticFeedback") private var hapticFeedback = true
    @AppStorage("showOfflineIndicator") private var showOfflineIndicator = true
    @State private var showingAbout = false
    @State private var cacheSize = "Calculating..."
    
    let currencies = ["zar", "usd", "eur", "gbp", "btc"]
    let refreshOptions = [(30, "30s"), (60, "1min"), (120, "2min"), (300, "5min")]
    
    var body: some View {
        NavigationStack {
            List {
                // Currency
                Section("Currency") {
                    Picker("Display Currency", selection: $currency) {
                        Text("🇿🇦 ZAR").tag("zar")
                        Text("🇺🇸 USD").tag("usd")
                        Text("🇪🇺 EUR").tag("eur")
                        Text("🇬🇧 GBP").tag("gbp")
                        Text("₿ BTC").tag("btc")
                    }
                }
                
                // Refresh
                Section("Data") {
                    Picker("Refresh Interval", selection: $refreshInterval) {
                        ForEach(refreshOptions, id: \.0) { value, label in
                            Text(label).tag(value)
                        }
                    }
                    
                    HStack {
                        Text("Cache Size")
                        Spacer()
                        Text(cacheSize)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Clear Cache") {
                        OfflineCache.clearAll()
                        cacheSize = "0 KB"
                    }
                    .foregroundColor(.red)
                }
                
                // Notifications
                Section("Notifications") {
                    Toggle("Price Alerts", isOn: $notificationsEnabled)
                    Toggle("Haptic Feedback", isOn: $hapticFeedback)
                    Toggle("Show Offline Indicator", isOn: $showOfflineIndicator)
                }
                
                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("2.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Built by")
                        Spacer()
                        Text("Greg AI 🦾")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("About SA Market Watch") {
                        showingAbout = true
                    }
                }
                
                // Danger Zone
                Section {
                    Button("Reset Watchlist to Defaults") {
                        // Handled by WatchlistStore
                    }
                    .foregroundColor(.orange)
                    
                    Button("Reset All Settings") {
                        resetSettings()
                    }
                    .foregroundColor(.red)
                } header: {
                    Text("Reset")
                }
            }
            .navigationTitle("⚙️ Settings")
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .onAppear {
                calculateCacheSize()
            }
        }
    }
    
    private func calculateCacheSize() {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        if let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.fileSizeKey]) {
            let total = files.reduce(0) { size, url in
                (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) + size
            }
            cacheSize = ByteCountFormatter.string(fromByteCount: Int64(total), countStyle: .file)
        }
    }
    
    private func resetSettings() {
        currency = "zar"
        refreshInterval = 60
        notificationsEnabled = true
        hapticFeedback = true
        showOfflineIndicator = true
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // App Icon Placeholder
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text("🇿🇦")
                            .font(.system(size: 50))
                    )
                
                Text("SA Market Watch")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Version 2.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Built from scratch by Greg AI 🦾\nNo human wrote a single line of code.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Live crypto prices in ZAR")
                    FeatureRow(icon: "bell.fill", text: "Price alerts & notifications")
                    FeatureRow(icon: "magnifyingglass", text: "Search 10,000+ coins")
                    FeatureRow(icon: "fuelpump.fill", text: "SA fuel price predictions")
                    FeatureRow(icon: "newspaper.fill", text: "Curated market news")
                    FeatureRow(icon: "wifi.slash", text: "Offline mode support")
                }
                .padding(.horizontal)
                
                Spacer()
                
                Text("Powered by CoinGecko API")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("© 2026 Greg AI. All rights reserved.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    SettingsView()
}
