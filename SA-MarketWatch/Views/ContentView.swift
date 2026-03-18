//
//  ContentView.swift
//  SA Market Watch
//
//  Refactored with Design System + AppState + Managers
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var haptic: HapticManager
    @EnvironmentObject var network: NetworkMonitor
    
    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingFlowView()
            } else {
                MainTabView()
            }
        }
        .overlay(alignment: .top) {
            if !network.isConnected {
                OfflineBanner()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: network.isConnected)
        .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedOnboarding)
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var haptic: HapticManager
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            CryptoView()
                .tabItem {
                    Label(
                        AppState.TabItem.crypto.rawValue,
                        systemImage: appState.selectedTab == .crypto ?
                            AppState.TabItem.crypto.selectedIcon :
                            AppState.TabItem.crypto.icon
                    )
                }
                .tag(AppState.TabItem.crypto)
            
            FuelView()
                .tabItem {
                    Label(
                        AppState.TabItem.fuel.rawValue,
                        systemImage: appState.selectedTab == .fuel ?
                            AppState.TabItem.fuel.selectedIcon :
                            AppState.TabItem.fuel.icon
                    )
                }
                .tag(AppState.TabItem.fuel)
            
            NewsView()
                .tabItem {
                    Label(
                        AppState.TabItem.news.rawValue,
                        systemImage: appState.selectedTab == .news ?
                            AppState.TabItem.news.selectedIcon :
                            AppState.TabItem.news.icon
                    )
                }
                .tag(AppState.TabItem.news)
            
            SettingsView()
                .tabItem {
                    Label(
                        AppState.TabItem.settings.rawValue,
                        systemImage: appState.selectedTab == .settings ?
                            AppState.TabItem.settings.selectedIcon :
                            AppState.TabItem.settings.icon
                    )
                }
                .tag(AppState.TabItem.settings)
        }
        .tint(.saPrimary)
        .onChange(of: appState.selectedTab) { _, _ in
            haptic.selection()
        }
    }
}

// MARK: - Offline Banner

struct OfflineBanner: View {
    var body: some View {
        HStack(spacing: SASpacing.xs) {
            Image(systemName: "wifi.slash")
                .font(.saCaption)
            
            Text("Offline — showing cached data")
                .font(.saCaption)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, SASpacing.md)
        .padding(.vertical, SASpacing.xs)
        .background(Color.saWarning)
        .cornerRadius(SARadius.small)
        .padding(.top, 4)
    }
}

// MARK: - Onboarding Flow

struct OnboardingFlowView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var haptic: HapticManager
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "🇿🇦",
            title: "SA Market Watch",
            description: "Your personal South African market dashboard — crypto, fuel prices, and market news in one place.",
            gradient: [Color.saDeepGreen, Color.saForest]
        ),
        OnboardingPage(
            icon: "📊",
            title: "Live Crypto in ZAR",
            description: "Track Bitcoin, Ethereum, and 10,000+ coins priced in South African Rand. Real-time updates, no guesswork.",
            gradient: [Color.saForest, Color.saGreen]
        ),
        OnboardingPage(
            icon: "⛽",
            title: "Fuel Price Predictions",
            description: "See monthly fuel price predictions before they're announced. Plan your fill-ups smarter and save money.",
            gradient: [Color.saGold, Color.saBrightGold]
        ),
        OnboardingPage(
            icon: "🔔",
            title: "Smart Price Alerts",
            description: "Set price targets and get notified instantly. Works offline with cached data when you need it most.",
            gradient: [Color.saBrightGold, Color.saGold]
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: pages[appState.currentOnboardingStep].gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        haptic.light()
                        withAnimation { appState.completeOnboarding() }
                    }
                    .font(.saButton)
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
                }
                
                // Page content
                TabView(selection: $appState.currentOnboardingStep) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: appState.currentOnboardingStep)
                
                // Custom page indicator + buttons
                VStack(spacing: SASpacing.lg) {
                    // Custom dots
                    HStack(spacing: SASpacing.xs) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == appState.currentOnboardingStep ? Color.white : Color.white.opacity(0.4))
                                .frame(width: index == appState.currentOnboardingStep ? 24 : 8, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: appState.currentOnboardingStep)
                        }
                    }
                    
                    // Navigation buttons
                    HStack(spacing: SASpacing.md) {
                        if appState.currentOnboardingStep > 0 {
                            Button {
                                haptic.light()
                                withAnimation { appState.previousOnboardingStep() }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .font(.saButton)
                                .foregroundColor(.white)
                                .frame(width: 120, height: 52)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(SARadius.large)
                            }
                        }
                        
                        Spacer()
                        
                        if appState.currentOnboardingStep < pages.count - 1 {
                            Button {
                                haptic.medium()
                                withAnimation { appState.nextOnboardingStep(totalSteps: pages.count) }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Next")
                                    Image(systemName: "chevron.right")
                                }
                                .font(.saButton)
                                .foregroundColor(.saDeepGreen)
                                .frame(width: 120, height: 52)
                                .background(Color.white)
                                .cornerRadius(SARadius.large)
                            }
                        } else {
                            Button {
                                haptic.success()
                                withAnimation { appState.completeOnboarding() }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Get Started")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.saButton)
                                .foregroundColor(.saDeepGreen)
                                .frame(width: 180, height: 52)
                                .background(Color.white)
                                .cornerRadius(SARadius.large)
                            }
                        }
                    }
                }
                .padding(.horizontal, SASpacing.xl)
                .padding(.bottom, SASpacing.xxl)
            }
        }
        .interactiveDismissDisabled()
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let gradient: [Color]
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: SASpacing.xl) {
            Spacer()
            
            Text(page.icon)
                .font(.system(size: 80))
            
            Text(page.title)
                .font(.saDisplayMedium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.saBodyLarge)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, SASpacing.xl)
                .lineSpacing(4)
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(CryptoViewModel())
        .environmentObject(FuelViewModel())
        .environmentObject(NewsViewModel())
        .environmentObject(WatchlistStore())
        .environmentObject(AlertStore())
        .environmentObject(HapticManager.shared)
        .environmentObject(NotificationManager.shared)
        .environmentObject(NetworkMonitor.shared)
}
