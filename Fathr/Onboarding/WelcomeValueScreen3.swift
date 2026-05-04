import SwiftUI

struct WelcomeValueScreen3: View {
    var onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            OnboardingDots(total: 4, current: 2)
                .padding(.top, 20)
                .padding(.bottom, 28)
                .staggerReveal(0)

            Group {
                Text("Fair questions.\n")
                    .font(.playfair(36))
                    .foregroundColor(Color.fathrBlack)
                + Text("Straight answers.")
                    .font(.playfairItalic(36))
                    .foregroundColor(Color.fathrBlue)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 28)
            .staggerReveal(1)

            VStack(spacing: 16) {

                FAQRow(
                    question: "\"Can small daily changes really matter?\"",
                    answer: "Yes. Consistency with sleep, nutrition, movement and habits builds momentum over time — your body responds to patterns, not perfection."
                )

                FAQRow(
                    question: "\"How long does it take?\"",
                    answer: "Most users follow 90-day lifestyle cycles aligned with sperm regeneration and habit formation."
                )

                FAQRow(
                    question: "\"Is this replacing my doctor?\"",
                    answer: "No. Fathr gives you daily habits and understanding. Your doctor provides clinical care."
                )

                FAQRow(
                    question: "\"Can lifestyle really move the needle?\"",
                    answer: "Research shows sleep, diet, and training can meaningfully support sperm health within a 90-day cycle."
                )
            }
            .padding(.bottom, 24)
            .staggerReveal(2)

            Spacer()

            PrimaryButton("Makes sense — let's go", perform: onNext)
                .padding(.bottom, 12)
                .staggerReveal(3)
        }
        .padding(.horizontal, 24)
        .background(Color.white.ignoresSafeArea())
    }
}

