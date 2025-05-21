import SwiftUI
import FirebaseAuth

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showSplash: Bool = true
    @State private var showSignUpScreen: Bool = false
    @State private var showAuth: Bool = false
    @State private var isLoggedIn: Bool = false
    @State private var selectedTab: Int = 0 // For TabBarView tab selection
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
            } else if showAuth || (!isLoggedIn && hasCompletedOnboarding) {
                AuthView(onAuthSuccess: {
                    isLoggedIn = true
                    showAuth = false
                })
            } else if !hasCompletedOnboarding {
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
        .onAppear {
            // Check Firebase Auth state
            if Auth.auth().currentUser != nil {
                isLoggedIn = true
                showAuth = false
                showSplash = false
                showSignUpScreen = false
            } else {
                isLoggedIn = false
                showAuth = hasCompletedOnboarding
                showSplash = !hasCompletedOnboarding
                showSignUpScreen = false
            }
        }
        .onChange(of: Auth.auth().currentUser) { _, newUser in
            // Handle auth state changes (e.g., sign-out)
            isLoggedIn = newUser != nil
            if newUser == nil {
                showAuth = hasCompletedOnboarding
                showSplash = !hasCompletedOnboarding
                showSignUpScreen = false
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthManager())
        .environmentObject(TestStore())
        .environmentObject(PurchaseModel())
}
