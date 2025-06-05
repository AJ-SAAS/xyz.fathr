import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel
    @State private var selectedTab: Int = 0
    @State private var showPaywall: Bool = false

    var body: some View {
        GeometryReader { geometry in
            TabView(selection: Binding(
                get: { selectedTab },
                set: { newValue in
                    if newValue == 1 && !purchaseModel.isSubscribed {
                        showPaywall = true
                    } else {
                        selectedTab = newValue
                    }
                }
            )) {
                DashboardView(selectedTab: $selectedTab)
                    .tabItem {
                        Label("Home", systemImage: "house")
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                    }
                    .environmentObject(testStore)
                    .environmentObject(purchaseModel)
                    .tag(0)
                    .padding(.bottom, geometry.size.width > 600 ? 20 : 10) // Adjust for iPad

                TrackView()
                    .tabItem {
                        Label("Track", systemImage: "plus.circle")
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                    }
                    .environmentObject(testStore)
                    .environmentObject(purchaseModel)
                    .tag(1)
                    .padding(.bottom, geometry.size.width > 600 ? 20 : 10) // Adjust for iPad

                SettingsView()
                    .tabItem {
                        Label("More", systemImage: "gear")
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                    }
                    .environmentObject(testStore)
                    .environmentObject(purchaseModel)
                    .tag(2)
                    .padding(.bottom, geometry.size.width > 600 ? 20 : 10) // Adjust for iPad
            }
            .sheet(isPresented: $showPaywall) {
                PurchaseView(isPresented: $showPaywall, purchaseModel: purchaseModel)
            }
            .padding(.bottom, geometry.size.width > 600 ? 20 : 0) // Adjust tab bar padding for iPad
        }
    }
}

#Preview("iPhone 14") {
    TabBarView()
        .environmentObject(AuthManager())
        .environmentObject(TestStore())
        .environmentObject(PurchaseModel())
}

#Preview("iPad Pro") {
    TabBarView()
        .environmentObject(AuthManager())
        .environmentObject(TestStore())
        .environmentObject(PurchaseModel())
}
