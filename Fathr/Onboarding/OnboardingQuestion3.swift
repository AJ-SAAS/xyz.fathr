import SwiftUI

struct OnboardingQuestion3: View {
    @Binding var mainGoal: String
    var onNext: () -> Void

    let options = [
        "Understanding my results",
        "Improving sperm quality",
        "Reducing miscarriage risk",
        "Supporting my partner"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            OnboardingDots(total: 3, current: 2)
                .padding(.top, 20)
                .padding(.bottom, 28)
                .staggerReveal(0)

            Text("Question 3 of 3")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.fathrMuted)
                .kerning(0.6)
                .padding(.bottom, 10)
                .staggerReveal(1)

            Group {
                Text("What matters\nmost ")
                    .font(.playfair(36))
                    .foregroundColor(Color.fathrBlack)
                + Text("right now?")
                    .font(.playfairItalic(36))
                    .foregroundColor(Color.fathrBlue)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 12)
            .staggerReveal(2)

            Text("Your action plan will prioritise this area first.")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.fathrSub)
                .lineSpacing(4)
                .padding(.bottom, 32)
                .staggerReveal(3)

            VStack(spacing: 12) {
                ForEach(Array(options.enumerated()), id: \.element) { i, option in
                    OptionRow(
                        text: option,
                        isSelected: mainGoal == option,
                        onTap: { mainGoal = option }
                    )
                    .staggerReveal(4 + i)
                }
            }
            .padding(.bottom, 40)

            Spacer()

            NextButton(title: "See my plan", action: onNext)
                .disabled(mainGoal.isEmpty)
                .opacity(mainGoal.isEmpty ? 0.45 : 1.0)
                .padding(.bottom, 12)
                .staggerReveal(8)
        }
        .padding(.horizontal, 24)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    OnboardingQuestion3(mainGoal: .constant(""), onNext: {})
}
