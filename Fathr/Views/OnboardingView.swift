import SwiftUI
import FirebaseAuth

struct OnboardingView: View {
    @State private var step: Int = 0
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    // User input states
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
            VStack(spacing: geometry.size.width > 600 ? 32 : 24) { // Adjust spacing for iPad
                // Header with Back button
                HStack {
                    if step > 0 {
                        Button(action: { step -= 1 }) {
                            Image(systemName: "chevron-left")
                            .font(.system(.body, design: .default, weight: .bold)) // Dynamic type
                            .foregroundColor(.white)
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                            .accessibilityLabel("Go back to Previous Step")
                        }
                    } else {
                        Spacer()
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, geometry.size.width > 600 ? 16 : 8) // Adjust for iPad
                
                // Progress Bar: 11 steps (0 to 10)
                ProgressView(value: Double(step), total: 10.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .tint(.black)
                    .frame(maxWidth: min(geometry.size.width * 0.9, 600)) // Cap progress bar width
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                    .accessibilityLabel("Onboarding progress: step \(step + 1) of 11")
                
                // Onboarding steps
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
                    OB12_LoadingView(onNext: { step += 1 })
                case 8:
                    OB13_BaselineView(onNext: { step += 1 })
                case 9:
                    OB15_WhyFathrView(onNext: { step += 1 })
                case 10:
                    OB20_DashboardPreviewView(onNext: {
                        hasCompletedOnboarding = true
                        onComplete()
                    })
                default:
                    Text("Something went wrong")
                        .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                        .foregroundColor(.black)
                        .onAppear { step = 0 }
                        .accessibilityLabel("Error: Invalid onboarding step")
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, geometry.size.width > 600 ? 40 : 24) // Adjust vertical padding
            .background(Color.white.ignoresSafeArea())
            .animation(.easeInOut, value: step)
            .transition(.slide)
        }
    }
}

#Preview("iPhone 14") {
    OnboardingView(onComplete: {})
}

#Preview("iPad Pro") {
    OnboardingView(onComplete: {})
}
