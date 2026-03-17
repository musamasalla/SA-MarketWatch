import XCTest
@testable import SA_MarketWatch

final class CryptoViewModelTests: XCTestCase {
    
    var viewModel: CryptoViewModel!
    var watchlist: WatchlistStore!
    
    override func setUp() {
        super.setUp()
        viewModel = CryptoViewModel()
        watchlist = WatchlistStore()
    }
    
    override func tearDown() {
        viewModel = nil
        watchlist = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertTrue(viewModel.prices.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.lastUpdated)
        XCTAssertFalse(viewModel.isOffline)
    }
    
    func testDefaultZARRate() {
        XCTAssertEqual(viewModel.zarrate, 18.50)
    }
    
    func testFormattedLastUpdateWhenNever() {
        XCTAssertEqual(viewModel.formattedLastUpdate, "Never")
    }
    
    // MARK: - CryptoPrice Model Tests
    
    func testCryptoPriceDecoding() throws {
        let json = """
        {
            "id": "bitcoin",
            "symbol": "btc",
            "name": "Bitcoin",
            "current_price": 1400000.50,
            "price_change_percentage_24h": 2.5,
            "market_cap": 28000000000000,
            "total_volume": 500000000000,
            "image": "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
        }
        """.data(using: .utf8)!
        
        let price = try JSONDecoder().decode(CryptoPrice.self, from: json)
        
        XCTAssertEqual(price.id, "bitcoin")
        XCTAssertEqual(price.symbol, "btc")
        XCTAssertEqual(price.name, "Bitcoin")
        XCTAssertEqual(price.currentPrice, 1400000.50)
        XCTAssertEqual(price.priceChangePercentage24h, 2.5)
        XCTAssertTrue(price.isPositive)
        XCTAssertTrue(price.formattedPrice.contains("R"))
        XCTAssertTrue(price.formattedChange.contains("+"))
    }
    
    func testCryptoPriceNegativeChange() throws {
        let json = """
        {
            "id": "ethereum",
            "symbol": "eth",
            "name": "Ethereum",
            "current_price": 75000.00,
            "price_change_percentage_24h": -3.2,
            "market_cap": 9000000000000,
            "total_volume": 300000000000,
            "image": "https://example.com/eth.png"
        }
        """.data(using: .utf8)!
        
        let price = try JSONDecoder().decode(CryptoPrice.self, from: json)
        
        XCTAssertFalse(price.isPositive)
        XCTAssertTrue(price.formattedChange.contains("-"))
    }
    
    // MARK: - Alert Store Tests
    
    func testAlertCreation() {
        let alert = PriceAlert(
            coinId: "bitcoin",
            coinName: "Bitcoin",
            targetPrice: 1500000,
            currency: "zar",
            isAbove: true
        )
        
        XCTAssertEqual(alert.coinId, "bitcoin")
        XCTAssertEqual(alert.targetPrice, 1500000)
        XCTAssertTrue(alert.isAbove)
        XCTAssertTrue(alert.isActive)
        XCTAssertFalse(alert.isTriggered)
        XCTAssertTrue(alert.description.contains("above"))
    }
    
    func testAlertAddAndRemove() {
        let store = AlertStore()
        let alert = PriceAlert(
            coinId: "bitcoin",
            coinName: "Bitcoin",
            targetPrice: 1500000,
            isAbove: true
        )
        
        store.add(alert)
        XCTAssertEqual(store.alerts.count, 1)
        
        store.remove(alert)
        XCTAssertTrue(store.alerts.isEmpty)
    }
    
    func testAlertTriggerCheck() {
        let store = AlertStore()
        let alert = PriceAlert(
            coinId: "bitcoin",
            coinName: "Bitcoin",
            targetPrice: 1000,
            isAbove: true
        )
        store.add(alert)
        
        let mockPrice = CryptoPrice(
            id: "bitcoin",
            symbol: "btc",
            name: "Bitcoin",
            currentPrice: 1500,
            priceChangePercentage24h: 5.0,
            marketCap: 1000000,
            totalVolume: 500000,
            image: "https://example.com/btc.png"
        )
        
        let triggered = store.checkAlerts(prices: [mockPrice])
        XCTAssertEqual(triggered.count, 1)
        XCTAssertTrue(triggered.first?.isTriggered ?? false)
    }
    
    func testAlertNoTriggerWhenBelow() {
        let store = AlertStore()
        let alert = PriceAlert(
            coinId: "bitcoin",
            coinName: "Bitcoin",
            targetPrice: 2000,
            isAbove: true
        )
        store.add(alert)
        
        let mockPrice = CryptoPrice(
            id: "bitcoin",
            symbol: "btc",
            name: "Bitcoin",
            currentPrice: 1500,
            priceChangePercentage24h: -2.0,
            marketCap: 1000000,
            totalVolume: 500000,
            image: "https://example.com/btc.png"
        )
        
        let triggered = store.checkAlerts(prices: [mockPrice])
        XCTAssertTrue(triggered.isEmpty)
    }
    
