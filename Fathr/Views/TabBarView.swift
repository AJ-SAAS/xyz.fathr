import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel
    @State private var selectedTab: Int = 0
    @State private var showPaywall: Bool = false

    // Set to false to re-enable paywall
    private let isPaywallDisabledForTesting = false

    var body: some View {
        GeometryReader { geometry in
            TabView(selection: Binding(
                get: { selectedTab },
                set: { newValue in
                    if isPaywallDisabledForTesting || newValue != 1 || purchaseModel.isSubscribed {
                        selectedTab = newValue
                    } else {
                        showPaywall = true
                    }
                }
            )) {
                DashboardView(selectedTab: $selectedTab)
                    .tabItem {
                        Label("Home", systemImage: "house")
                            .font(.system(.body, design: .default, weight: .regular))
                    }
                    .environmentObject(testStore)
                    .environmentObject(purchaseModel)
                    .tag(0)
                    .padding(.bottom, geometry.size.width > 600 ? 20 : 10)

                TrackView()
                    .tabItem {
                        Label("Track", systemImage: "plus.circle")
                            .font(.system(.body, design: .default, weight: .regular))
                    }
                    .environmentObject(testStore)
                    .environmentObject(purchaseModel)
                    .tag(1)
                    .padding(.bottom, geometry.size.width > 600 ? 20 : 10)

                SettingsView()
                    .tabItem {
                        Label("More", systemImage: "gear")
                            .font(.system(.body, design: .default, weight: .regular))
                    }
                    .environmentObject(testStore)
                    .environmentObject(purchaseModel)
                    .tag(2)
                    .padding(.bottom, geometry.size.width > 600 ? 20 : 10)
            }
            .sheet(isPresented: $showPaywall) {
                PurchaseView(isPresented: $showPaywall, purchaseModel: purchaseModel)
            }
            .padding(.bottom, geometry.size.width > 600 ? 20 : 0)
        }
    }
}

#Preview("iPhone 14") {
    let purchaseModel = PurchaseModel()
    purchaseModel.isSubscribed = false // Simulate non-subscribed state
    return TabBarView()
        .environmentObject(AuthManager())
        .environmentObject(TestStore())
        .environmentObject(purchaseModel)
}

#Preview("iPad Pro") {
    let purchaseModel = PurchaseModel()
    purchaseModel.isSubscribed = false // Simulate non-subscribed state
    return TabBarView()
        .environmentObject(AuthManager())
        .environmentObject(TestStore())
        .environmentObject(purchaseModel)
}
