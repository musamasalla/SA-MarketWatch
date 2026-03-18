//
//  CoinSearchView.swift
//  SA Market Watch
//
//  Refactored with Design System
//

import SwiftUI

struct CoinSearchView: View {
    @StateObject private var searchVM = CoinSearchViewModel()
    @EnvironmentObject var watchlist: WatchlistStore
    @EnvironmentObject var haptic: HapticManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                if searchVM.isSearching {
                    SALoadingView(message: "Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchVM.results.isEmpty && !searchVM.query.isEmpty {
                    SAEmptyState(
                        icon: "magnifyingglass",
                        title: "No Coins Found",
                        message: "Try a different search term"
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchVM.results.isEmpty {
                    SAEmptyState(
                        icon: "sparkle.magnifyingglass",
                        title: "Search Coins",
                        message: "Search from over 10,000 coins to add to your watchlist"
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(searchVM.results) { coin in
                        CoinSearchRow(
                            coin: coin,
                            isAdded: watchlist.coins.contains(where: { $0.id == coin.id })
                        ) {
                            haptic.success()
                            let watchlistCoin = WatchlistCoin(id: coin.id, name: coin.name, symbol: coin.symbol)
                            watchlist.add(watchlistCoin)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .saBackground()
            .navigationTitle("Add Coin")
            .searchable(text: $searchVM.query, prompt: "Search coins...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        haptic.light()
                        dismiss()
                    }
                    .font(.saButton)
                    .foregroundColor(.saPrimary)
                }
            }
        }
    }
}

struct CoinSearchRow: View {
    let coin: CoinSearchResult
    let isAdded: Bool
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: SASpacing.sm) {
            AsyncImage(url: URL(string: coin.thumb)) { image in
                image.resizable()
            } placeholder: {
                Circle().fill(Color.saSurfaceSecondary)
            }
            .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(coin.name)
                    .font(.saBodyMedium)
                    .fontWeight(.medium)
                    .foregroundColor(.saTextPrimary)
                
                Text(coin.symbol.uppercased())
                    .font(.saTicker)
                    .foregroundColor(.saTextSecondary)
            }
            
            Spacer()
            
            if let rank = coin.marketCapRank {
                Text("#\(rank)")
                    .font(.saCaption)
                    .foregroundColor(.saTextTertiary)
            }
            
            Button(action: onAdd) {
                Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(isAdded ? .saSuccess : .saPrimary)
            }
            .disabled(isAdded)
        }
        .padding(.vertical, 4)
    }
}

@MainActor
class CoinSearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [CoinSearchResult] = []
    @Published var isSearching = false
    
    private var searchTask: Task<Void, Never>?
    
    init() {
        Task {
            for await _ in $query.values.debounce(for: .milliseconds(300), scheduler: DispatchQueue.main) {
                guard !query.isEmpty else {
                    results = []
                    return
                }
                await search()
            }
        }
    }
    
    func search() async {
        searchTask?.cancel()
        searchTask = Task {
            isSearching = true
            
            guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: "https://api.coingecko.com/api/v3/search?query=\(encoded)") else {
                isSearching = false
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if !Task.isCancelled {
                    let response = try JSONDecoder().decode(CoinSearchResponse.self, from: data)
                    results = Array(response.coins.prefix(20))
                }
            } catch {
                if !Task.isCancelled {
                    results = []
                }
            }
            
            isSearching = false
        }
    }
}

#Preview {
    CoinSearchView()
        .environmentObject(WatchlistStore())
        .environmentObject(HapticManager.shared)
}
