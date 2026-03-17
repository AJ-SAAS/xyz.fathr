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

                        Text(isSignUp ? "Get started" : "Sign In")
                            .font(.system(.largeTitle, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)

                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)

                        SecureField("Password", text: $password)
                            .textContentType(isSignUp ? .newPassword : .password)
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)

                        if isSignUp {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .padding()
                                .background(.gray.opacity(0.1))
                                .cornerRadius(8)
                                .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        }

                        if let error = authManager.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
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
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(email.isEmpty || password.isEmpty ? .gray : .black)
                        .cornerRadius(8)

                        Button("Continue as Guest") {
                            authManager.continueAsGuest()
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )

                        Button(isSignUp ? "Already have an account? Sign In" : "Need an account? Sign Up") {
                            isSignUp.toggle()
                            authManager.errorMessage = nil
                        }
                        .foregroundColor(.black)

                        Button("Forgot Password?") {
                            showingResetPassword = true
                        }
                        .foregroundColor(.black)
                    }
                }
                .background(Color.white.ignoresSafeArea())
                .onChange(of: authManager.isGuest) { _, newValue in
                    if !newValue && authManager.isSignedIn {
                        onAuthSuccess()
                    }
                }
            }
        }
    }
}
