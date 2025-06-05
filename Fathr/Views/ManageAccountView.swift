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
        GeometryReader { geometry in
            NavigationStack {
                Form {
                    Section(header: Text("Update Email")
                                .font(.system(.headline, design: .default, weight: .bold))) { // Dynamic type
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600)) // Cap field width
                            .accessibilityLabel("Email")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad

                    Section(header: Text("Update Password")
                                .font(.system(.headline, design: .default, weight: .bold))) { // Dynamic type
                        SecureField("New Password", text: $password)
                            .textContentType(.newPassword)
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600)) // Cap field width
                            .accessibilityLabel("New Password")
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textContentType(.newPassword)
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600)) // Cap field width
                            .accessibilityLabel("Confirm Password")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad

                    if let error = errorMessage {
                        Text(error)
                            .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad
                            .accessibilityLabel("Error: \(error)")
                    }

                    if let success = successMessage {
                        Text(success)
                            .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad
                            .accessibilityLabel("Success: \(success)")
                    }

                    Section {
                        Button("Update Account") {
                            updateAccount()
                        }
                        .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                        .foregroundColor(.black)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400)) // Cap button width
                        .padding()
                        .background(email.isEmpty || (password != confirmPassword) ? .gray : .white)
                        .cornerRadius(8)
                        .disabled(email.isEmpty || (password != confirmPassword))
                        .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad
                        .accessibilityLabel("Update Account")
                        
                        Button("Delete Account") {
                            showingDeleteAlert = true
                        }
                        .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                        .foregroundColor(.red)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400)) // Cap button width
                        .padding()
                        .background(.white)
                        .cornerRadius(8)
                        .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad
                        .accessibilityLabel("Delete Account")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad
                }
                .navigationTitle("Manage Account")
                .padding(.vertical, geometry.size.width > 600 ? 40 : 24) // Adjust vertical padding
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
            .frame(maxWidth: .infinity)
            .background(Color.white.ignoresSafeArea())
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

#Preview("iPhone 14") {
    ManageAccountView()
        .environmentObject(AuthManager())
}

#Preview("iPad Pro") {
    ManageAccountView()
        .environmentObject(AuthManager())
}
