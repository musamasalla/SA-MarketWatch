import SwiftUI

struct CoinSearchView: View {
    @StateObject private var searchVM = CoinSearchViewModel()
    @EnvironmentObject var watchlist: WatchlistStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                if searchVM.isSearching {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchVM.results.isEmpty && !searchVM.query.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No coins found")
                            .font(.headline)
                        Text("Try a different search term")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(searchVM.results) { coin in
                        CoinSearchRow(coin: coin, isAdded: watchlist.coins.contains(where: { $0.id == coin.id })) {
                            let watchlistCoin = WatchlistCoin(id: coin.id, name: coin.name, symbol: coin.symbol)
                            watchlist.add(watchlistCoin)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Add Coin")
            .searchable(text: $searchVM.query, prompt: "Search coins...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
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
        HStack {
            AsyncImage(url: URL(string: coin.thumb)) { image in
                image.resizable()
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.3))
            }
            .frame(width: 32, height: 32)
            
            VStack(alignment: .leading) {
                Text(coin.name)
                    .font(.body)
                Text(coin.symbol.uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let rank = coin.marketCapRank {
                Text("#\(rank)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Button(action: onAdd) {
                Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle")
                    .foregroundColor(isAdded ? .green : .blue)
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
        // Debounced search
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
            
            guard let url = URL(string: "https://api.coingecko.com/api/v3/search?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else { return }
            
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
}
