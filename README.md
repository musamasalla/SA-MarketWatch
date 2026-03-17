# 🇿🇦 SA Market Watch

A beautiful iOS app for South African market data — crypto prices (BTC/ETH/ZAR), fuel price forecasts, and breaking market news.

**Built entirely by Greg AI** 🦾 — from scratch, no human code.

## Features

- 📊 **Live Crypto Prices** — BTC, ETH, SOL, ADA, DOT and more in ZAR
- 🔔 **Price Alerts** — Set targets, get notified when hit
- 🔍 **Coin Search** — Search 10,000+ coins via CoinGecko
- ⛽ **Fuel Price Tracker** — Monthly fuel price predictions
- 📰 **Market News** — Curated financial news for SA
- 📴 **Offline Mode** — Cached prices work without internet
- 🌙 **Dark Mode** — Native iOS dark mode support
- 🔄 **Pull-to-Refresh** — Live data on demand

## Tech Stack

- SwiftUI (iOS 17+)
- MVVM Architecture
- Async/Await
- CoinGecko API (free, no key needed)
- Offline disk caching
- UserDefaults for persistence
- GitHub Actions CI

## Architecture

```
SA-MarketWatch/
├── App/
│   └── SA_MarketWatchApp.swift
├── Models/
│   ├── CryptoPrice.swift      — Crypto data model
│   ├── FuelPrice.swift        — Fuel price model
│   ├── NewsItem.swift         — News data model
│   ├── Alert.swift            — Price alerts + store
│   └── CoinSearch.swift       — Search + watchlist
├── ViewModels/
│   ├── CryptoViewModel.swift
│   ├── FuelViewModel.swift
│   ├── NewsViewModel.swift
│   └── CoinSearchViewModel.swift (inline)
├── Views/
│   ├── ContentView.swift      — Tab navigation
│   ├── CryptoView.swift       — Crypto + alerts integration
│   ├── FuelView.swift         — Fuel prices
│   ├── NewsView.swift         — News with filters
│   ├── CoinSearchView.swift   — Search & add coins
│   └── AlertView.swift        — Create/manage alerts
├── Services/
│   ├── APIService.swift       — Network layer + offline cache
│   └── CacheService.swift     — In-memory cache with TTL
└── Utilities/
    └── Extensions.swift       — Helpers
```

## Development

This app was built autonomously by Greg AI using a simulated dev team approach:
- **Project Manager**: Feature planning & prioritization
- **Senior Dev**: Architecture decisions & complex features
- **Junior Dev**: UI implementation & data models
- **QA**: Error handling & edge cases
- **Code Reviewer**: Code quality & best practices

## Requirements

- iOS 17.0+
- Xcode 15+
- No API keys needed

## License

MIT — Built by Greg AI 🦾
