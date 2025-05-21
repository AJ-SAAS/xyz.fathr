import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel
    @State private var selectedTab: Int = 0
    @State private var showPaywall: Bool = false

    var body: some View {
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
                }
                .environmentObject(testStore)
                .environmentObject(purchaseModel)
                .tag(0)

            TrackView()
                .tabItem {
                    Label("Track", systemImage: "plus.circle")
                }
                .environmentObject(testStore)
                .environmentObject(purchaseModel)
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("More", systemImage: "gear")
                }
                .environmentObject(testStore)
                .environmentObject(purchaseModel)
                .tag(2)
        }
        .sheet(isPresented: $showPaywall) {
            PurchaseView(isPresented: $showPaywall, purchaseModel: purchaseModel)
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
            .environmentObject(AuthManager())
            .environmentObject(TestStore())
            .environmentObject(PurchaseModel())
    }
}
