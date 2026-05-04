import SwiftUI
import FirebaseAuth

struct AuthView: View {

    @EnvironmentObject var authManager: AuthManager

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

                        // MARK: Logo
                        Image("Fathr_logo_white")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: min(geometry.size.width * 0.4, 200))
                            .padding(.top, geometry.size.width > 600 ? 40 : 24)

                        // MARK: TITLE
                        Text("Save your progress")
                            .font(.system(.largeTitle, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)

                        // MARK: SUBTITLE
                        Text("Your 74-day transformation will be stored safely")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)

                        // MARK: EMAIL
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)

                        // MARK: PASSWORD
                        SecureField("Password", text: $password)
                            .textContentType(isSignUp ? .newPassword : .password)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)

                        // MARK: CONFIRM PASSWORD
                        if isSignUp {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        }

                        // MARK: ERROR
                        if let error = authManager.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        }

                        // MARK: PRIMARY BUTTON
                        Button("Continue") {

                            if isSignUp {

                                guard password == confirmPassword else {
                                    authManager.errorMessage = "Passwords do not match"
                                    return
                                }

                                authManager.signUp(email: email, password: password)

                            } else {
                                authManager.signIn(email: email, password: password)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(email.isEmpty || password.isEmpty ? Color.gray : Color.black)
                        .cornerRadius(8)

                        // MARK: TOGGLE
                        Button(isSignUp
                               ? "Already have an account? Sign in"
                               : "Need an account? Sign up") {
                            isSignUp.toggle()
                            authManager.errorMessage = nil
                        }
                        .foregroundColor(.blue)

                        // MARK: RESET PASSWORD
                        Button("Forgot Password?") {
                            showingResetPassword = true
                        }
                        .foregroundColor(.black)

                        // MARK: GUEST
                        HStack(spacing: 4) {
                            Text("Would you like to sign in later?")
                                .foregroundColor(.black)

                            Button(action: {
                                authManager.continueAsGuest()
                                onAuthSuccess()
                            }) {
                                Text("Skip")
                                    .bold()
                                    .underline()
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .background(Color.white.ignoresSafeArea())

                // MARK: UPDATED - Handle successful authentication
                .onChange(of: authManager.currentUserID) { _, userID in
                    if let userID = userID, !userID.isEmpty {
                        DispatchQueue.main.async {
                            // Transfer onboarding data to Firestore for new users
                            if isSignUp {
                                authManager.completeSignupWithOnboarding()
                            }
                            onAuthSuccess()
                        }
                    }
                }

                // safety fallback (guest flow)
                .onChange(of: authManager.isGuest) { _, isGuest in
                    if isGuest {
                        DispatchQueue.main.async {
                            onAuthSuccess()
                        }
                    }
                }
            }
        }
    }
}