    // MARK: - Watchlist Store Tests
    
    func testWatchlistDefaults() {
        let store = WatchlistStore()
        XCTAssertFalse(store.coins.isEmpty)
        XCTAssertTrue(store.coinIds.contains("bitcoin"))
        XCTAssertTrue(store.coinIds.contains("ethereum"))
    }
    
    func testWatchlistAddCoin() {
        let store = WatchlistStore()
        let initialCount = store.coins.count
        
        let coin = WatchlistCoin(id: "test-coin", name: "Test Coin", symbol: "TEST")
        store.add(coin)
        
        XCTAssertEqual(store.coins.count, initialCount + 1)
        XCTAssertTrue(store.coinIds.contains("test-coin"))
    }
    
    func testWatchlistNoDuplicates() {
        let store = WatchlistStore()
        let initialCount = store.coins.count
        
        let coin = WatchlistCoin(id: "bitcoin", name: "Bitcoin", symbol: "btc")
        store.add(coin) // Already exists in defaults
        
        XCTAssertEqual(store.coins.count, initialCount) // No change
    }
    
    func testWatchlistRemoveCoin() {
        let store = WatchlistStore()
        let coin = WatchlistCoin(id: "test-remove", name: "Test", symbol: "T")
        store.add(coin)
        
        let countAfterAdd = store.coins.count
        store.remove(coin)
        
        XCTAssertEqual(store.coins.count, countAfterAdd - 1)
        XCTAssertFalse(store.coinIds.contains("test-remove"))
    }
    
    // MARK: - API Error Tests
    
    func testAPIErrorDescriptions() {
        XCTAssertNotNil(APIError.invalidURL.errorDescription)
        XCTAssertNotNil(APIError.requestFailed(statusCode: 404).errorDescription)
        XCTAssertNotNil(APIError.networkUnavailable.errorDescription)
        XCTAssertNotNil(APIError.timeout.errorDescription)
        XCTAssertNotNil(APIError.rateLimited(retryAfter: 60).errorDescription)
    }
    
    func testAPIErrorRetryability() {
        XCTAssertTrue(APIError.networkUnavailable.isRetryable)
        XCTAssertTrue(APIError.timeout.isRetryable)
        XCTAssertTrue(APIError.serverError(message: "500").isRetryable)
        XCTAssertFalse(APIError.invalidURL.isRetryable)
        XCTAssertFalse(APIError.decodingFailed(reason: "bad json").isRetryable)
    }
    
    func testAPIErrorIcons() {
        XCTAssertEqual(APIError.networkUnavailable.iconName, "wifi.slash")
        XCTAssertEqual(APIError.timeout.iconName, "clock.badge.exclamationmark")
        XCTAssertEqual(APIError.rateLimited(retryAfter: 30).iconName, "hourglass")
    }
    
    // MARK: - Offline Cache Tests
    
    func testOfflineCacheSaveAndLoad() {
        let testPrices = [
            CryptoPrice(
                id: "bitcoin",
                symbol: "btc",
                name: "Bitcoin",
                currentPrice: 1000000,
                priceChangePercentage24h: 1.5,
                marketCap: 20000000000000,
                totalVolume: 100000000000,
                image: "https://example.com/btc.png"
            )
        ]
        
        OfflineCache.save(testPrices, forKey: "test_prices")
        let loaded: [CryptoPrice]? = OfflineCache.load(forKey: "test_prices")
        
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.count, 1)
        XCTAssertEqual(loaded?.first?.id, "bitcoin")
        
        // Cleanup
        OfflineCache.clear(forKey: "test_prices")
    }
    
    // MARK: - Fuel Price Tests
    
    func testFuelDataNotEmpty() {
        XCTAssertFalse(FuelData.current.isEmpty)
        XCTAssertTrue(FuelData.current.contains { $0.type.contains("Petrol") })
        XCTAssertTrue(FuelData.current.contains { $0.type.contains("Diesel") })
    }
    
    func testFuelPriceFormatting() {
        let fuel = FuelPrice(type: "Petrol 93", currentPrice: 21.45, predictedChange: -0.35, effectiveDate: "April 1")
        XCTAssertTrue(fuel.formattedPrice.contains("R"))
        XCTAssertTrue(fuel.formattedPrice.contains("/L"))
        XCTAssertTrue(fuel.isPositive == false) // Negative change = good news
    }
    
    // MARK: - News Item Tests
    
    func testNewsDataNotEmpty() {
        XCTAssertFalse(NewsData.sample.isEmpty)
    }
    
    func testNewsCategories() {
        let categories = Set(NewsData.sample.map { $0.category })
        XCTAssertFalse(categories.isEmpty)
    }
    
    func testNewsAllCategoriesExist() {
        for category in NewsItem.Category.allCases {
            XCTAssertFalse(category.icon.isEmpty)
        }
    }
}
