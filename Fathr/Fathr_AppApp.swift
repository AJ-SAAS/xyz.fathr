import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics
import RevenueCat
import UIKit

// MARK: - AppDelegate for Light Mode Override
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Force Light Mode for all windows
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
        }
        return true
    }
}

@main
struct FathrApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager = AuthManager()
    @StateObject private var testStore = TestStore()
    @StateObject private var purchaseModel = PurchaseModel()

    init() {
        // Initialize Firebase
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(false) // Consider enabling in production
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false) // Consider enabling in production

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
                    // Sync RevenueCat after auth state is confirmed
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if let userID = authManager.currentUserID {
                            print("FathrApp: Syncing RevenueCat with userID: \(userID)")
                            Purchases.shared.logIn(userID) { (customerInfo, created, error) in
                                if let error = error {
                                    print("FathrApp: RevenueCat login error: \(error.localizedDescription)")
                                } else {
                                    print("FathrApp: RevenueCat logged in user: \(userID), created: \(created)")
                                }
                            }
                        } else {
                            print("FathrApp: No userID for RevenueCat sync")
                        }
                    }
                }
        }
    }
}
