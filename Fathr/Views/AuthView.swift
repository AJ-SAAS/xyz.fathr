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
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    VStack(spacing: geometry.size.width > 600 ? 24 : 20) {
                        Image("Fathr_logo_white")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: min(geometry.size.width * 0.4, 200))
                            .padding(.top, geometry.size.width > 600 ? 40 : 24)
                            .accessibilityLabel("Fathr Logo")

                        Text(isSignUp ? "Create Account" : "Sign In")
                            .font(.system(.largeTitle, design: .default, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)

                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .default, weight: .regular))
                            .foregroundColor(.black)
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .accessibilityLabel("Email")

                        SecureField("Password", text: $password)
                            .textContentType(isSignUp ? .newPassword : .password)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .default, weight: .regular))
                            .foregroundColor(.black)
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .accessibilityLabel("Password")

                        if isSignUp {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .disableAutocorrection(true)
                                .font(.system(.body, design: .default, weight: .regular))
                                .foregroundColor(.black)
                                .padding()
                                .background(.gray.opacity(0.1))
                                .cornerRadius(8)
                                .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                                .accessibilityLabel("Confirm Password")
                        }

                        if let error = authManager.errorMessage {
                            Text(error)
                                .font(.system(.subheadline, design: .default, weight: .regular))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
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
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(email.isEmpty || password.isEmpty || (isSignUp && confirmPassword.isEmpty) ? .gray : .black)
                        .cornerRadius(8)
                        .disabled(email.isEmpty || password.isEmpty || (isSignUp && confirmPassword.isEmpty))
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .accessibilityLabel(isSignUp ? "Sign Up" : "Sign In")

                        Button(isSignUp ? "Already have an account? Sign In" : "Need an account? Sign Up") {
                            isSignUp.toggle()
                            authManager.errorMessage = nil
                            email = ""
                            password = ""
                            confirmPassword = ""
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.black)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .accessibilityLabel(isSignUp ? "Switch to Sign In" : "Switch to Sign Up")

                        Button("Forgot Password?") {
                            showingResetPassword = true
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.black)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                        .accessibilityLabel("Forgot Password")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
                }
                .background(Color.white.ignoresSafeArea())
                .sheet(isPresented: $showingResetPassword) {
                    VStack(spacing: geometry.size.width > 600 ? 24 : 20) {
                        Text("Reset Password")
                            .font(.system(.largeTitle, design: .default, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)

                        TextField("Email", text: $resetEmail)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .default, weight: .regular))
                            .foregroundColor(.black)
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .accessibilityLabel("Reset Email")

                        Button("Send Reset Email") {
                            authManager.resetPassword(email: resetEmail)
                            showingResetPassword = false
                            resetEmail = ""
                        }
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(resetEmail.isEmpty ? .gray : .black)
                        .cornerRadius(8)
                        .disabled(resetEmail.isEmpty)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .accessibilityLabel("Send Reset Email")

                        Button("Cancel") {
                            showingResetPassword = false
                            resetEmail = ""
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.black)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                        .accessibilityLabel("Cancel")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
                    .background(Color.white.ignoresSafeArea())
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
}

#Preview("iPhone 14") {
    AuthView(onAuthSuccess: {})
        .environmentObject(AuthManager())
        .environmentObject(PurchaseModel())
}

#Preview("iPad Pro") {
    AuthView(onAuthSuccess: {})
        .environmentObject(AuthManager())
        .environmentObject(PurchaseModel())
}
