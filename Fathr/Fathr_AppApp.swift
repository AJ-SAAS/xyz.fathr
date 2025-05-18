import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics
import RevenueCat

@main
struct Sperm_Test_Results_AppApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var testStore = TestStore()
    @StateObject private var purchaseModel = PurchaseModel()

    init() {
        // Debug: Reset UserDefaults for testing
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "lastTipDate")

        // Initialize Firebase
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(false)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)

        // Initialize RevenueCat
        Purchases.configure(withAPIKey: "appl_rhIxpzSZfMAgajJHLURLcNHmThg")
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .environmentObject(testStore)
                .environmentObject(purchaseModel)
                .onAppear {
                    // Sync RevenueCat with Firebase user ID
                    if let userID = authManager.currentUserID {
                        Purchases.shared.logIn(userID) { (customerInfo, created, error) in
                            if let error = error {
                                print("RevenueCat login error: \(error.localizedDescription)")
                            } else {
                                print("RevenueCat logged in user: \(userID)")
                            }
                        }
                    }
                }
        }
    }
}
