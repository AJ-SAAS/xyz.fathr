import SwiftUI

// MARK: - Main Onboarding View (No Splash)
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject var purchaseModel: PurchaseModel

    @State private var currentStep: OnboardingStep = .welcome1

    // User responses
    @State private var journeyStage: String = ""
    @State private var hasTestResults: String = ""
    @State private var mainGoal: String = ""

    // Animation control
    @State private var skipAnimations: Bool = false

    // 🔥 UPDATED: no longer assumes "home navigation"
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {

                if currentStep.showsProgress {
                    OnboardingProgressBar(currentStep: currentStep)
                        .padding(.top, 20)
                }

                Group {
                    switch currentStep {

                    case .welcome1:
                        WelcomeValueScreen1(onNext: { currentStep = .welcome2 })
                            .environment(\.skipAnimations, skipAnimations)

                    case .welcome2:
                        WelcomeValueScreen2(onNext: { currentStep = .welcome3 })
                            .environment(\.skipAnimations, skipAnimations)

                    case .welcome3:
                        WelcomeValueScreen3(onNext: { currentStep = .welcome4 })
                            .environment(\.skipAnimations, skipAnimations)

                    case .welcome4:
                        WelcomeValueScreen4(onNext: { currentStep = .question1 })
                            .environment(\.skipAnimations, skipAnimations)

                    case .question1:
                        OnboardingQuestion1(
                            journeyStage: $journeyStage,
                            onNext: { currentStep = .question2 }
                        )

                    case .question2:
                        OnboardingQuestion2(
                            hasTestResults: $hasTestResults,
                            onNext: { currentStep = .question3 }
                        )

                    case .question3:
                        OnboardingQuestion3(
                            mainGoal: $mainGoal,
                            onNext: { currentStep = .review }
                        )

                    case .review:
                        OB12_ReviewView(onNext: {
                            currentStep = .summary
                        })

                    case .summary:
                        PersonalizedSummaryView(onNext: {
                            currentStep = .loading
                        })

                    case .loading:
                        OB12_LoadingView(
                            onNext: finishOnboarding,
                            goal: $mainGoal,
                            situation: $journeyStage,
                            ageGroup: .constant(""),
                            energyLevel: .constant(""),
                            stressLevel: .constant(""),
                            previousEfforts: .constant([])
                        )
                        .environmentObject(purchaseModel)
                    }
                }
                .id(currentStep)
            }
        }

        .contentShape(Rectangle())
        .onTapGesture {
            skipAnimations = true
        }

        .animation(.easeInOut(duration: 0.45), value: currentStep)
    }

    // MARK: - FINAL STEP (UPDATED FLOW)
    private func finishOnboarding() {

        // 1. mark onboarding done
        hasCompletedOnboarding = true

        // 2. tell RootView: onboarding + paywall flow finished
        onComplete()

        // ❌ IMPORTANT CHANGE:
        // We NO LONGER assume this goes to Home.
        // RootView decides next step (AuthView → Home)
    }
}

// MARK: - Onboarding Steps Enum
enum OnboardingStep {
    case welcome1, welcome2, welcome3, welcome4
    case question1, question2, question3
    case review, summary, loading

    var showsProgress: Bool {
        switch self {
        case .welcome1, .welcome2, .welcome3, .welcome4:
            return false
        default:
            return true
        }
    }
}

// MARK: - Animation System (TypingText + Staggered)
struct SkipAnimationsKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var skipAnimations: Bool {
        get { self[SkipAnimationsKey.self] }
        set { self[SkipAnimationsKey.self] = newValue }
    }
}

struct StaggeredRevealModifier: ViewModifier {
    let delay: Double

    @Environment(\.skipAnimations) var skipAnimations
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible || skipAnimations ? 1 : 0)
            .offset(y: isVisible || skipAnimations ? 0 : 10)
            .onAppear {
                if skipAnimations {
                    isVisible = true
                    return
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        isVisible = true
                    }
                }
            }
    }
}

extension View {
    func staggered(delay: Double) -> some View {
        self.modifier(StaggeredRevealModifier(delay: delay))
    }
}

struct TypingText: View {
    let fullText: String

    @Environment(\.skipAnimations) var skipAnimations
    @State private var displayedText = ""

    var body: some View {
        Text(displayedText)
            .onAppear {
                if skipAnimations {
                    displayedText = fullText
                } else {
                    typeText()
                }
            }
    }

    private func typeText() {
        displayedText = ""
        for (index, char) in fullText.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.03) {
                displayedText.append(char)
            }
        }
    }
}
