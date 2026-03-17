import Foundation

struct CoinSearchResult: Identifiable, Codable {
    let id: String
    let name: String
    let symbol: String
    let marketCapRank: Int?
    let thumb: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbol, thumb
        case marketCapRank = "market_cap_rank"
    }
}

struct CoinSearchResponse: Codable {
    let coins: [CoinSearchResult]
}

struct WatchlistCoin: Identifiable, Codable {
    let id: String
    let name: String
    let symbol: String
    
    var shortSymbol: String { symbol.uppercased() }
}

class WatchlistStore: ObservableObject {
    @Published var coins: [WatchlistCoin] = []
    
    private let key = "watchlist_coins"
    private let defaults: [WatchlistCoin] = [
        WatchlistCoin(id: "bitcoin", name: "Bitcoin", symbol: "btc"),
        WatchlistCoin(id: "ethereum", name: "Ethereum", symbol: "eth"),
        WatchlistCoin(id: "solana", name: "Solana", symbol: "sol"),
        WatchlistCoin(id: "cardano", name: "Cardano", symbol: "ada"),
        WatchlistCoin(id: "polkadot", name: "Polkadot", symbol: "dot")
    ]
    
    init() {
        load()
    }
    
    func add(_ coin: WatchlistCoin) {
        guard !coins.contains(where: { $0.id == coin.id }) else { return }
        coins.append(coin)
        save()
    }
    
    func remove(_ coin: WatchlistCoin) {
        coins.removeAll { $0.id == coin.id }
        save()
    }
    
    func remove(at offsets: IndexSet) {
        coins.remove(atOffsets: offsets)
        save()
    }
    
    func reset() {
        coins = defaults
        save()
    }
    
    var coinIds: [String] {
        coins.map { $0.id }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(coins) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([WatchlistCoin].self, from: data) {
            coins = decoded.isEmpty ? defaults : decoded
        } else {
            coins = defaults
        }
    }
}
