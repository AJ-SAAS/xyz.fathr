import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel
    @State private var selectedTab: Int = 0 // Added for tab navigation

    var body: some View {
        if authManager.isSignedIn {
            TabView(selection: $selectedTab) {
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
            .environmentObject(authManager)
        } else {
            AuthView()
                .environmentObject(authManager)
                .environmentObject(purchaseModel)
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
