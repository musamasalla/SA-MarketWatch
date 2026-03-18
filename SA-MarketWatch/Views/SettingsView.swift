//
//  SettingsView.swift
//  SA Market Watch
//
//  Refactored with Design System + AppState
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var haptic: HapticManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var showingAbout = false
    @State private var showingResetConfirm = false
    @State private var cacheSize = "Calculating..."
    
    var body: some View {
        NavigationStack {
            List {
                // Currency Section
                Section {
                    Picker(selection: $appState.selectedCurrency) {
                        ForEach(AppState.availableCurrencies, id: \.code) { currency in
                            Text("\(currency.flag) \(currency.name)")
                                .tag(currency.code)
                        }
                    } label: {
                        HStack(spacing: SASpacing.xs) {
                            Image(systemName: "coloncurrencysign.circle.fill")
                                .foregroundColor(.saPrimary)
                                .frame(width: 28)
                            Text("Display Currency")
                        }
                    }
                } header: {
                    Text("Currency")
                }
                
                // Data Section
                Section {
                    Picker(selection: $appState.refreshInterval) {
                        ForEach(AppState.refreshIntervals, id: \.seconds) { interval in
                            Text(interval.label).tag(interval.seconds)
                        }
                    } label: {
                        HStack(spacing: SASpacing.xs) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.saPrimary)
                                .frame(width: 28)
                            Text("Auto Refresh")
                        }
                    }
                    
                    HStack {
                        HStack(spacing: SASpacing.xs) {
                            Image(systemName: "internaldrive.fill")
                                .foregroundColor(.saPrimary)
                                .frame(width: 28)
                            Text("Cache Size")
                        }
                        Spacer()
                        Text(cacheSize)
                            .font(.saCaption)
                            .foregroundColor(.saTextSecondary)
                    }
                    
                    Button {
                        haptic.medium()
                        clearCache()
                    } label: {
                        HStack(spacing: SASpacing.xs) {
                            Image(systemName: "trash")
                                .frame(width: 28)
                            Text("Clear Cache")
                        }
                    }
                    .foregroundColor(.saDanger)
                } header: {
                    Text("Data")
                }
                
                // Notifications Section
                Section {
                    Toggle(isOn: $appState.notificationsEnabled) {
                        HStack(spacing: SASpacing.xs) {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.saPrimary)
                                .frame(width: 28)
                            Text("Price Alerts")
                        }
                    }
                    .onChange(of: appState.notificationsEnabled) { _, newValue in
                        if newValue {
                            Task {
                                await notificationManager.requestPermission()
                            }
                        }
                    }
                    
                    Toggle(isOn: $appState.hapticFeedback) {
                        HStack(spacing: SASpacing.xs) {
                            Image(systemName: "hand.tap.fill")
                                .foregroundColor(.saPrimary)
                                .frame(width: 28)
                            Text("Haptic Feedback")
                        }
                    }
                } header: {
                    Text("Notifications")
                }
                
                // Appearance Section
                Section {
                    Toggle(isOn: $appState.isDarkMode) {
                        HStack(spacing: SASpacing.xs) {
                            Image(systemName: appState.isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(.saPrimary)
                                .frame(width: 28)
                            Text("Dark Mode")
                        }
                    }
                } header: {
                    Text("Appearance")
                }
                
                // About Section
                Section {
                    HStack {
                        HStack(spacing: SASpacing.xs) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.saPrimary)
                                .frame(width: 28)
                            Text("Version")
                        }
                        Spacer()
                        Text("2.1.0")
                            .font(.saCaption)
                            .foregroundColor(.saTextSecondary)
                    }
                    
                    HStack {
                        HStack(spacing: SASpacing.xs) {
                            Image(systemName: "hammer.fill")
                                .foregroundColor(.saPrimary)
                                .frame(width: 28)
                            Text("Built by")
                        }
                        Spacer()
                        Text("Greg AI 🦾")
                            .font(.saCaption)
                            .foregroundColor(.saTextSecondary)
                    }
                    
                    Button {
                        haptic.light()
                        showingAbout = true
                    } label: {
                        HStack(spacing: SASpacing.xs) {
                            Image(systemName: "app.fill")
                                .frame(width: 28)
                            Text("About SA Market Watch")
                        }
                    }
                    .foregroundColor(.saPrimary)
                } header: {
                    Text("About")
                }
                
                // Reset Section
                Section {
                    Button {
                        haptic.warning()
                        showingResetConfirm = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset All Settings")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .foregroundColor(.saDanger)
                }
            }
            .navigationTitle("⚙️ Settings")
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .confirmationDialog(
                "Reset all settings to defaults?",
                isPresented: $showingResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Reset All Settings", role: .destructive) {
                    haptic.heavy()
                    appState.resetToDefaults()
                }
                Button("Cancel", role: .cancel) {}
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
    
    private func clearCache() {
        OfflineCache.clearAll()
        cacheSize = "0 KB"
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var haptic: HapticManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SASpacing.xl) {
                    Spacer(minLength: SASpacing.xxl)
                    
                    // App Icon
                    RoundedRectangle(cornerRadius: SARadius.xl)
                        .fill(
                            LinearGradient(
                                colors: [.saDeepGreen, .saForest],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(Text("🇿🇦").font(.system(size: 50)))
                        .saShadowMedium()
                    
                    VStack(spacing: SASpacing.xs) {
                        Text("SA Market Watch")
                            .font(.saDisplayMedium)
                            .foregroundColor(.saTextPrimary)
                        
                        Text("Version 2.1.0")
                            .font(.saCaption)
                            .foregroundColor(.saTextSecondary)
                    }
                    
                    Text("Built from scratch by Greg AI 🦾\nNo human wrote a single line of code.")
                        .font(.saBodyMedium)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.saTextSecondary)
                    
                    // Features
                    SACard {
                        VStack(spacing: SASpacing.md) {
                            FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Live crypto prices in ZAR")
                            FeatureRow(icon: "bell.fill", text: "Price alerts & notifications")
                            FeatureRow(icon: "magnifyingglass", text: "Search 10,000+ coins")
                            FeatureRow(icon: "fuelpump.fill", text: "SA fuel price predictions")
                            FeatureRow(icon: "newspaper.fill", text: "Curated market news")
                            FeatureRow(icon: "wifi.slash", text: "Offline mode support")
                            FeatureRow(icon: "hand.tap.fill", text: "Haptic feedback")
                            FeatureRow(icon: "moon.fill", text: "Dark mode")
                        }
                    }
                    
                    VStack(spacing: SASpacing.xs) {
                        Text("Powered by CoinGecko API")
                            .font(.saCaption)
                            .foregroundColor(.saTextTertiary)
                        
                        Text("© 2026 Greg AI. All rights reserved.")
                            .font(.saCaption)
                            .foregroundColor(.saTextTertiary)
                    }
                    
                    Spacer(minLength: SASpacing.xl)
                }
                .padding(SASpacing.lg)
            }
            .saBackground()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        haptic.light()
                        dismiss()
                    }
                    .font(.saButton)
                    .foregroundColor(.saPrimary)
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: SASpacing.sm) {
            Image(systemName: icon)
                .foregroundColor(.saPrimary)
                .frame(width: 24)
            
            Text(text)
                .font(.saBodyMedium)
                .foregroundColor(.saTextPrimary)
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(HapticManager.shared)
        .environmentObject(NotificationManager.shared)
}
