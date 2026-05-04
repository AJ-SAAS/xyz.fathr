import SwiftUI

struct OnboardingProgressBar: View {
    let currentStep: OnboardingStep
    
    private var progress: Double {
        switch currentStep {
        case .welcome1, .welcome2, .welcome3, .welcome4:   // Removed .splash
            return 0.0
        case .question1:
            return 0.2
        case .question2:
            return 0.4
        case .question3:
            return 0.6
        case .review:
            return 0.75
        case .summary:
            return 0.85
        case .loading:
            return 1.0
        }
    }
    
    var body: some View {
        ProgressView(value: progress, total: 1.0)
            .progressViewStyle(LinearProgressViewStyle(tint: .black))
            .frame(height: 4)
            .padding(.horizontal, 32)
    }
}
