import SwiftUI
import FirebaseAuth

struct OnboardingView: View {
    @State private var step = 0
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false

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
        VStack(spacing: 24) {
            // Header with Back button
            HStack {
                if step > 0 {
                    Button(action: { step -= 1 }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .accessibilityLabel("Go back to previous step")
                    }
                } else {
                    Spacer()
                }
                Spacer()
            }
            .padding(.horizontal)

            // Progress Bar: 11 steps (0 to 10)
            ProgressView(value: Double(step), total: 10)
                .progressViewStyle(LinearProgressViewStyle())
                .tint(.black)
                .padding(.horizontal)

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
                    .onAppear { step = 0 }
            }

            Spacer()
        }
        .animation(.easeInOut, value: step)
        .transition(.slide)
        .padding()
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
