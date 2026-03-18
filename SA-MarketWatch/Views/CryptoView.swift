//
//  CryptoView.swift
//  SA Market Watch
//
//  Refactored with Design System
//

import SwiftUI

struct CryptoView: View {
    @EnvironmentObject var viewModel: CryptoViewModel
    @EnvironmentObject var watchlist: WatchlistStore
    @EnvironmentObject var alertStore: AlertStore
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var haptic: HapticManager
    @EnvironmentObject var network: NetworkMonitor
    
    @State private var showSearch = false
    @State private var showAlerts = false
    @State private var triggeredAlert: PriceAlert?
    @State private var searchText = ""
    
    var filteredPrices: [CryptoPrice] {
        if searchText.isEmpty {
            return viewModel.prices
        }
        return viewModel.prices.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.symbol.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SASpacing.md) {
                    // Market Overview Card
                    marketOverviewCard
                    
                    // Inline Search
                    if !viewModel.prices.isEmpty {
                        SASearchBar(text: $searchText, placeholder: "Search coins...")
                    }
                    
                    // Content
                    if viewModel.isLoading && viewModel.prices.isEmpty {
                        SALoadingView(message: "Fetching latest prices...")
                    } else if let error = viewModel.errorMessage, viewModel.prices.isEmpty {
                        SAErrorView(message: error) {
                            Task { await viewModel.fetchPrices() }
                        }
                    } else if filteredPrices.isEmpty && !searchText.isEmpty {
                        SAEmptyState(
                            icon: "magnifyingglass",
                            title: "No Results",
                            message: "No coins matching '\(searchText)'"
                        )
                    } else if filteredPrices.isEmpty {
                        SAEmptyState(
                            icon: "star.slash",
                            title: "Watchlist Empty",
                            message: "Add coins to start tracking prices",
                            buttonTitle: "Add Coins",
                            buttonAction: { showSearch = true }
                        )
                    } else {
                        ForEach(filteredPrices) { crypto in
                            CryptoCard(crypto: crypto)
                        }
                    }
                }
                .padding(SASpacing.md)
            }
            .saGroupedBackground()
            .navigationTitle("🇿🇦 Crypto in ZAR")
            .refreshable {
                haptic.refresh()
                await viewModel.refresh()
                checkAlerts()
            }
            .task {
                if viewModel.prices.isEmpty {
                    await viewModel.fetchPrices()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        haptic.light()
                        showAlerts = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.saPrimary)
                            if !alertStore.alerts.isEmpty {
                                Circle()
                                    .fill(Color.saDanger)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        haptic.light()
                        showSearch = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.saPrimary)
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                CoinSearchView()
            }
            .sheet(isPresented: $showAlerts) {
                AlertView()
            }
            .alert("🔔 Price Alert!", isPresented: Binding<Bool>(
                get: { triggeredAlert != nil },
                set: { if !$0 { triggeredAlert = nil } }
            )) {
                Button("OK", role: .cancel) { haptic.light() }
            } message: {
                if let alert = triggeredAlert {
                    Text("\(alert.coinName) is now \(alert.isAbove ? "above" : "below") your target of \(formatPrice(alert.targetPrice))!")
                }
            }
        }
    }
    
    private func checkAlerts() {
        let triggered = alertStore.checkAlerts(prices: viewModel.prices)
        if let first = triggered.first {
            triggeredAlert = first
            haptic.alertTriggered()
        }
    }
    
    private func formatPrice(_ price: Double) -> String {
        price.zarString
    }
    
    // MARK: - Market Overview Card
    
    private var marketOverviewCard: some View {
        SACard {
            VStack(spacing: SASpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("USD / ZAR")
                            .font(.saCaption)
                            .foregroundColor(.saTextSecondary)
                        
                        Text(String(format: "R%.2f", viewModel.zarrate))
                            .font(.saPriceLarge)
                            .foregroundColor(.saTextPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        SAMarketStatusBadge(isOnline: !viewModel.isOffline)
                        
                        Text(viewModel.formattedLastUpdate)
                            .font(.saCaption)
                            .foregroundColor(.saTextSecondary)
                    }
                }
                
                if viewModel.isOffline {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle")
                            .font(.saCaption)
                        Text("Showing cached prices")
                            .font(.saCaption)
                    }
                    .foregroundColor(.saWarning)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                }
            }
        }
    }
}

// MARK: - Crypto Card

struct CryptoCard: View {
    let crypto: CryptoPrice
    @EnvironmentObject var haptic: HapticManager
    
    var body: some View {
        SAMarketCard(isPositive: crypto.priceChangePercentage24h >= 0 ? true : crypto.priceChangePercentage24h < 0 ? false : nil) {
            HStack(spacing: SASpacing.sm) {
                // Coin Image
                AsyncImage(url: URL(string: crypto.image)) { image in
                    image.resizable()
                } placeholder: {
                    Circle()
                        .fill(Color.saSurfaceSecondary)
                        .overlay(
                            Text(String(crypto.symbol.prefix(1)).uppercased())
                                .font(.saTicker)
                                .foregroundColor(.saTextTertiary)
                        )
                }
                .frame(width: 42, height: 42)
                
                // Coin Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(crypto.name)
                        .font(.saBodyLarge)
                        .fontWeight(.medium)
                        .foregroundColor(.saTextPrimary)
                        .lineLimit(1)
                    
                    Text(crypto.symbol.uppercased())
                        .font(.saTicker)
                        .foregroundColor(.saTextSecondary)
                }
                
                Spacer()
                
                // Price Info
                VStack(alignment: .trailing, spacing: 4) {
                    Text(crypto.formattedPrice)
                        .font(.saPrice)
                        .foregroundColor(.saTextPrimary)
                    
                    SAPriceChangeBadge(change: crypto.priceChangePercentage24h)
                }
            }
        }
    }
}

#Preview {
    CryptoView()
        .environmentObject(CryptoViewModel())
        .environmentObject(WatchlistStore())
        .environmentObject(AlertStore())
        .environmentObject(AppState())
        .environmentObject(HapticManager.shared)
        .environmentObject(NetworkMonitor.shared)
}
