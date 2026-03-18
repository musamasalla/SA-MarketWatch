import Foundation
import Combine

// MARK: - API Error Types

enum APIError: LocalizedError, Equatable {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed(reason: String)
    case networkUnavailable
    case rateLimited(retryAfter: TimeInterval)
    case serverError(message: String)
    case timeout
    case cancelled
    case unknown(description: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .requestFailed(let code): return "Request failed (HTTP \(code))"
        case .decodingFailed(let reason): return "Data error: \(reason)"
        case .networkUnavailable: return "No internet connection"
        case .rateLimited(let time): return "Rate limited. Retry in \(Int(time))s"
        case .serverError(let msg): return "Server error: \(msg)"
        case .timeout: return "Request timed out"
        case .cancelled: return "Request cancelled"
        case .unknown(let desc): return desc
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkUnavailable, .timeout, .serverError, .requestFailed(500...599):
            return true
        case .rateLimited:
            return true
        default:
            return false
        }
    }
    
    var iconName: String {
        switch self {
        case .networkUnavailable: return "wifi.slash"
        case .timeout: return "clock.badge.exclamationmark"
        case .rateLimited: return "hourglass"
        case .serverError: return "server.rack"
        default: return "exclamationmark.triangle"
        }
    }
}

// MARK: - API Service

class APIService {
    static let shared = APIService()
    private let session: URLSession
    private let cache = CacheService.shared
    private let decoder = JSONDecoder()
    
    // Rate limiting
    private var lastRequestTime: Date?
    private let minRequestInterval: TimeInterval = 1.0 // CoinGecko free tier: 1 req/sec
    private var requestQueue: [() -> Void] = []
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.waitsForConnectivity = true
        config.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Rate Limited Request
    
    private func rateLimitedRequest<T: Codable>(
        url: URL,
        cacheKey: String? = nil,
        cacheTTL: TimeInterval = 60
    ) async throws -> T {
        // Check cache first
        if let key = cacheKey, let cached: T = cache.get(key), !cache.isExpired(key, ttl: cacheTTL) {
            return cached
        }
        
        // Rate limit
        if let last = lastRequestTime {
            let elapsed = Date().timeIntervalSince(last)
            if elapsed < minRequestInterval {
                try await Task.sleep(nanoseconds: UInt64((minRequestInterval - elapsed) * 1_000_000_000))
            }
        }
        lastRequestTime = Date()
        
        // Make request with retry
        let data = try await requestWithRetry(url: url)
        
        // Decode
        do {
            let decoded = try decoder.decode(T.self, from: data)
            if let key = cacheKey {
                cache.set(key, value: decoded)
                // Also save to disk for offline
                OfflineCache.save(decoded, forKey: key)
            }
            return decoded
        } catch {
            throw APIError.decodingFailed(reason: error.localizedDescription)
        }
    }
    
    // MARK: - Retry Logic
    
    private func requestWithRetry(url: URL, maxRetries: Int = 3) async throws -> Data {
        var lastError: Error?
        
        for attempt in 0..<maxRetries {
            do {
                var request = URLRequest(url: url)
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("SA-MarketWatch/2.0", forHTTPHeaderField: "User-Agent")
                
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown(description: "Invalid response")
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 429:
                    let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                    let delay = Double(retryAfter ?? "60") ?? 60
                    if attempt < maxRetries - 1 {
                        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        continue
                    }
                    throw APIError.rateLimited(retryAfter: delay)
                case 500...599:
                    if attempt < maxRetries - 1 {
                        // Exponential backoff: 1s, 2s, 4s
                        let backoff = pow(2.0, Double(attempt))
                        try await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
                        continue
                    }
                    throw APIError.serverError(message: "HTTP \(httpResponse.statusCode)")
                default:
                    throw APIError.requestFailed(statusCode: httpResponse.statusCode)
                }
            } catch let error as APIError {
                if !error.isRetryable || attempt == maxRetries - 1 {
                    throw error
                }
                lastError = error
            } catch {
                if error is CancellationError {
                    throw APIError.cancelled
                }
                // Network error - retry with backoff
                if attempt < maxRetries - 1 {
                    let backoff = pow(2.0, Double(attempt))
                    try await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
                    lastError = error
                    continue
                }
                lastError = error
            }
        }
        
        throw lastError ?? APIError.unknown(description: "Request failed after \(maxRetries) attempts")
    }
    
    // MARK: - CoinGecko API
    
    func fetchCryptoPrices(ids: [String], currency: String = "zar") async throws -> [CryptoPrice] {
        let idsString = ids.joined(separator: ",")
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=\(currency)&ids=\(idsString)&order=market_cap_desc&sparkline=false&price_change_percentage=24h"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let cacheKey = "crypto_\(currency)_\(idsString.hashValue)"
        
        do {
            let prices: [CryptoPrice] = try await rateLimitedRequest(
                url: url,
                cacheKey: cacheKey,
                cacheTTL: 60
            )
            return prices
        } catch {
            // Try offline cache as last resort
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
    
    func searchCoins(query: String) async throws -> [CoinSearchResult] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.coingecko.com/api/v3/search?query=\(encoded)") else {
            throw APIError.invalidURL
        }
        
        struct SearchResponse: Codable { let coins: [CoinSearchResult] }
        
        let response: SearchResponse = try await rateLimitedRequest(url: url, cacheKey: "search_\(query)", cacheTTL: 300)
        return response.coins
    }
    
    func fetchZARRate() async throws -> Double {
        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=usd&vs_currencies=zar"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        struct ZARResponse: Codable {
            let usd: ZARValue
            struct ZARValue: Codable { let zar: Double }
        }
        
        let response: ZARResponse = try await rateLimitedRequest(url: url, cacheKey: "zar_rate", cacheTTL: 300)
        return response.usd.zar
    }
    
    // MARK: - Background Refresh
    
    func backgroundRefresh(watchlist: WatchlistStore) async {
        do {
            let prices = try await fetchCryptoPrices(ids: watchlist.coinIds)
            // Post notification for UI update
            NotificationCenter.default.post(
                name: NSNotification.Name("CryptoPricesUpdated"),
                object: nil,
                userInfo: ["prices": prices]
            )
        } catch {
            // Silent fail for background refresh
            print("Background refresh failed: \(error)")
        }
    }
}

// MARK: - Offline Disk Cache

class OfflineCache {
    static func save<T: Encodable>(_ value: T, forKey key: String) {
        let url = cacheURL(forKey: key)
        do {
            let data = try JSONEncoder().encode(value)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Cache save failed for \(key): \(error)")
        }
    }
    
    static func load<T: Decodable>(forKey key: String) -> T? {
        let url = cacheURL(forKey: key)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    static func clear(forKey key: String) {
        let url = cacheURL(forKey: key)
        try? FileManager.default.removeItem(at: url)
    }
    
    static func clearAll() {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        try? FileManager.default.removeItem(at: dir.appendingPathComponent("sa_marketwatch_"))
    }
    
    private static func cacheURL(forKey key: String) -> URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("sa_marketwatch_\(key).json")
    }
}
