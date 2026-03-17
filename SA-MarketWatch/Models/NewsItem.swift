import Foundation

struct NewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let timeAgo: String
    let category: Category
    let url: String
    
    enum Category: String, CaseIterable {
        case crypto = "Crypto"
        case markets = "Markets"
        case fuel = "Fuel"
        case economy = "Economy"
        case breaking = "Breaking"
        
        var icon: String {
            switch self {
            case .crypto: return "bitcoinsign.circle.fill"
            case .markets: return "chart.line.uptrend.xyaxis"
            case .fuel: return "fuelpump.fill"
            case .economy: return "building.columns.fill"
            case .breaking: return "bolt.fill"
            }
        }
        
        var color: String {
            switch self {
            case .crypto: return "orange"
            case .markets: return "blue"
            case .fuel: return "green"
            case .economy: return "purple"
            case .breaking: return "red"
            }
        }
    }
}

struct NewsData {
    static let sample: [NewsItem] = [
        NewsItem(
            title: "SA Rejects US Pressure on Iran Ties",
            summary: "South Africa says it has no reason to cut ties with Iran despite US ambassador pressure.",
            source: "Reuters",
            timeAgo: "2h ago",
            category: .breaking,
            url: "https://reuters.com"
        ),
        NewsItem(
            title: "BTC Holds Above $75K Amid Geopolitical Tensions",
            summary: "Bitcoin remains stable despite Middle East escalation. Analysts see $80K target.",
            source: "CoinDesk",
            timeAgo: "4h ago",
            category: .crypto,
            url: "https://coindesk.com"
        ),
        NewsItem(
            title: "Fuel Prices Expected to Drop in April",
            summary: "Lower oil prices could bring relief at the pump. Predicted R0.35/L decrease.",
            source: "BusinessTech",
            timeAgo: "6h ago",
            category: .fuel,
            url: "https://businesstech.co.za"
        ),
        NewsItem(
            title: "Rand Strengthens Against Dollar",
            summary: "ZAR gains 1.2% as risk sentiment improves. USD/ZAR at 18.45.",
            source: "Moneyweb",
            timeAgo: "8h ago",
            category: .markets,
            url: "https://moneyweb.co.za"
        ),
        NewsItem(
            title: "Woolworths Acquires in2food Holdings",
            summary: "Retail giant buys longtime supplier in strategic consolidation move.",
            source: "CNBC Africa",
            timeAgo: "1h ago",
            category: .economy,
            url: "https://cnbcafrica.com"
        )
    ]
}
