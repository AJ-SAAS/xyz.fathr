import SwiftUI

struct OB2_SignupScreen: View {
    var onContinueWithEmail: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 24)

            Image("Fathr_logo_white")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.4)
                .accessibilityLabel("Fathr Logo")

            Image("ob_signup")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Signup Illustration")

            Text("Sign up to access all of Fathr's features!")
                .font(.system(size: 18, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.horizontal, 32)

            Spacer()

            Button(action: {
                onContinueWithEmail()
            }) {
                Text("Continue with email")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 40) // Matching the splash screen
        }
        .background(Color.white.ignoresSafeArea())
    }
}

