import SwiftUI

struct OnboardingQuestion2: View {
    @Binding var hasTestResults: String
    var onNext: () -> Void

    let options = [
        "Yes — ready to upload",
        "Yes — I'll enter them manually",
        "Not yet — booking soon",
        "Not planning to test"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            OnboardingDots(total: 3, current: 1)
                .padding(.top, 20)
                .padding(.bottom, 28)
                .staggerReveal(0)

            Text("Question 2 of 3")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.fathrMuted)
                .kerning(0.6)
                .padding(.bottom, 10)
                .staggerReveal(1)

            Group {
                Text("Do you have\nsperm ")
                    .font(.playfair(36))
                    .foregroundColor(Color.fathrBlack)
                + Text("test results?")
                    .font(.playfairItalic(36))
                    .foregroundColor(Color.fathrBlue)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 12)
            .staggerReveal(2)

            Text("We'll tailor what you see first on your home screen.")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.fathrSub)
                .lineSpacing(4)
                .padding(.bottom, 32)
                .staggerReveal(3)

            VStack(spacing: 12) {
                ForEach(Array(options.enumerated()), id: \.element) { i, option in
                    OptionRow(
                        text: option,
                        isSelected: hasTestResults == option,
                        onTap: { hasTestResults = option }
                    )
                    .staggerReveal(4 + i)
                }
            }
            .padding(.bottom, 40)

            Spacer()

            NextButton(title: "Continue", action: onNext)
                .disabled(hasTestResults.isEmpty)
                .opacity(hasTestResults.isEmpty ? 0.45 : 1.0)
                .padding(.bottom, 12)
                .staggerReveal(8)
        }
        .padding(.horizontal, 24)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    OnboardingQuestion2(hasTestResults: .constant(""), onNext: {})
}
