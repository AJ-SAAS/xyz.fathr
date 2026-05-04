import SwiftUI

struct OnboardingQuestion1: View {
    @Binding var journeyStage: String
    var onNext: () -> Void

    let options = [
        "Just starting to try",
        "Trying for 6–12 months",
        "Over a year, no success yet",
        "Exploring IVF / other options"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Progress dots — reusing same component as welcome screens
            OnboardingDots(total: 3, current: 0)
                .padding(.top, 20)
                .padding(.bottom, 28)
                .staggerReveal(0)

            // Step label
            Text("Question 1 of 3")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.fathrMuted)
                .kerning(0.6)
                .padding(.bottom, 10)
                .staggerReveal(1)

            // Headline
            Group {
                Text("Where are you in\nyour ")
                    .font(.playfair(36))
                    .foregroundColor(Color.fathrBlack)
                + Text("journey?")
                    .font(.playfairItalic(36))
                    .foregroundColor(Color.fathrBlue)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 12)
            .staggerReveal(2)

            Text("This shapes the tone and urgency of your plan.")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.fathrSub)
                .lineSpacing(4)
                .padding(.bottom, 32)
                .staggerReveal(3)

            // Options
            VStack(spacing: 12) {
                ForEach(Array(options.enumerated()), id: \.element) { i, option in
                    OptionRow(
                        text: option,
                        isSelected: journeyStage == option,
                        onTap: { journeyStage = option }
                    )
                    .staggerReveal(4 + i)
                }
            }
            .padding(.bottom, 40)

            Spacer()

            NextButton(title: "Continue", action: onNext)
                .disabled(journeyStage.isEmpty)
                .opacity(journeyStage.isEmpty ? 0.45 : 1.0)
                .padding(.bottom, 12)
                .staggerReveal(8)
        }
        .padding(.horizontal, 24)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    OnboardingQuestion1(journeyStage: .constant(""), onNext: {})
}
