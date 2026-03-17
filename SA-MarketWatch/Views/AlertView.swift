import SwiftUI

struct AlertView: View {
    @EnvironmentObject var alertStore: AlertStore
    @EnvironmentObject var cryptoVM: CryptoViewModel
    @State private var showingCreate = false
    
    var body: some View {
        NavigationStack {
            Group {
                if alertStore.alerts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No Alerts Set")
                            .font(.headline)
                        Text("Create price alerts to get notified\nwhen coins hit your targets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Create Alert") {
                            showingCreate = true
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(alertStore.alerts) { alert in
                            AlertRow(alert: alert)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
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
                        showingCreate = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.coinName)
                    .font(.headline)
                Text(alert.isAbove ? "↑ Above" : "↓ Below")
                    .font(.caption)
                    .foregroundColor(alert.isAbove ? .green : .red)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatPrice(alert.targetPrice, currency: alert.currency))
                    .font(.body)
                    .fontWeight(.bold)
                
                if alert.isTriggered {
                    Text("TRIGGERED")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange)
                        .cornerRadius(4)
                } else if alert.isActive {
                    Text("Active")
                        .font(.caption2)
                        .foregroundColor(.green)
                } else {
                    Text("Paused")
                        .font(.caption2)
                        .foregroundColor(.secondary)
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
            .tint(.blue)
        }
    }
    
    private func formatPrice(_ price: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.uppercased()
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
}

struct CreateAlertView: View {
    @EnvironmentObject var cryptoVM: CryptoViewModel
    @EnvironmentObject var alertStore: AlertStore
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCoin: CryptoPrice?
    @State private var targetPrice = ""
    @State private var isAbove = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Coin") {
                    if cryptoVM.prices.isEmpty {
                        Text("Loading coins...")
                    } else {
                        Picker("Select Coin", selection: $selectedCoin) {
                            Text("Choose a coin").tag(nil as CryptoPrice?)
                            ForEach(cryptoVM.prices) { coin in
                                Text("\(coin.name) (\(coin.symbol.uppercased()))")
                                    .tag(coin as CryptoPrice?)
                            }
                        }
                    }
                }
                
                if let coin = selectedCoin {
                    Section("Current Price") {
                        HStack {
                            Text(coin.name)
                            Spacer()
                            Text(coin.formattedPrice)
                                .fontWeight(.bold)
                        }
                    }
                    
                    Section("Alert When Price Goes") {
                        Picker("Direction", selection: $isAbove) {
                            Text("Above").tag(true)
                            Text("Below").tag(false)
                        }
                        .pickerStyle(.segmented)
                        
                        HStack {
                            Text("ZAR")
                                .foregroundColor(.secondary)
                            TextField("Target price", text: $targetPrice)
                                .keyboardType(.decimalPad)
                        }
                    }
                    
                    Section {
                        Button("Create Alert") {
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
                        }
                        .disabled(Double(targetPrice) == nil)
                    }
                }
            }
            .navigationTitle("New Alert")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AlertView()
        .environmentObject(AlertStore())
        .environmentObject(CryptoViewModel())
}
