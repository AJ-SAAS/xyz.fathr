import SwiftUI
import FirebaseAuth

struct ManageAccountView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showingDeleteAlert = false
    @State private var errorMessage: String?

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

                Section {
                    Button("Update Account") {
                        updateAccount()
                    }
                    .disabled(email.isEmpty || password.isEmpty || password != confirmPassword)
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
            return
        }

        user.updateEmail(to: email) { error in
            if let error = error {
                errorMessage = "Failed to update email: \(error.localizedDescription)"
                return
            }

            if !password.isEmpty {
                user.updatePassword(to: password) { error in
                    if let error = error {
                        errorMessage = "Failed to update password: \(error.localizedDescription)"
                    } else {
                        errorMessage = "Account updated successfully"
                    }
                }
            } else {
                errorMessage = "Account updated successfully"
            }
        }
    }

    private func deleteAccount() {
        authManager.deleteAccount { error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Failed to delete account: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct ManageAccountView_Previews: PreviewProvider {
    static var previews: some View {
        ManageAccountView()
            .environmentObject(AuthManager())
    }
}
