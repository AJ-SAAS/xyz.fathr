import SwiftUI
import FirebaseAuth

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showSplash: Bool = true
    @State private var showSignUpScreen: Bool = true
    @State private var showAuth: Bool = false
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel

    var body: some View {
        Group {
            if showSplash {
                OB1_SplashScreen {
                    showSplash = false
                    showSignUpScreen = true
                }
            } else if showSignUpScreen {
                OB2_SignupScreen {
                    showSignUpScreen = false
                    showAuth = true
                }
            } else if showAuth || (!authManager.isSignedIn && hasCompletedOnboarding) {
                AuthView(onAuthSuccess: {
                    // No need to set isSignedIn here; AuthManager handles it
                })
            } else if !hasCompletedOnboarding && authManager.isSignedIn {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            } else {
                TabBarView()
                    .environmentObject(authManager)
                    .environmentObject(testStore)
                    .environmentObject(purchaseModel)
            }
        }
        .onChange(of: authManager.isSignedIn) { _, newValue in
            if newValue {
                // User is signed in, let hasCompletedOnboarding decide the next view
                showAuth = false
                showSplash = false
                showSignUpScreen = false
            } else {
                // User is signed out
                showAuth = hasCompletedOnboarding
                showSplash = !hasCompletedOnboarding
                showSignUpScreen = false
            }
        }
        .onAppear {
            // Initial auth state is handled by AuthManager
            if authManager.isSignedIn {
                showAuth = false
                showSplash = false
                showSignUpScreen = false
            } else {
                showAuth = hasCompletedOnboarding
                showSplash = !hasCompletedOnboarding
                showSignUpScreen = false
            }
        }
    }
}

#Preview("iPhone 14") {
    RootView()
        .environmentObject(AuthManager())
        .environmentObject(TestStore())
        .environmentObject(PurchaseModel())
}

#Preview("iPad Pro") {
    RootView()
        .environmentObject(AuthManager())
        .environmentObject(TestStore())
        .environmentObject(PurchaseModel())
}
