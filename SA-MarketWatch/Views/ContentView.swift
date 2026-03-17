import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showOnboarding = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CryptoView()
                .tabItem {
                    Label("Crypto", systemImage: "bitcoinsign.circle.fill")
                }
                .tag(0)
            
            FuelView()
                .tabItem {
                    Label("Fuel", systemImage: "fuelpump.fill")
                }
                .tag(1)
            
            NewsView()
                .tabItem {
                    Label("News", systemImage: "newspaper.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(.orange)
        .onAppear {
            if !hasCompletedOnboarding {
                showOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
    }
}

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            icon: "🇿🇦",
            title: "SA Market Watch",
            description: "Your personal South African market dashboard — crypto, fuel, and news in one place.",
            color: .orange
        ),
        OnboardingPage(
            icon: "📊",
            title: "Live Crypto Prices",
            description: "Track Bitcoin, Ethereum, and 10,000+ coins in ZAR. Set price alerts and never miss a move.",
            color: .blue
        ),
        OnboardingPage(
            icon: "⛽",
            title: "Fuel Predictions",
            description: "See monthly fuel price predictions before they're announced. Plan your fill-ups smarter.",
            color: .green
        ),
        OnboardingPage(
            icon: "🔔",
            title: "Smart Alerts",
            description: "Set price targets and get notified. Works offline with cached data when you need it.",
            color: .purple
        )
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Buttons
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation { currentPage -= 1 }
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button("Next") {
                            withAnimation { currentPage += 1 }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    } else {
                        Button("Get Started") {
                            isPresented = false
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .interactiveDismissDisabled()
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text(page.icon)
                .font(.system(size: 80))
            
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
