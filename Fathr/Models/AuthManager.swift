import FirebaseAuth
import FirebaseFirestore
import Foundation

class AuthManager: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var errorMessage: String?
    var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }
    private var authListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        checkAuthState()
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            let isSignedIn = user != nil
            print("AuthManager: Auth state changed, isSignedIn = \(isSignedIn), user = \(user?.uid ?? "none")")
            self?.isSignedIn = isSignedIn
        }
    }

    func checkAuthState() {
        let user = Auth.auth().currentUser
        isSignedIn = user != nil
        print("AuthManager: checkAuthState, isSignedIn = \(isSignedIn), user = \(user?.uid ?? "none")")
    }

    func signIn(email: String, password: String) {
        errorMessage = nil
        print("AuthManager: Attempting sign-in with email: \(email)")
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                print("AuthManager: Sign-in error: \(error.localizedDescription)")
                return
            }
            if let result = result {
                self?.isSignedIn = true
                print("AuthManager: Sign-in successful, isSignedIn = true, user = \(result.user.uid)")
            }
        }
    }

    func signUp(email: String, password: String) {
        errorMessage = nil
        print("AuthManager: Attempting sign-up with email: \(email)")
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                print("AuthManager: Sign-up error: \(error.localizedDescription)")
                return
            }
            if let result = result {
                self?.isSignedIn = true
                print("AuthManager: Sign-up successful, user = \(result.user.uid)")
            }
        }
    }

    func resetPassword(email: String) {
        errorMessage = nil
        print("AuthManager: Sending password reset for email: \(email)")
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                print("AuthManager: Reset password error: \(error.localizedDescription)")
                return
            }
            self?.errorMessage = "Password reset email sent"
            print("AuthManager: Password reset email sent successfully")
        }
    }

    func signOut() {
        errorMessage = nil
        do {
            try Auth.auth().signOut()
            isSignedIn = false
            print("AuthManager: Signed out successfully")
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
            print("AuthManager: Sign-out error: \(error.localizedDescription)")
        }
    }

    func deleteAccount(completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            print("AuthManager: No user logged in for account deletion")
            completion(error)
            return
        }

        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(user.uid)

        print("AuthManager: Deleting Firestore data for user \(user.uid)")
        userDocRef.delete { error in
            if let error = error {
                print("AuthManager: Error deleting Firestore data: \(error.localizedDescription)")
                completion(error)
                return
            }

            print("AuthManager: Deleting Firebase user \(user.uid)")
            user.delete { error in
                if let error = error {
                    print("AuthManager: Error deleting Firebase user: \(error.localizedDescription)")
                    completion(error)
                    return
                }

                self.isSignedIn = false
                self.errorMessage = nil
                print("AuthManager: Account deleted successfully")
                completion(nil)
            }
        }
    }
}
