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
                    VStack(spacing: geometry.size.width > 600 ? 24 : 20) { // Adjust spacing for iPad
                        // Logo
                        Image("Fathr_logo_white")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: min(geometry.size.width * 0.4, 200)) // Cap logo width
                            .padding(.top, geometry.size.width > 600 ? 40 : 24) // Adjust for iPad
                            .accessibilityLabel("Fathr Logo")
                        
                        // Title
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .font(.system(.largeTitle, design: .default, weight: .bold)) // Dynamic type
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                            .accessibilityLabel(isSignUp ? "Create Account" : "Sign In")
                        
                        // Email Field
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600)) // Cap field width
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                            .accessibilityLabel("Email")
                        
                        // Password Field
                        SecureField("Password", text: $password)
                            .textContentType(isSignUp ? .newPassword : .password)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600)) // Cap field width
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                            .accessibilityLabel("Password")
                        
                        // Confirm Password Field (Sign Up only)
                        if isSignUp {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .disableAutocorrection(true)
                                .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                                .padding()
                                .background(.gray.opacity(0.1))
                                .cornerRadius(8)
                                .frame(maxWidth: min(geometry.size.width * 0.9, 600)) // Cap field width
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                                .accessibilityLabel("Confirm Password")
                        }
                        
                        // Error Message
                        if let error = authManager.errorMessage {
                            Text(error)
                                .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                                .accessibilityLabel("Error: \(error)")
                        }
                        
                        // Sign Up/Sign In Button
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
                        .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400)) // Cap button width
                        .padding()
                        .background(email.isEmpty || password.isEmpty || (isSignUp && confirmPassword.isEmpty) ? .gray : .black)
                        .cornerRadius(8)
                        .disabled(email.isEmpty || password.isEmpty || (isSignUp && confirmPassword.isEmpty))
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                        .accessibilityLabel(isSignUp ? "Sign Up" : "Sign In")
                        
                        // Toggle Sign Up/Sign In
                        Button(isSignUp ? "Already have an account? Sign In" : "Need an account? Sign Up") {
                            isSignUp.toggle()
                            authManager.errorMessage = nil
                            email = ""
                            password = ""
                            confirmPassword = ""
                        }
                        .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                        .foregroundColor(.black)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                        .accessibilityLabel(isSignUp ? "Switch to Sign In" : "Switch to Sign Up")
                        
                        // Forgot Password
                        Button("Forgot Password?") {
                            showingResetPassword = true
                        }
                        .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                        .foregroundColor(.black)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                        .padding(.bottom, geometry.size.width > 600 ? 60 : 40) // Adjust for iPad
                        .accessibilityLabel("Forgot Password")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, geometry.size.width > 600 ? 40 : 24) // Adjust vertical padding
                }
                .background(Color.white.ignoresSafeArea())
                .sheet(isPresented: $showingResetPassword) {
                    VStack(spacing: geometry.size.width > 600 ? 24 : 20) { // Adjust spacing for iPad
                        // Reset Password Title
                        Text("Reset Password")
                            .font(.system(.largeTitle, design: .default, weight: .bold)) // Dynamic type
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                            .accessibilityLabel("Reset Password")
                        
                        // Reset Email Field
                        TextField("Email", text: $resetEmail)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600)) // Cap field width
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                            .accessibilityLabel("Reset Email")
                        
                        // Send Reset Email Button
                        Button("Send Reset Email") {
                            authManager.resetPassword(email: resetEmail)
                            showingResetPassword = false
                            resetEmail = ""
                        }
                        .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400)) // Cap button width
                        .padding()
                        .background(resetEmail.isEmpty ? .gray : .black)
                        .cornerRadius(8)
                        .disabled(resetEmail.isEmpty)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                        .accessibilityLabel("Send Reset Email")
                        
                        // Cancel Button
                        Button("Cancel") {
                            showingResetPassword = false
                            resetEmail = ""
                        }
                        .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                        .foregroundColor(.black)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                        .padding(.bottom, geometry.size.width > 600 ? 60 : 40) // Adjust for iPad
                        .accessibilityLabel("Cancel")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, geometry.size.width > 600 ? 40 : 24) // Adjust vertical padding
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
