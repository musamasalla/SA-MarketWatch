import SwiftUI

struct CryptoView: View {
    @EnvironmentObject var viewModel: CryptoViewModel
    @EnvironmentObject var watchlist: WatchlistStore
    @EnvironmentObject var alertStore: AlertStore
    @State private var showSearch = false
    @State private var showAlerts = false
    @State private var triggeredAlert: PriceAlert?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header Card
                    headerCard
                    
                    // Watchlist
                    if viewModel.isLoading && viewModel.prices.isEmpty {
                        ProgressView("Loading prices...")
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if let error = viewModel.errorMessage {
                        errorView(error)
                    } else {
                        ForEach(viewModel.prices) { crypto in
                            CryptoCard(crypto: crypto)
                                .onTapGesture {
                                    // Future: detail view
                                }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("🇿🇦 Crypto in ZAR")
            .refreshable {
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
                        showAlerts = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                            if !alertStore.alerts.isEmpty {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSearch = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
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
                Button("OK", role: .cancel) {}
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
        }
    }
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "ZAR"
        return formatter.string(from: NSNumber(value: price)) ?? "R\(price)"
    }
    
    private var headerCard: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("USD/ZAR")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "R%.2f", viewModel.zarrate))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Last updated")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.formattedLastUpdate)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Failed to load prices")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await viewModel.fetchPrices() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

struct CryptoCard: View {
    let crypto: CryptoPrice
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: crypto.image)) { image in
                image.resizable()
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.3))
            }
            .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(crypto.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text(crypto.symbol.uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(crypto.formattedPrice)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text(crypto.formattedChange)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(crypto.isPositive ? Color.green : Color.red)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    CryptoView()
        .environmentObject(CryptoViewModel())
        .environmentObject(WatchlistStore())
        .environmentObject(AlertStore())
}
