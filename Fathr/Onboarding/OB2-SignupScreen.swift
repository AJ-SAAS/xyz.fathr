import SwiftUI

struct OB2_SignupScreen: View {
    var onContinueWithEmail: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                Spacer().frame(height: geometry.size.width > 600 ? 40 : 24) // Adjust for iPad

                Image("Fathr_logo_white")
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(geometry.size.width * 0.4, 280)) // Cap logo size
                    .accessibilityLabel("Fathr Logo")

                Image("ob_signup")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: min(geometry.size.width * 0.9, 500)) // Cap illustration size
                    .accessibilityLabel("Signup Illustration")

                Text("Sign up to access all of Fathr's features!")
                    .font(.system(.title2, design: .default, weight: .bold)) // Dynamic type
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad

                Spacer()

                Button(action: {
                    onContinueWithEmail()
                }) {
                    Text("Continue with email")
                        .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400)) // Cap button width
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                .padding(.bottom, geometry.size.width > 600 ? 60 : 40) // Adjust for iPad
            }
            .frame(maxWidth: .infinity)
            .background(Color.white.ignoresSafeArea())
        }
    }
}

struct OB2_SignupScreen_Previews: PreviewProvider {
    static var previews: some View {
        OB2_SignupScreen(onContinueWithEmail: {})
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
        
        OB2_SignupScreen(onContinueWithEmail: {})
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
            .previewDisplayName("iPad Pro")
    }
}
