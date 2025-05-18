import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @State private var showSplashScreen = true
    
    var body: some View {
        ZStack {
            if showSplashScreen {
                SplashScreen()
                    .transition(.opacity)
            } else {
                Group {
                    if !hasCompletedOnboarding {
                        OnboardingView()
                    } else if !authManager.isSignedIn || Auth.auth().currentUser?.isAnonymous == true {
                        AuthView()
                    } else {
                        TabBarView()
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showSplashScreen)
        .onAppear {
            print("RootView: hasCompletedOnboarding = \(hasCompletedOnboarding), isSignedIn = \(authManager.isSignedIn), isAnonymous = \(Auth.auth().currentUser?.isAnonymous ?? false)")
            // Show splash screen for 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showSplashScreen = false
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
