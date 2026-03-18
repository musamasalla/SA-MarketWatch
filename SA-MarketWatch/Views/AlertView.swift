//
//  AlertView.swift
//  SA Market Watch
//
//  Refactored with Design System
//

import SwiftUI

struct AlertView: View {
    @EnvironmentObject var alertStore: AlertStore
    @EnvironmentObject var cryptoVM: CryptoViewModel
    @EnvironmentObject var haptic: HapticManager
    @State private var showingCreate = false
    
    var body: some View {
        NavigationStack {
            Group {
                if alertStore.alerts.isEmpty {
                    SAEmptyState(
                        icon: "bell.slash",
                        title: "No Alerts Set",
                        message: "Create price alerts to get notified when coins hit your targets",
                        buttonTitle: "Create Alert",
                        buttonAction: {
                            haptic.light()
                            showingCreate = true
                        }
                    )
                } else {
                    List {
                        ForEach(alertStore.alerts) { alert in
                            AlertRow(alert: alert)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                haptic.medium()
                                alertStore.remove(alertStore.alerts[index])
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("🔔 Price Alerts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        haptic.light()
                        showingCreate = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.saPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingCreate) {
                CreateAlertView()
            }
        }
    }
}

struct AlertRow: View {
    let alert: PriceAlert
    @EnvironmentObject var alertStore: AlertStore
    
    var body: some View {
        HStack(spacing: SASpacing.sm) {
            // Direction indicator
            Image(systemName: alert.isAbove ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .font(.title2)
                .foregroundColor(alert.isAbove ? .saBull : .saBear)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(alert.coinName)
                    .font(.saBodyLarge)
                    .fontWeight(.medium)
                    .foregroundColor(.saTextPrimary)
                
                Text(alert.isAbove ? "Above target" : "Below target")
                    .font(.saCaption)
                    .foregroundColor(alert.isAbove ? .saBull : .saBear)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatPrice(alert.targetPrice, currency: alert.currency))
                    .font(.saPrice)
                    .foregroundColor(.saTextPrimary)
                
                if alert.isTriggered {
                    Text("TRIGGERED")
                        .font(.saCaption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.saWarning)
                        .cornerRadius(4)
                } else if alert.isActive {
                    SAMarketStatusBadge(isOnline: true)
                } else {
                    Text("Paused")
                        .font(.saCaption)
                        .foregroundColor(.saTextTertiary)
                }
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                alertStore.remove(alert)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                alertStore.toggle(alert)
            } label: {
                Label(alert.isActive ? "Pause" : "Resume",
                      systemImage: alert.isActive ? "pause.circle" : "play.circle")
            }
            .tint(.saInfo)
        }
    }
    
    private func formatPrice(_ price: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.uppercased()
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
}

struct CreateAlertView: View {
    @EnvironmentObject var cryptoVM: CryptoViewModel
    @EnvironmentObject var alertStore: AlertStore
    @EnvironmentObject var haptic: HapticManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCoin: CryptoPrice?
    @State private var targetPrice = ""
    @State private var isAbove = true
    @State private var showingCoinPicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Select Coin") {
                    if cryptoVM.prices.isEmpty {
                        SALoadingView(message: "Loading coins...")
                    } else if let selected = selectedCoin {
                        HStack {
                            Text(selected.name)
                                .foregroundColor(.saTextPrimary)
                            Spacer()
                            Text(selected.formattedPrice)
                                .foregroundColor(.saTextSecondary)
                        }
                        Button("Change Coin") {
                            showingCoinPicker = true
                        }
                        .foregroundColor(.saPrimary)
                    } else {
                        Button("Choose a Coin") {
                            showingCoinPicker = true
                        }
                        .foregroundColor(.saPrimary)
                    }
                }
                
                if let coin = selectedCoin {
                    Section("Current Price") {
                        HStack {
                            Text(coin.name)
                                .font(.saBodyMedium)
                            Spacer()
                            Text(coin.formattedPrice)
                                .font(.saPrice)
                        }
                    }
                    
                    Section("Alert When Price Goes") {
                        Picker("Direction", selection: $isAbove) {
                            Text("Above").tag(true)
                            Text("Below").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: isAbove) { _, _ in haptic.selection() }
                        
                        HStack {
                            Text("ZAR")
                                .font(.saBodyMedium)
                                .foregroundColor(.saTextSecondary)
                            TextField("Target price", text: $targetPrice)
                                .keyboardType(.decimalPad)
                                .font(.saBodyLarge)
                        }
                    }
                    
                    Section {
                        Button {
                            haptic.success()
                            if let price = Double(targetPrice), let coin = selectedCoin {
                                let alert = PriceAlert(
                                    coinId: coin.id,
                                    coinName: coin.name,
                                    targetPrice: price,
                                    currency: "zar",
                                    isAbove: isAbove
                                )
                                alertStore.add(alert)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Create Alert")
                                    .font(.saButton)
                                Spacer()
                            }
                        }
                        .disabled(Double(targetPrice) == nil)
                    }
                }
            }
            .navigationTitle("New Alert")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        haptic.light()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCoinPicker) {
                NavigationStack {
                    List(cryptoVM.prices) { coin in
                        Button {
                            selectedCoin = coin
                            haptic.selection()
                            showingCoinPicker = false
                        } label: {
                            HStack {
                                AsyncImage(url: URL(string: coin.image)) { img in
                                    img.resizable()
                                } placeholder: {
                                    Circle().fill(Color.saSurfaceSecondary)
                                }
                                .frame(width: 32, height: 32)
                                
                                VStack(alignment: .leading) {
                                    Text(coin.name)
                                        .foregroundColor(.saTextPrimary)
                                    Text(coin.symbol.uppercased())
                                        .font(.saCaption)
                                        .foregroundColor(.saTextSecondary)
                                }
                                
                                Spacer()
                                
                                if selectedCoin?.id == coin.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.saPrimary)
                                }
                            }
                        }
                    }
                    .navigationTitle("Select Coin")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingCoinPicker = false
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AlertView()
        .environmentObject(AlertStore())
        .environmentObject(CryptoViewModel())
        .environmentObject(HapticManager.shared)
}
