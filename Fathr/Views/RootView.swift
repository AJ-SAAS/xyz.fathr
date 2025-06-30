import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RootView: View {
    @State private var hasCompletedOnboarding: Bool = false
    @State private var showSplash: Bool = true
    @State private var showSignUpScreen: Bool = false
    @State private var showAuth: Bool = false
    @State private var isLoading: Bool = true
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .accessibilityLabel("Loading app state")
            } else if showSplash {
                OB1_SplashScreen {
                    showSplash = false
                    showSignUpScreen = true
                }
            } else if showSignUpScreen {
                OB2_SignupScreen {
                    showSignUpScreen = false
                    showAuth = true
                }
            } else if showAuth || !authManager.isSignedIn {
                AuthView(onAuthSuccess: {
                    loadOnboardingStatus()
                })
                .environmentObject(purchaseModel)
            } else if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding) {
                    saveOnboardingStatus()
                }
            } else {
                TabBarView()
                    .environmentObject(authManager)
                    .environmentObject(testStore)
                    .environmentObject(purchaseModel)
            }
        }
        .onChange(of: authManager.isSignedIn) { _, newValue in
            print("RootView: isSignedIn changed to \(newValue), hasCompletedOnboarding: \(hasCompletedOnboarding)")
            if newValue {
                showAuth = false
                showSplash = false
                showSignUpScreen = false
                isLoading = true // Ensure loading state until Firestore fetch completes
                loadOnboardingStatus()
            } else {
                showAuth = true
                showSplash = false
                showSignUpScreen = false
                isLoading = false
            }
        }
        .onAppear {
            print("RootView: onAppear, isSignedIn: \(authManager.isSignedIn), hasCompletedOnboarding: \(hasCompletedOnboarding)")
            if authManager.isSignedIn {
                isLoading = true
                loadOnboardingStatus()
            } else {
                isLoading = false
                showSplash = true
                showAuth = false
                showSignUpScreen = false
            }
        }
    }

    private func loadOnboardingStatus(retryCount: Int = 0, maxRetries: Int = 3) {
        guard let userId = authManager.currentUserID else {
            print("RootView: No user ID, setting isLoading = false, hasCompletedOnboarding = false")
            isLoading = false
            hasCompletedOnboarding = false
            return
        }
        print("RootView: Loading onboarding status for user \(userId), attempt \(retryCount + 1)")
        Firestore.firestore().collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("RootView: Error loading onboarding status: \(error.localizedDescription)")
                if retryCount < maxRetries {
                    print("RootView: Retrying loadOnboardingStatus, attempt \(retryCount + 2)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        loadOnboardingStatus(retryCount: retryCount + 1, maxRetries: maxRetries)
                    }
                    return
                } else {
                    print("RootView: Max retries reached, defaulting to hasCompletedOnboarding = false")
                    isLoading = false
                    hasCompletedOnboarding = false
                    return
                }
            }
            if let data = snapshot?.data(), let completed = data["hasCompletedOnboarding"] as? Bool {
                print("RootView: Loaded hasCompletedOnboarding = \(completed) from Firestore")
                hasCompletedOnboarding = completed
            } else {
                print("RootView: No onboarding data found, defaulting to false")
                hasCompletedOnboarding = false
            }
            isLoading = false
        }
    }

    private func saveOnboardingStatus() {
        guard let userId = authManager.currentUserID else {
            print("RootView: No user ID, cannot save onboarding status")
            return
        }
        print("RootView: Saving hasCompletedOnboarding = true for user \(userId)")
        Firestore.firestore().collection("users").document(userId).setData([
            "hasCompletedOnboarding": true
        ], merge: true) { error in
            if let error = error {
                print("RootView: Error saving onboarding status: \(error.localizedDescription)")
            } else {
                print("RootView: Successfully saved hasCompletedOnboarding = true")
                hasCompletedOnboarding = true
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
