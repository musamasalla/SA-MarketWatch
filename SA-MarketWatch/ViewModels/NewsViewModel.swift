import Foundation
import SwiftUI

@MainActor
class NewsViewModel: ObservableObject {
    @Published var items: [NewsItem] = []
    @Published var selectedCategory: NewsItem.Category?
    @Published var isLoading = false
    
    init() {
        loadNews()
    }
    
    func loadNews() {
        items = NewsData.sample
    }
    
    var filteredItems: [NewsItem] {
        guard let category = selectedCategory else { return items }
        return items.filter { $0.category == category }
    }
    
    func filter(by category: NewsItem.Category?) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedCategory = category
        }
    }
    
    func refresh() async {
        isLoading = true
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        loadNews()
        isLoading = false
    }
}
