import SwiftUI

struct FuelView: View {
    @EnvironmentObject var viewModel: FuelViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Summary Card
                    summaryCard
                    
                    // Price List
                    ForEach(viewModel.prices) { fuel in
                        FuelCard(fuel: fuel)
                    }
                    
                    // Info
                    infoCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("⛽ Fuel Prices")
        }
    }
    
    private var summaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: viewModel.isGoodNews ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(viewModel.isGoodNews ? .green : .red)
                
                VStack(alignment: .leading) {
                    Text(viewModel.isGoodNews ? "Good News!" : "Prices Rising")
                        .font(.headline)
                    Text("April prediction: \(viewModel.formattedAverageChange)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            Text("Based on current oil prices and ZAR/USD exchange rate")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📅 Next price adjustment")
                .font(.subheadline)
                .fontWeight(.medium)
            Text("April 1, 2026 — announced by DMRE on the first Wednesday of each month")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct FuelCard: View {
    let fuel: FuelPrice
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(fuel.type)
                    .font(.body)
                    .fontWeight(.medium)
                Text(fuel.effectiveDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(fuel.formattedPrice)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text(fuel.formattedChange)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(fuel.isPositive ? Color.red : Color.green)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    FuelView()
        .environmentObject(FuelViewModel())
}
