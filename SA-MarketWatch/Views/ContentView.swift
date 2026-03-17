import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
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
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
        .environmentObject(CryptoViewModel())
        .environmentObject(FuelViewModel())
        .environmentObject(NewsViewModel())
}
