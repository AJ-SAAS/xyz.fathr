import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var purchaseModel: PurchaseModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSignUp: Bool = true
    @State private var showingResetPassword: Bool = false
    @State private var resetEmail: String = ""
    var onAuthSuccess: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image("Fathr_logo_white")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.4)
                        .padding(.top, 24)
                        .accessibilityLabel("Fathr Logo")

                    Text(isSignUp ? "Create Account" : "Sign In")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true) // Added for consistency
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(8)
                        .accessibilityLabel("Email")

                    SecureField("Password", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password) // Use .newPassword for sign-up
                        .disableAutocorrection(true) // Prevent autocorrect interference
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(8)
                        .accessibilityLabel("Password")

                    if isSignUp {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textContentType(.newPassword) // Use .newPassword for consistency
                            .disableAutocorrection(true) // Prevent autocorrect interference
                            .padding()
                            .background(.gray.opacity(0.1))
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
                    .background(email.isEmpty || password.isEmpty || (isSignUp && confirmPassword.isEmpty) ? .gray : .black)
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
                    .foregroundColor(.black)
                    .accessibilityLabel(isSignUp ? "Switch to Sign In" : "Switch to Sign Up")

                    Button("Forgot Password?") {
                        showingResetPassword = true
                    }
                    .foregroundColor(.black)
                    .accessibilityLabel("Forgot Password")

                    Spacer().frame(height: 40)
                }
                .padding()
            }
            .sheet(isPresented: $showingResetPassword) {
                VStack(spacing: 20) {
                    Text("Reset Password")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TextField("Email", text: $resetEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true) // Added for consistency
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(8)
                        .accessibilityLabel("Reset Email")

                    Button("Send Reset Email") {
                        authManager.resetPassword(email: resetEmail)
                        showingResetPassword = false
                        resetEmail = ""
                    }
                    .padding()
                    .background(resetEmail.isEmpty ? .gray : .black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(resetEmail.isEmpty)
                    .accessibilityLabel("Send Reset Email")

                    Button("Cancel") {
                        showingResetPassword = false
                        resetEmail = ""
                    }
                    .foregroundColor(.black)
                    .accessibilityLabel("Cancel")
                }
                .padding()
            }
            .onChange(of: email) { _, _ in
                authManager.errorMessage = nil
            }
            .onChange(of: isSignUp) { _, _ in
                authManager.errorMessage = nil
            }
            .onChange(of: authManager.isSignedIn) { _, newValue in
                if newValue {
                    onAuthSuccess()
                }
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(onAuthSuccess: {})
            .environmentObject(AuthManager())
            .environmentObject(PurchaseModel())
    }
}
