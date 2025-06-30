import SwiftUI
import FirebaseAuth

struct OnboardingView: View {
    @State private var step: Int = 0
    @Binding var hasCompletedOnboarding: Bool
    @State private var goal: String = ""
    @State private var situation: String = ""
    @State private var ageGroup: String = ""
    @State private var energyLevel: String = ""
    @State private var stressLevel: String = ""
    @State private var uploadedTest: Bool = false
    @State private var improvements: [String] = []
    @State private var previousEfforts: [String] = []
    @State private var trackingMethods: [String] = []

    var onComplete: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 32 : 24) {
                HStack {
                    if step > 0 {
                        Button(action: { step -= 1 }) {
                            Image(systemName: "chevron-left")
                                .font(.system(.body, design: .default, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                                .accessibilityLabel("Go back to Previous Step")
                        }
                    } else {
                        Spacer()
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, geometry.size.width > 600 ? 16 : 8)

                ProgressView(value: Double(step), total: 7.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .tint(.black)
                    .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .accessibilityLabel("Onboarding progress: step \(step + 1) of 8")

                switch step {
                case 0:
                    OB3_GoalView(selectedOption: $goal, onNext: { step += 1 })
                case 1:
                    OB4_SituationView(selectedOption: $situation, onNext: { step += 1 })
                case 2:
                    OB5_AgeGroupView(selectedOption: $ageGroup, onNext: { step += 1 })
                case 3:
                    OB6_EnergyLevelView(selectedOption: $energyLevel, onNext: { step += 1 })
                case 4:
                    OB7_StressLevelView(selectedOption: $stressLevel, onNext: { step += 1 })
                case 5:
                    OB10_PreviousEffortsView(selectedOptions: $previousEfforts, onNext: { step += 1 })
                case 6:
                    OB11_ImpactView(onNext: { step += 1 })
                case 7:
                    OB12_LoadingView(
                        onNext: {
                            hasCompletedOnboarding = true
                            onComplete()
                        },
                        goal: $goal,
                        situation: $situation,
                        ageGroup: $ageGroup,
                        energyLevel: $energyLevel,
                        stressLevel: $stressLevel,
                        previousEfforts: $previousEfforts
                    )
                default:
                    Text("Something went wrong")
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.black)
                        .onAppear { step = 0 }
                        .accessibilityLabel("Error: Invalid onboarding step")
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
            .background(Color.white.ignoresSafeArea())
            .animation(.easeInOut, value: step)
            .transition(.slide)
        }
    }
}

#Preview("iPhone 14") {
    OnboardingView(hasCompletedOnboarding: .constant(false), onComplete: {})
}

#Preview("iPad Pro") {
    OnboardingView(hasCompletedOnboarding: .constant(false), onComplete: {})
}
