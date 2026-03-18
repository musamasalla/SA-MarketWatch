//
//  DesignSystem.swift
//  SA Market Watch
//
//  South African market-inspired design system
//  Colors: SA flag greens & golds, ZAR currency theme
//

import SwiftUI

// MARK: - Color Palette

extension Color {
    // Primary Colors (SA-inspired)
    static let saDeepGreen = Color(hex: "1B5E20")
    static let saForest = Color(hex: "2E7D32")
    static let saGreen = Color(hex: "4CAF50")
    static let saMint = Color(hex: "81C784")
    static let saLightMint = Color(hex: "E8F5E9")
    
    // Gold/ZA Colors
    static let saGold = Color(hex: "D4A017")
    static let saBrightGold = Color(hex: "FFB300")
    static let saLightGold = Color(hex: "FFF8E1")
    
    // Semantic Colors
    static let saPrimary = Color.saForest
    static let saSecondary = Color.saGold
    static let saAccent = Color.saBrightGold
    
    // Market Colors
    static let saBull = Color(hex: "2E7D32")      // Green - price up
    static let saBear = Color(hex: "C62828")      // Red - price down
    static let saNeutral = Color(hex: "757575")    // Gray - no change
    
    // Status Colors
    static let saSuccess = Color(hex: "4CAF50")
    static let saWarning = Color(hex: "FF9800")
    static let saDanger = Color(hex: "E53935")
    static let saInfo = Color(hex: "2196F3")
    
    // Background Colors
    static let saBackground = Color(hex: "F5F5F0")
    static let saCardBackground = Color.white
    static let saSurfaceSecondary = Color(hex: "EEEEEE")
    static let saGroupedBackground = Color(hex: "F0F0EB")
    
    // Text Colors
    static let saTextPrimary = Color(hex: "1A1A1A")
    static let saTextSecondary = Color(hex: "616161")
    static let saTextTertiary = Color(hex: "9E9E9E")
    
    // Dark Mode Colors
    static let saDarkBackground = Color(hex: "121212")
    static let saDarkSurface = Color(hex: "1E1E1E")
    static let saDarkCard = Color(hex: "2C2C2C")
    static let saDarkTextPrimary = Color(hex: "FAFAFA")
    static let saDarkTextSecondary = Color(hex: "B0B0B0")
    
    // MARK: - Hex Initializer
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography

extension Font {
    // Display
    static let saDisplayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let saDisplayMedium = Font.system(size: 28, weight: .bold, design: .rounded)
    static let saDisplaySmall = Font.system(size: 24, weight: .semibold, design: .rounded)
    
    // Headings
    static let saHeadingLarge = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let saHeadingMedium = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let saHeadingSmall = Font.system(size: 18, weight: .medium, design: .rounded)
    
    // Body
    static let saBodyLarge = Font.system(size: 17, weight: .regular)
    static let saBodyMedium = Font.system(size: 16, weight: .regular)
    static let saBodySmall = Font.system(size: 15, weight: .regular)
    
    // UI
    static let saButton = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let saCaption = Font.system(size: 13, weight: .medium)
    static let saLabel = Font.system(size: 14, weight: .medium)
    
    // Market Data
    static let saPrice = Font.system(size: 20, weight: .bold, design: .monospaced)
    static let saPriceLarge = Font.system(size: 28, weight: .bold, design: .monospaced)
    static let saTicker = Font.system(size: 14, weight: .bold, design: .monospaced)
    static let saMarketData = Font.system(size: 12, weight: .medium, design: .monospaced)
}

// MARK: - Spacing (8pt grid)

enum SASpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius

enum SARadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xl: CGFloat = 20
    static let full: CGFloat = 100
}

// MARK: - Shadows

extension View {
    func saShadowLight() -> some View {
        self.shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    func saShadowMedium() -> some View {
        self.shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
    }
    
    func saShadowStrong() -> some View {
        self.shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 12)
    }
}

// MARK: - Button Styles

struct SAPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.saButton)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: SARadius.large)
                    .fill(isEnabled ? Color.saPrimary : Color.saTextTertiary)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SASecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.saButton)
            .foregroundColor(.saPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: SARadius.large)
                    .stroke(Color.saPrimary, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SAGoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.saButton)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [Color.saGold, Color.saBrightGold],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipShape(RoundedRectangle(cornerRadius: SARadius.large))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SASmallButtonStyle: ButtonStyle {
    var color: Color = .saPrimary
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.saLabel)
            .foregroundColor(.white)
            .padding(.horizontal, SASpacing.md)
            .padding(.vertical, SASpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: SARadius.small)
                    .fill(color)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Card Components

struct SACard<Content: View>: View {
    let content: Content
    var padding: CGFloat = SASpacing.md
    
    init(padding: CGFloat = SASpacing.md, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(Color.saCardBackground)
            .cornerRadius(SARadius.large)
            .saShadowLight()
    }
}

struct SAMarketCard<Content: View>: View {
    let content: Content
    let isPositive: Bool?
    
