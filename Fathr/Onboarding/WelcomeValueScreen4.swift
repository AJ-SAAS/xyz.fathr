import SwiftUI

struct WelcomeValueScreen4: View {
    var onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            OnboardingDots(total: 4, current: 3)
                .padding(.top, 20)
                .padding(.bottom, 28)
                .staggerReveal(0)

            // Headline: black bold + blue italic on next line
            Group {
                Text("Private. Science-based.\n")
                    .font(.playfair(36))
                    .foregroundColor(Color.fathrBlack)
                + Text("Built for men.")
                    .font(.playfairItalic(36))
                    .foregroundColor(Color.fathrBlue)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 14)
            .staggerReveal(1)

            Text("No judgement. No waiting rooms. A clear picture of where you are — and a daily plan to get where you want to be.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.fathrSub)
                .lineSpacing(5)
                .padding(.bottom, 28)
                .staggerReveal(2)

            HStack(alignment: .top, spacing: 12) {
                StatBox(title: "78%", subtitle: "improved a key metric in 90 days")
                StatBox(title: "4.8★", subtitle: "from 2,400+ men")
            }
            .padding(.bottom, 20)
            .staggerReveal(3)

            VStack(spacing: 14) {
                TestimonialCard(
                    quote: "\"My DFI was 34% — high risk. Three months on the plan and it dropped to 18%.\"",
                    name: "Tom K., 37 · London",
                    result: "DFI 34% → 18% in 90 days",
                    initials: "TK"
                )
                TestimonialCard(
                    quote: "\"I had no idea lifestyle could affect this. Six weeks in, my motility went from 28% to 51%.\"",
                    name: "James R., 34 · Manchester",
                    result: "Motility 28% → 51% in 6 weeks",
                    initials: "JR"
                )
            }
            .padding(.bottom, 32)
            .staggerReveal(4)

            Spacer()

            PrimaryButton("Let's personalise your plan", perform: onNext)
                .padding(.bottom, 12)
                .staggerReveal(5)
        }
        .padding(.horizontal, 24)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    WelcomeValueScreen4(onNext: {})
}
