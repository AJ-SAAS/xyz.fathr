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
struct Fathr_AppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var authManager = AuthManager()
    @StateObject private var testStore = TestStore()
    @StateObject private var purchaseModel = PurchaseModel()

    init() {
        // Note: Remove these UserDefaults resets in production to preserve user state
        // UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        // UserDefaults.standard.removeObject(forKey: "lastTipDate")

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