    init(isPositive: Bool? = nil, @ViewBuilder content: () -> Content) {
        self.isPositive = isPositive
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if let positive = isPositive {
                Rectangle()
                    .fill(positive ? Color.saBull : Color.saBear)
                    .frame(width: 4)
            }
            
            content
                .padding(SASpacing.md)
        }
        .background(Color.saCardBackground)
        .cornerRadius(SARadius.medium)
        .saShadowLight()
    }
}

// MARK: - Text Fields

struct SATextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var icon: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: SASpacing.xs) {
            Text(title)
                .font(.saLabel)
                .foregroundColor(.saTextSecondary)
            
            HStack(spacing: SASpacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.saTextTertiary)
                }
                
                TextField(placeholder, text: $text)
                    .font(.saBodyLarge)
            }
            .padding(SASpacing.md)
            .background(Color.saSurfaceSecondary)
            .cornerRadius(SARadius.medium)
        }
    }
}

struct SASearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    
    var body: some View {
        HStack(spacing: SASpacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.saTextTertiary)
            
            TextField(placeholder, text: $text)
                .font(.saBodyLarge)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.saTextTertiary)
                }
            }
        }
        .padding(SASpacing.md)
        .background(Color.saSurfaceSecondary)
        .cornerRadius(SARadius.medium)
    }
}

// MARK: - Empty State

struct SAEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: SASpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(.saTextTertiary)
            
            VStack(spacing: SASpacing.xs) {
                Text(title)
                    .font(.saHeadingMedium)
                    .foregroundColor(.saTextPrimary)
                
                Text(message)
                    .font(.saBodyMedium)
                    .foregroundColor(.saTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let buttonTitle = buttonTitle, let action = buttonAction {
                Button(buttonTitle, action: action)
                    .buttonStyle(SAPrimaryButtonStyle())
                    .frame(width: 200)
            }
        }
        .padding(SASpacing.xl)
    }
}

// MARK: - Loading State

struct SALoadingView: View {
    var message: String = "Loading..."
    
    var body: some View {
        VStack(spacing: SASpacing.md) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.saPrimary)
            
            Text(message)
                .font(.saBodyMedium)
                .foregroundColor(.saTextSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

// MARK: - Error State

struct SAErrorView: View {
    let message: String
    let icon: String
    let retryAction: () -> Void
    
    init(message: String, icon: String = "exclamationmark.triangle.fill", retryAction: @escaping () -> Void) {
        self.message = message
        self.icon = icon
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: SASpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundColor(.saWarning)
            
            Text("Something went wrong")
                .font(.saHeadingSmall)
                .foregroundColor(.saTextPrimary)
            
            Text(message)
                .font(.saCaption)
                .foregroundColor(.saTextSecondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again", action: retryAction)
                .buttonStyle(SASmallButtonStyle())
        }
        .padding(SASpacing.lg)
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

// MARK: - Market Data Components

struct SAPriceChangeBadge: View {
    let change: Double
    var compact: Bool = false
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                .font(.system(size: compact ? 10 : 12, weight: .bold))
            
            Text(formattedChange)
                .font(compact ? .saMarketData : .saCaption)
                .fontWeight(.bold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, compact ? 4 : 6)
        .padding(.vertical, compact ? 2 : 3)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(change >= 0 ? Color.saBull : Color.saBear)
        )
    }
    
    private var formattedChange: String {
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: compact ? "%.1f" : "%.2f", change))%"
    }
}

struct SAMarketStatusBadge: View {
    let isOnline: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isOnline ? Color.saSuccess : Color.saDanger)
                .frame(width: 6, height: 6)
            
            Text(isOnline ? "Live" : "Offline")
                .font(.saCaption)
                .foregroundColor(isOnline ? .saSuccess : .saDanger)
        }
    }
}

// MARK: - Section Headers

struct SASectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.saHeadingSmall)
                    .foregroundColor(.saTextPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.saCaption)
                        .foregroundColor(.saTextSecondary)
                }
            }
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .font(.saCaption)
                    .foregroundColor(.saPrimary)
            }
        }
    }
}

// MARK: - Progress Indicators

struct SAProgressBar: View {
    let progress: Double
    var color: Color = .saPrimary
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: SARadius.full)
                    .fill(Color.saSurfaceSecondary)
                
                RoundedRectangle(cornerRadius: SARadius.full)
                    .fill(color)
                    .frame(width: geometry.size.width * CGFloat(min(max(progress, 0), 1)))
            }
        }
        .frame(height: 6)
    }
}

// MARK: - View Extensions

extension View {
    func saBackground() -> some View {
        self.background(Color.saBackground)
    }
    
    func saGroupedBackground() -> some View {
        self.background(Color.saGroupedBackground)
    }
}

// MARK: - Tab Bar Appearance

struct SATabBarAppearance {
    static func configure() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.saCardBackground)
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.saTextTertiary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.saTextTertiary)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.saPrimary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.saPrimary)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Navigation Bar Appearance

struct SANavigationBarAppearance {
    static func configure() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.saBackground)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color.saTextPrimary)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.saTextPrimary)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
