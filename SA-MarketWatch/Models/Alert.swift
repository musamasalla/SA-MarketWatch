import Foundation

struct PriceAlert: Identifiable, Codable {
    let id: UUID
    let coinId: String
    let coinName: String
    let targetPrice: Double
    let currency: String
    let isAbove: Bool // true = alert when price goes above, false = alert when below
    var isActive: Bool
    var isTriggered: Bool
    let createdAt: Date
    
    init(coinId: String, coinName: String, targetPrice: Double, currency: String = "zar", isAbove: Bool) {
        self.id = UUID()
        self.coinId = coinId
        self.coinName = coinName
        self.targetPrice = targetPrice
        self.currency = currency
        self.isAbove = isAbove
        self.isActive = true
        self.isTriggered = false
        self.createdAt = Date()
    }
    
    var description: String {
        let direction = isAbove ? "above" : "below"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.uppercased()
        let priceStr = formatter.string(from: NSNumber(value: targetPrice)) ?? "\(targetPrice)"
        return "\(coinName) \(direction) \(priceStr)"
    }
}

class AlertStore: ObservableObject {
    @Published var alerts: [PriceAlert] = []
    
    private let key = "price_alerts"
    
    init() {
        load()
    }
    
    func add(_ alert: PriceAlert) {
        alerts.append(alert)
        save()
    }
    
    func remove(_ alert: PriceAlert) {
        alerts.removeAll { $0.id == alert.id }
        save()
    }
    
    func toggle(_ alert: PriceAlert) {
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index].isActive.toggle()
            save()
        }
    }
    
    func checkAlerts(prices: [CryptoPrice]) -> [PriceAlert] {
        var triggered: [PriceAlert] = []
        
        for (index, alert) in alerts.enumerated() {
            guard alert.isActive, !alert.isTriggered else { continue }
            
            if let price = prices.first(where: { $0.id == alert.coinId }) {
                let hit = alert.isAbove ? 
                    price.currentPrice >= alert.targetPrice :
                    price.currentPrice <= alert.targetPrice
                
                if hit {
                    alerts[index].isTriggered = true
                    triggered.append(alerts[index])
                }
            }
        }
        
        if !triggered.isEmpty { save() }
        return triggered
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(alerts) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([PriceAlert].self, from: data) {
            alerts = decoded
        }
    }
}
