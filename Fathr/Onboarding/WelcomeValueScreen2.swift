import SwiftUI

struct WelcomeValueScreen2: View {
    var onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            OnboardingDots(total: 4, current: 1)
                .padding(.top, 20)
                .padding(.bottom, 28)
                .staggerReveal(0)

            // Headline: black bold, then blue italic on next line
            Group {
                Text("Your sperm renews every 90 days.\n")
                    .font(.playfair(36))
                    .foregroundColor(Color.fathrBlack)
                + Text("That's your window.")
                    .font(.playfairItalic(30))
                    .foregroundColor(Color.fathrBlue)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 16)
            .staggerReveal(1)

            Text("What you eat, sleep and do starting today shapes the next generation of sperm.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.fathrSub)
                .lineSpacing(5)
                .padding(.bottom, 32)
                .staggerReveal(2)

            VStack(alignment: .leading, spacing: 0) {
                TimelineRow(day: "Today", description: "Start the plan", isLast: false)
                TimelineRow(day: "Day 45", description: "Habits locked in", isLast: false)
                TimelineRow(day: "Day 90", description: "Re-test & see real change", isLast: true)
            }
            .padding(.bottom, 32)
            .staggerReveal(3)

            HStack(alignment: .top, spacing: 12) {
                BeforeAfterCard(
                    label: "WITHOUT FATHR",
                    labelColor: Color.fathrDanger,
                    items: ["Still guessing", "No tracking", "Same results"],
                    isAfter: false
                )
                BeforeAfterCard(
                    label: "WITH FATHR",
                    labelColor: Color.fathrSuccess,
                    items: ["Daily plan", "Progress tracked", "Measurable change"],
                    isAfter: true
                )
            }
            .padding(.bottom, 40)
            .staggerReveal(4)

            Spacer()

            PrimaryButton("I want that", perform: onNext)
                .padding(.bottom, 12)
                .staggerReveal(5)
        }
        .padding(.horizontal, 24)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    WelcomeValueScreen2(onNext: {})
}
