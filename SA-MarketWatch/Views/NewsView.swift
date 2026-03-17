import SwiftUI

struct NewsView: View {
    @EnvironmentObject var viewModel: NewsViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Category Filter
                    categoryFilter
                    
                    // News Items
                    ForEach(viewModel.filteredItems) { item in
                        NewsCard(item: item)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("📰 Market News")
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All button
                FilterChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.filter(by: nil)
                }
                
                ForEach(NewsItem.Category.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.filter(by: category == viewModel.selectedCategory ? nil : category)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.orange : Color(.systemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct NewsCard: View {
    let item: NewsItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: item.category.icon)
                    .font(.caption)
                    .foregroundColor(colorForCategory)
                Text(item.category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(colorForCategory)
                Spacer()
                Text(item.timeAgo)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(item.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(item.summary)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Text(item.source)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var colorForCategory: Color {
        switch item.category {
        case .crypto: return .orange
        case .markets: return .blue
        case .fuel: return .green
        case .economy: return .purple
        case .breaking: return .red
        }
    }
}

#Preview {
    NewsView()
        .environmentObject(NewsViewModel())
}
