import SwiftUI
import FirebaseAuth

struct ManageAccountView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showingDeleteAlert = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Update Email")) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .accessibilityLabel("Email")
                }

                Section(header: Text("Update Password")) {
                    SecureField("New Password", text: $password)
                        .textContentType(.newPassword)
                        .accessibilityLabel("New Password")
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .accessibilityLabel("Confirm Password")
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .accessibilityLabel("Error: \(error)")
                }

                if let success = successMessage {
                    Text(success)
                        .foregroundColor(.green)
                        .accessibilityLabel("Success: \(success)")
                }

                Section {
                    Button("Update Account") {
                        updateAccount()
                    }
                    .disabled(email.isEmpty || (password != confirmPassword))
                    .accessibilityLabel("Update Account")

                    Button("Delete Account") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                    .accessibilityLabel("Delete Account")
                }
            }
            .navigationTitle("Manage Account")
            .alert("Delete Account", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("This will permanently delete your account and all data. Are you sure?")
            }
            .onAppear {
                if let user = Auth.auth().currentUser {
                    email = user.email ?? ""
                }
            }
        }
    }

    private func updateAccount() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user logged in"
            successMessage = nil
            return
        }

        // Validate email format
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            successMessage = nil
            return
        }

        // Update email with verification
        user.sendEmailVerification(beforeUpdatingEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Failed to send verification email: \(error.localizedDescription)"
                    successMessage = nil
                    return
                }

                successMessage = "Verification email sent. Please check your inbox to confirm the new email."
                errorMessage = nil

                // Update password if provided
                if !password.isEmpty {
                    user.updatePassword(to: password) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                errorMessage = "Failed to update password: \(error.localizedDescription)"
                                successMessage = nil
                            } else {
                                successMessage = "Password updated successfully. Email verification pending."
                                errorMessage = nil
                            }
                        }
                    }
                }
            }
        }
    }

    private func deleteAccount() {
        authManager.deleteAccount { error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Failed to delete account: \(error.localizedDescription)"
                    successMessage = nil
                } else {
                    successMessage = "Account deleted successfully"
                    errorMessage = nil
                }
            }
        }
    }

    // Helper function to validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
}

struct ManageAccountView_Previews: PreviewProvider {
    static var previews: some View {
        ManageAccountView()
            .environmentObject(AuthManager())
    }
}
