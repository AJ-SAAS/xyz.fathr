import SwiftUI

struct PersonalizedSummaryView: View {
    var onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            OnboardingDots(total: 3, current: 2)
                .padding(.top, 20)
                .padding(.bottom, 28)
                .staggerReveal(0)

            Group {
                Text("Your plan is\n")
                    .font(.playfair(36))
                    .foregroundColor(Color.fathrBlack)
                + Text("ready.")
                    .font(.playfairItalic(36))
                    .foregroundColor(Color.fathrBlue)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 8)
            .staggerReveal(1)

            Text("Based on your answers, here's what we're focusing on first.")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.fathrSub)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 28)
                .staggerReveal(2)

            // Goal + Window summary rows
            VStack(spacing: 10) {
                summaryRow(
                    icon: "target",
                    label: "Main goal",
                    value: "Improving sperm quality",
                    accentColor: Color.fathrBlue,
                    bgColor: Color.fathrBlueLight
                )
                .staggerReveal(3)
                
                summaryRow(
                    icon: "arrow.clockwise.circle",
                    label: "Your window",
                    value: "Sperm renews every 90 days — starting today",
                    accentColor: Color.fathrBlue,
                    bgColor: Color.fathrBlueLight
                )
                .staggerReveal(4)
            }
            .padding(.bottom, 20)

            // Progress curve
            FathrProgressCurve()
                .staggerReveal(5)
                .padding(.bottom, 24)

            // Encouraging callout
            HStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.fathrBlue)
                Text("You're taking a step most men never do. That already puts you ahead.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.fathrSub)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .background(Color.fathrBlueLight)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.bottom, 16) // 👈 reduced from 36
            .staggerReveal(6)

            PrimaryButton("Continue", perform: onNext)
                .padding(.top, 8)   // 👈 pulls it closer
                .padding(.bottom, 16)
                .staggerReveal(7)
        }
        .padding(.horizontal, 24)
        .background(Color.white.ignoresSafeArea())
    }

    // MARK: - Summary Row
    private func summaryRow(
        icon: String,
        label: String,
        value: String,
        accentColor: Color,
        bgColor: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(bgColor)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(accentColor)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Color.fathrMuted)
                    .kerning(0.7)
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.fathrBlack)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.fathrOff)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.fathrBorder, lineWidth: 1)
        )
    }
}

#Preview {
    PersonalizedSummaryView(onNext: {})
}
