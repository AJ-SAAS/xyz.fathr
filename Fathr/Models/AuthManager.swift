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
        // Debug: Sign out to clear user
        try? Auth.auth().signOut()
        if Auth.auth().currentUser != nil {
            isSignedIn = true
        }
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isSignedIn = user != nil
            print("AuthManager: isSignedIn = \(self?.isSignedIn ?? false), user = \(user?.uid ?? "none")")
        }
    }

    func signIn(email: String, password: String) {
        errorMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                print("Sign-in error: \(error.localizedDescription)")
                return
            }
            self?.isSignedIn = true
        }
    }

    func signUp(email: String, password: String) {
        errorMessage = nil
        let oldUserID = Auth.auth().currentUser?.uid
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                print("Sign-up error: \(error.localizedDescription)")
                return
            }
            if let anonymousUser = Auth.auth().currentUser, anonymousUser.isAnonymous, let oldUserID = oldUserID {
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                anonymousUser.link(with: credential) { linkResult, linkError in
                    if let linkError = linkError {
                        self?.errorMessage = "Failed to link account: \(linkError.localizedDescription)"
                        print("Link error: \(linkError.localizedDescription)")
                        return
                    }
                    if let newUserID = linkResult?.user.uid {
                        self?.moveOnboardingAnswers(from: oldUserID, to: newUserID)
                    }
                    self?.isSignedIn = true
                }
            } else {
                self?.isSignedIn = true
            }
        }
    }

    func resetPassword(email: String) {
        errorMessage = nil
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                print("Reset password error: \(error.localizedDescription)")
                return
            }
            self?.errorMessage = "Password reset email sent"
        }
    }

    func signOut() {
        errorMessage = nil
        do {
            try Auth.auth().signOut()
            isSignedIn = false
            print("Signed out successfully")
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
            print("Sign-out error: \(error.localizedDescription)")
        }
    }

    func deleteAccount(completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"]))
            return
        }

        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(user.uid)

        // Delete user document and subcollections
        userDocRef.delete { error in
            if let error = error {
                print("Error deleting Firestore data: \(error.localizedDescription)")
                completion(error)
                return
            }

            // Delete Firebase Auth user
            user.delete { error in
                if let error = error {
                    print("Error deleting Firebase user: \(error.localizedDescription)")
                    completion(error)
                    return
                }

                // Update state
                self.isSignedIn = false
                self.errorMessage = nil
                print("Account deleted successfully")
                completion(nil)
            }
        }
    }

    private func moveOnboardingAnswers(from oldUserID: String, to newUserID: String) {
        let db = Firestore.firestore()
        db.collection("users").document(oldUserID).collection("onboarding").document("answers").getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("No answers to move or error: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            db.collection("users").document(newUserID).collection("onboarding").document("answers").setData(data) { error in
                if let error = error {
                    print("Error moving answers: \(error.localizedDescription)")
                } else {
                    db.collection("users").document(oldUserID).collection("onboarding").document("answers").delete()
                    print("Answers moved successfully")
                }
            }
        }
    }
}
