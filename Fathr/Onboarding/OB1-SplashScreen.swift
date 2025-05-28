import SwiftUI

struct OB1_SplashScreen: View {
    var onGetStarted: () -> Void

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Image("Fathr_logo_white")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.45)
                    .accessibilityLabel("Fathr Logo")

                VStack(spacing: 12) {
                    Text("Congratulations.")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)

                    Text("You're taking the first step toward a healthier, stronger legacy.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 40) // Increased top padding for better vertical centering

                Spacer()

                Button(action: {
                    onGetStarted()
                }) {
                    Text("Get Started")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black)
                        .cornerRadius(10)
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

