import SwiftUI
import FirebaseAuth

struct OnboardingView: View {
    @State private var step = 0
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @State private var exerciseFrequency: String = ""
    @State private var dietQuality: String = ""
    @State private var sleepHours: Double = 7.0
    @State private var stressLevel: String = ""

    var body: some View {
        VStack {
            Text("Step \(step + 1) of 6")
                .font(.subheadline)
                .padding(.bottom)

            if step > 0 {
                Button(action: {
                    step -= 1
                }) {
                    Text("Back")
                        .padding()
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("Go back to previous step")
            }

            switch step {
            case 0:
                WelcomeScreen(onNext: { step += 1 })
            case 1:
                Question1View(selectedOption: $exerciseFrequency, onNext: { step += 1 })
            case 2:
                Question2View(selectedOption: $dietQuality, onNext: { step += 1 })
            case 3:
                Question3View(sleepHours: $sleepHours, onNext: { step += 1 })
            case 4:
                Question4View(selectedOption: $stressLevel, onNext: { step += 1 })
            case 5:
                MotivationView(
                    exerciseFrequency: exerciseFrequency,
                    dietQuality: dietQuality,
                    sleepHours: sleepHours,
                    stressLevel: stressLevel,
                    onNext: {
                        hasCompletedOnboarding = true
                    }
                )
            default:
                Text("Something went wrong")
                    .font(.headline)
                    .onAppear { step = 0 }
                    .accessibilityLabel("Error in onboarding, restarting")
            }
        }
        .animation(.easeInOut, value: step)
        .transition(.slide)
        .padding()
        .onAppear {
            if Auth.auth().currentUser == nil {
                Auth.auth().signInAnonymously { result, error in
                    if let error = error {
                        print("Anonymous login failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
