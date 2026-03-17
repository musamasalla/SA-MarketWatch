# 🇿🇦 SA Market Watch

A beautiful iOS app for South African market data — crypto prices (BTC/ETH/ZAR), fuel price forecasts, and breaking market news.

Built from scratch by Greg AI 🦾

## Features

- 📊 **Live Crypto Prices** — BTC, ETH, and major coins in ZAR
- ⛽ **Fuel Price Tracker** — Monthly fuel price predictions
- 📰 **Market News** — Curated financial news for SA
- 🔔 **Smart Alerts** — Price movement notifications
- 🌙 **Dark Mode** — Native iOS dark mode support

## Tech Stack

- SwiftUI (iOS 17+)
- MVVM Architecture
- Async/Await
- CoinGecko API (free, no key needed)
- URLSession for networking

## Screenshots

*Coming soon*

## Requirements

- iOS 17.0+
- Xcode 15+
- No API keys needed (uses free public APIs)

## Architecture

```
SA-MarketWatch/
├── App/
│   └── SA_MarketWatchApp.swift
├── Models/
│   ├── CryptoPrice.swift
│   ├── FuelPrice.swift
│   └── NewsItem.swift
├── ViewModels/
│   ├── CryptoViewModel.swift
│   ├── FuelViewModel.swift
│   └── NewsViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── CryptoView.swift
│   ├── FuelView.swift
│   └── NewsView.swift
├── Services/
│   ├── APIService.swift
│   └── CacheService.swift
└── Utilities/
    └── Extensions.swift
```

## License

MIT
