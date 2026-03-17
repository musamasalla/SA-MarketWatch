import SwiftUI

struct CryptoView: View {
    @EnvironmentObject var viewModel: CryptoViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header Card
                    headerCard
                    
                    // Price List
                    if viewModel.isLoading && viewModel.prices.isEmpty {
                        ProgressView("Loading prices...")
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if let error = viewModel.errorMessage {
                        errorView(error)
                    } else {
                        ForEach(viewModel.prices) { crypto in
                            CryptoCard(crypto: crypto)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("🇿🇦 Crypto in ZAR")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                if viewModel.prices.isEmpty {
                    await viewModel.fetchPrices()
                }
            }
        }
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
            // Coin Image
            AsyncImage(url: URL(string: crypto.image)) { image in
                image.resizable()
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.3))
            }
            .frame(width: 40, height: 40)
            
            // Name & Symbol
            VStack(alignment: .leading, spacing: 2) {
                Text(crypto.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text(crypto.symbol.uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Price & Change
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
}
