import Foundation

class CacheService {
    static let shared = CacheService()
    
    private var cache: [String: (value: Any, timestamp: Date)] = [:]
    
    private init() {}
    
    func get<T>(_ key: String) -> T? {
        cache[key]?.value as? T
    }
    
    func set(_ key: String, value: Any) {
        cache[key] = (value, Date())
    }
    
    func isExpired(_ key: String, ttl: TimeInterval) -> Bool {
        guard let entry = cache[key] else { return true }
        return Date().timeIntervalSince(entry.timestamp) > ttl
    }
    
    func clear() {
        cache.removeAll()
    }
}
