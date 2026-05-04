import FirebaseAuth
import FirebaseFirestore
import Foundation

class AuthManager: ObservableObject {

    @Published var user: User? = Auth.auth().currentUser
    @Published var isSignedIn: Bool = Auth.auth().currentUser != nil
    @Published var isGuest: Bool = false
    @Published var errorMessage: String?

    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    private let testStore: TestStore

    var currentUserID: String? {
        user?.uid
    }

    init() {
        self.testStore = TestStore()
        listenToAuth()
    }

    private func listenToAuth() {
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isSignedIn = user != nil
                print("🔑 Auth changed:", user?.uid ?? "nil")
            }
        }
    }

    // MARK: Guest
    func continueAsGuest() {
        isGuest = true
        isSignedIn = true
    }

    // MARK: Sign In
    func signIn(email: String, password: String) {
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }

            DispatchQueue.main.async {
                self?.user = result?.user
                self?.isSignedIn = true
                self?.isGuest = false
            }
        }
    }

    // MARK: Sign Up
    func signUp(email: String, password: String) {
        errorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }

            DispatchQueue.main.async {
                self?.user = result?.user
                self?.isSignedIn = true
                self?.isGuest = false
            }
        }
    }

    // MARK: - COMPLETE SIGNUP WITH ONBOARDING DATA
    func completeSignupWithOnboarding() {
        guard let uid = currentUserID else {
            print("⚠️ completeSignupWithOnboarding called but no user ID")
            return
        }
        
        let dataManager = OnboardingDataManager.shared
        
        let userData: [String: Any] = [
            "hasCompletedOnboarding": true,
            "onboardingCompletedAt": Timestamp(),
            "onboardingVersion": 2,
            "journeyStage": dataManager.journeyStage,
            "mainGoal": dataManager.mainGoal,
            "createdAt": Timestamp(),
            "email": Auth.auth().currentUser?.email ?? "",
            "updatedAt": Timestamp()
        ]
        
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .setData(userData, merge: true) { error in
                if let error = error {
                    print("❌ Failed to save onboarding data: \(error.localizedDescription)")
                } else {
                    print("✅ Onboarding data successfully saved to Firestore")
                    dataManager.clearTempData()
                }
            }
    }

    // MARK: Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.user = nil
                self.isSignedIn = false
                self.isGuest = false
                OnboardingDataManager.shared.clearTempData() // Clean up
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Delete Account
    func deleteAccount(completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "", code: -1))
            return
        }

        let uid = user.uid

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .delete { _ in

                user.delete { error in
                    DispatchQueue.main.async {
                        self.user = nil
                        self.isSignedIn = false
                        self.isGuest = false
                        OnboardingDataManager.shared.clearTempData()
                        completion(error)
                    }
                }
            }
    }
}
