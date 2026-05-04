import SwiftUI

struct WelcomeValueScreen1: View {
    var onNext: () -> Void
    var onSkip: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            OnboardingDots(total: 4, current: 0)
                .padding(.top, 20)
                .padding(.bottom, 28)
                .staggerReveal(0)

            // Headline: black bold + inline blue italic
            Group {
                Text("You got your results.\nNo one ")
                    .font(.playfair(36))
                    .foregroundColor(Color.fathrBlack)
                + Text("explained")
                    .font(.playfairItalic(36))
                    .foregroundColor(Color.fathrBlue)
                + Text("\nthem.")
                    .font(.playfair(36))
                    .foregroundColor(Color.fathrBlack)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 14)
            .staggerReveal(1)

            Text("Count. Motility. Morphology. A lab sheet, a vague thumbs up — and zero idea what it means for your chances of becoming a dad.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.fathrSub)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 28)
                .staggerReveal(2)

            VStack(spacing: 12) {
                PainPointRow(text: "\"Borderline normal\" — but no one said what to actually do")
                PainPointRow(text: "Blame quietly lands on her. Your role goes unexamined.")
                PainPointRow(text: "You Googled it at midnight and got more confused")
            }
            .padding(.bottom, 28)
            .staggerReveal(3)

            HStack(alignment: .top, spacing: 12) {
                StatBox(title: "1 in 6", subtitle: "couples face fertility challenges")
                StatBox(title: "50%", subtitle: "involve a male factor")
            }
            .padding(.bottom, 40)
            .staggerReveal(4)

            Spacer()

            VStack(spacing: 4) {
                PrimaryButton("That changes now", perform: onNext)
                SkipLink(perform: onSkip)
            }
            .padding(.bottom, 12)
            .staggerReveal(5)
        }
        .padding(.horizontal, 24)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    WelcomeValueScreen1(onNext: {})
}
