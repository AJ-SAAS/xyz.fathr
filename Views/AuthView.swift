import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var purchaseModel: PurchaseModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSignUp: Bool = false
    @State private var showingResetPassword: Bool = false
    @State private var resetEmail: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(isSignUp ? "Create Account" : "Sign In")
                    .font(.title)
                    .fontDesign(.rounded)

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .accessibilityLabel("Email")

                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .accessibilityLabel("Password")

                if isSignUp {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.password)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .accessibilityLabel("Confirm Password")
                }

                if let error = authManager.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .accessibilityLabel("Error: \(error)")
                }

                Button(isSignUp ? "Sign Up" : "Sign In") {
                    if isSignUp {
                        if password == confirmPassword {
                            authManager.signUp(email: email, password: password)
                        } else {
                            authManager.errorMessage = "Passwords do not match"
                        }
                    } else {
                        authManager.signIn(email: email, password: password)
                    }
                }
                .padding()
                .background(email.isEmpty || password.isEmpty || (isSignUp && confirmPassword.isEmpty) ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(email.isEmpty || password.isEmpty || (isSignUp && confirmPassword.isEmpty))
                .accessibilityLabel(isSignUp ? "Sign Up" : "Sign In")

                Button(isSignUp ? "Already have an account? Sign In" : "Need an account? Sign Up") {
                    isSignUp.toggle()
                    authManager.errorMessage = nil
                    email = ""
                    password = ""
                    confirmPassword = ""
                }
                .foregroundColor(.blue)
                .accessibilityLabel(isSignUp ? "Switch to Sign In" : "Switch to Sign Up")

                Button("Forgot Password?") {
                    showingResetPassword = true
                }
                .foregroundColor(.blue)
                .accessibilityLabel("Forgot Password")
            }
            .padding()
            .sheet(isPresented: $showingResetPassword) {
                VStack(spacing: 20) {
                    Text("Reset Password")
                        .font(.title)
                        .fontDesign(.rounded)

                    TextField("Email", text: $resetEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .accessibilityLabel("Reset Email")

                    Button("Send Reset Email") {
                        authManager.resetPassword(email: resetEmail)
                        showingResetPassword = false
                        resetEmail = ""
                    }
                    .padding()
                    .background(resetEmail.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(resetEmail.isEmpty)
                    .accessibilityLabel("Send Reset Email")

                    Button("Cancel") {
                        showingResetPassword = false
                        resetEmail = ""
                    }
                    .foregroundColor(.blue)
                    .accessibilityLabel("Cancel")
                }
                .padding()
            }
            .onChange(of: email) {
                authManager.errorMessage = nil
            }
            .onChange(of: isSignUp) {
                authManager.errorMessage = nil
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(AuthManager())
            .environmentObject(PurchaseModel())
    }
}
