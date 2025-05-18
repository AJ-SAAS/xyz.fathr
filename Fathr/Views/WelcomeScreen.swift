import SwiftUI

struct WelcomeScreen: View {
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Start your journey to a healthier you!")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .accessibilityLabel("Welcome to your wellness journey")

            Button("Begin Now") {
                onNext()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .accessibilityLabel("Start onboarding")

            Button("Skip") {
                onNext()
            }
            .foregroundColor(.gray)
            .accessibilityLabel("Skip onboarding")
        }
    }
}

#Preview {
    WelcomeScreen(onNext: {})
}
