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
        Analytics.setAnalyticsCollectionEnabled(false)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)

        // Initialize RevenueCat - ONLY ONCE here
        Purchases.logLevel = .debug
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        if let userID = authManager.currentUserID, !userID.isEmpty {
                            print("🔑 RevenueCat: Logging in with userID: \(userID)")
                            Task {
                                do {
                                    let (_, created) = try await Purchases.shared.logIn(userID)
                                    print("✅ RevenueCat login successful (new user: \(created))")
                                } catch {
                                    print("❌ RevenueCat login failed: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }
        }
    }
}
