import SwiftUI
import FirebaseFirestore

struct RootView: View {

    @State private var hasCompletedOnboarding: Bool = false
    @State private var showSplash: Bool = true
    @State private var showAuth: Bool = false

    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel

    var body: some View {
        Group {

            // MARK: Splash
            if showSplash {
                SplashScreen {
                    showSplash = false
                }
            }

            // MARK: Onboarding
            else if !hasCompletedOnboarding {

                OnboardingView(
                    hasCompletedOnboarding: $hasCompletedOnboarding,
                    onComplete: {
                        showAuth = true
                    }
                )
                .environmentObject(purchaseModel)
            }

            // MARK: Auth
            else if showAuth {

                AuthView(onAuthSuccess: {
                    showAuth = false
                })
                .environmentObject(authManager)
                .environmentObject(testStore)
                .environmentObject(purchaseModel)
            }

            // MARK: Home / Dashboard
            else {
                TabBarView()
                    .environmentObject(authManager)
                    .environmentObject(testStore)
                    .environmentObject(purchaseModel)
            }
        }

        // MARK: Auth listener
        .onChange(of: authManager.user) { _, user in
            guard user != nil else { return }
            loadOnboardingStatus()
        }

        .onAppear {
            setup()
        }
    }

    private func setup() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if authManager.user != nil {
                loadOnboardingStatus()
            }
        }
    }

    // MARK: Load Onboarding Status from Firestore
    private func loadOnboardingStatus() {
        guard let uid = authManager.currentUserID else {
            hasCompletedOnboarding = false
            return
        }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                
                if let data = snapshot?.data(),
                   let completed = data["hasCompletedOnboarding"] as? Bool {
                    DispatchQueue.main.async {
                        self.hasCompletedOnboarding = completed
                        print("✅ Onboarding status loaded: \(completed)")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.hasCompletedOnboarding = false
                        print("ℹ️ No onboarding completion flag found")
                    }
                }
            }
    }
}
