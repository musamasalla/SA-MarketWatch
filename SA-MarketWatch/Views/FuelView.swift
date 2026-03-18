//
//  FuelView.swift
//  SA Market Watch
//
//  Refactored with Design System
//

import SwiftUI

struct FuelView: View {
    @EnvironmentObject var viewModel: FuelViewModel
    @EnvironmentObject var haptic: HapticManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SASpacing.md) {
                    // Summary Card
                    summaryCard
                    
                    // Price List
                    SASectionHeader(
                        title: "Current Prices",
                        subtitle: "Gauteng pump prices"
                    )
                    .padding(.top, SASpacing.xs)
                    
                    ForEach(viewModel.prices) { fuel in
                        FuelCard(fuel: fuel)
                    }
                    
                    // Info Card
                    infoCard
                }
                .padding(SASpacing.md)
            }
            .saGroupedBackground()
            .navigationTitle("⛽ Fuel Prices")
        }
    }
    
    private var summaryCard: some View {
        SACard {
            HStack(spacing: SASpacing.md) {
                // Icon
                Image(systemName: viewModel.isGoodNews ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(viewModel.isGoodNews ? .saBull : .saBear)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.isGoodNews ? "Good News!" : "Prices Rising")
                        .font(.saHeadingMedium)
                        .foregroundColor(.saTextPrimary)
                    
                    Text("April prediction: \(viewModel.formattedAverageChange)")
                        .font(.saBodyMedium)
                        .foregroundColor(.saTextSecondary)
                }
                
                Spacer()
            }
            
            Text("Based on current oil prices and ZAR/USD exchange rate")
                .font(.saCaption)
                .foregroundColor(.saTextTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, SASpacing.xs)
        }
    }
    
    private var infoCard: some View {
        SACard {
            VStack(alignment: .leading, spacing: SASpacing.xs) {
                HStack(spacing: SASpacing.xs) {
                    Image(systemName: "calendar")
                        .foregroundColor(.saPrimary)
                    Text("Next price adjustment")
                        .font(.saBodyMedium)
                        .fontWeight(.medium)
                }
                
                Text("April 1, 2026 — announced by DMRE on the first Wednesday of each month")
                    .font(.saCaption)
                    .foregroundColor(.saTextSecondary)
            }
        }
    }
}

struct FuelCard: View {
    let fuel: FuelPrice
    
    var body: some View {
        SAMarketCard(isPositive: !fuel.isPositive) {  // Inverted: fuel price increase = bad = red
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(fuel.type)
                        .font(.saBodyLarge)
                        .fontWeight(.medium)
                        .foregroundColor(.saTextPrimary)
                    
                    Text(fuel.effectiveDate)
                        .font(.saCaption)
                        .foregroundColor(.saTextSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(fuel.formattedPrice)
                        .font(.saPrice)
                        .foregroundColor(.saTextPrimary)
                    
                    Text(fuel.formattedChange)
                        .font(.saCaption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(!fuel.isPositive ? Color.saBull : Color.saBear)
                        )
                }
            }
        }
    }
}

#Preview {
    FuelView()
        .environmentObject(FuelViewModel())
        .environmentObject(HapticManager.shared)
}
