import Foundation

class APIService {
    static let shared = APIService()
    private let session = URLSession.shared
    private let cache = CacheService.shared
    
    private init() {}
    
    // MARK: - CoinGecko API (Free, no key)
    
    func fetchCryptoPrices(ids: [String] = ["bitcoin", "ethereum", "solana", "cardano", "polkadot"], currency: String = "zar") async throws -> [CryptoPrice] {
        let idsString = ids.joined(separator: ",")
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=\(currency)&ids=\(idsString)&order=market_cap_desc&sparkline=false&price_change_percentage=24h"
        
        // Check cache first (60 second TTL)
        if let cached: [CryptoPrice] = cache.get("crypto_\(currency)"),
           !cache.isExpired("crypto_\(currency)", ttl: 60) {
            return cached
        }
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                // Return cached data if available, even expired
                if let cached: [CryptoPrice] = cache.get("crypto_\(currency)") {
                    return cached
                }
                throw APIError.requestFailed
            }
            
            let prices = try JSONDecoder().decode([CryptoPrice].self, from: data)
            cache.set("crypto_\(currency)", value: prices)
            
            // Also save to disk for offline access
            OfflineCache.save(prices, forKey: "crypto_prices")
            
            return prices
        } catch {
            // On error, try disk cache
            if let offline: [CryptoPrice] = OfflineCache.load(forKey: "crypto_prices") {
                return offline
            }
            throw error
        }
    }
    
    func fetchCustomCoins(ids: [String], currency: String = "zar") async throws -> [CryptoPrice] {
        guard !ids.isEmpty else { return [] }
        return try await fetchCryptoPrices(ids: ids, currency: currency)
    }
    
    // MARK: - Search Coins
    
    func searchCoins(query: String) async throws -> [CoinSearchResult] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.coingecko.com/api/v3/search?query=\(encoded)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(CoinSearchResponse.self, from: data)
        return response.coins
    }
    
    // MARK: - Fetch ZAR/USD Rate
    
    func fetchZARRate() async throws -> Double {
        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=usd&vs_currencies=zar"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let usd = json?["usd"] as? [String: Any],
              let zar = usd["zar"] as? Double else {
            throw APIError.decodingFailed
        }
        
        return zar
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case requestFailed
    case decodingFailed
    case offline
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .requestFailed: return "Network request failed"
        case .decodingFailed: return "Failed to decode response"
        case .offline: return "You're offline. Showing cached data."
        }
    }
}

// MARK: - Offline Disk Cache

class OfflineCache {
    static func save<T: Encodable>(_ value: T, forKey key: String) {
        let url = cacheURL(forKey: key)
        if let data = try? JSONEncoder().encode(value) {
            try? data.write(to: url)
        }
    }
    
    static func load<T: Decodable>(forKey key: String) -> T? {
        let url = cacheURL(forKey: key)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    private static func cacheURL(forKey key: String) -> URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("sa_marketwatch_\(key).json")
    }
}
