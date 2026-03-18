//
//  NewsView.swift
//  SA Market Watch
//
//  Refactored with Design System
//

import SwiftUI

struct NewsView: View {
    @EnvironmentObject var viewModel: NewsViewModel
    @EnvironmentObject var haptic: HapticManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SASpacing.md) {
                    // Category Filter
                    categoryFilter
                    
                    // News Items
                    if viewModel.filteredItems.isEmpty {
                        SAEmptyState(
                            icon: "newspaper",
                            title: "No News",
                            message: "No articles in this category yet"
                        )
                    } else {
                        ForEach(viewModel.filteredItems) { item in
                            NewsCard(item: item)
                        }
                    }
                }
                .padding(SASpacing.md)
            }
            .saGroupedBackground()
            .navigationTitle("📰 Market News")
            .refreshable {
                haptic.refresh()
                await viewModel.refresh()
            }
        }
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SASpacing.xs) {
                // All button
                FilterChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    haptic.selection()
                    viewModel.filter(by: nil)
                }
                
                ForEach(NewsItem.Category.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        haptic.selection()
                        viewModel.filter(by: category == viewModel.selectedCategory ? nil : category)
                    }
                }
            }
            .padding(.horizontal, SASpacing.md)
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
                    .font(.saCaption)
                Text(title)
                    .font(.saCaption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, SASpacing.sm)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.saPrimary : Color.saCardBackground)
            )
            .foregroundColor(isSelected ? .white : .saTextPrimary)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.saSurfaceSecondary, lineWidth: 1)
            )
        }
    }
}

struct NewsCard: View {
    let item: NewsItem
    
    var body: some View {
        SACard {
            VStack(alignment: .leading, spacing: SASpacing.sm) {
                // Header
                HStack(spacing: SASpacing.xs) {
                    Image(systemName: item.category.icon)
                        .font(.saCaption)
                        .foregroundColor(colorForCategory)
                    
                    Text(item.category.rawValue)
                        .font(.saCaption)
                        .fontWeight(.medium)
                        .foregroundColor(colorForCategory)
                    
                    Spacer()
                    
                    Text(item.timeAgo)
                        .font(.saCaption)
                        .foregroundColor(.saTextTertiary)
                }
                
                // Title
                Text(item.title)
                    .font(.saHeadingSmall)
                    .foregroundColor(.saTextPrimary)
                    .lineLimit(2)
                
                // Summary
                Text(item.summary)
                    .font(.saBodySmall)
                    .foregroundColor(.saTextSecondary)
                    .lineLimit(2)
                
                // Source
                Text(item.source)
                    .font(.saCaption)
                    .foregroundColor(.saTextTertiary)
            }
        }
    }
    
    private var colorForCategory: Color {
        switch item.category {
        case .crypto: return .saBrightGold
        case .markets: return .saInfo
        case .fuel: return .saGreen
        case .economy: return .saAccent
        case .breaking: return .saDanger
        }
    }
}

#Preview {
    NewsView()
        .environmentObject(NewsViewModel())
        .environmentObject(HapticManager.shared)
}
