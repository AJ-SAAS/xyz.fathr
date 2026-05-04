import SwiftUI
import StoreKit

struct OB12_ReviewView: View {
    var onNext: () -> Void
    @State private var didRequestReview = false

    let reviews: [(quote: String, author: String, handle: String, result: String)] = [
        (
            quote: "We had been trying for over a year. Fathr broke everything down and gave us real steps to follow. I finally felt like I had a role in this.",
            author: "S.M.",
            handle: "Sophie5644",
            result: "Pregnant after 3 months on plan"
        ),
        (
            quote: "I sat on my results for 3 months not knowing what they meant. Fathr gave me a full breakdown and action plan the same day. Game changer.",
            author: "V.K.",
            handle: "Vicks-92",
            result: "Morphology improved 4% → 9%"
        ),
        (
            quote: "Told my sperm was 'fine' by my GP. Fathr showed me exactly where to improve. Already seeing better numbers on my retest.",
            author: "J.R.",
            handle: "Jurec777",
            result: "Motility up 18% in 6 weeks"
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            OnboardingDots(total: 3, current: 2)
                .padding(.top, 20)
                .padding(.bottom, 28)
                .staggerReveal(0)

            // Headline
            Group {
                Text("Real men.\n")
                    .font(.playfair(36))
                    .foregroundColor(Color.fathrBlack)
                + Text("Real results.")
                    .font(.playfairItalic(36))
                    .foregroundColor(Color.fathrBlue)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 10)
            .staggerReveal(1)

            Text("Don't just take our word for it.")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.fathrSub)
                .padding(.bottom, 32)
                .staggerReveal(2)

            // Review cards
            VStack(spacing: 14) {
                ForEach(Array(reviews.enumerated()), id: \.offset) { i, review in
                    ReviewCard(
                        quote: review.quote,
                        author: review.author,
                        handle: review.handle,
                        result: review.result
                    )
                    .staggerReveal(3 + i)
                }
            }
            .padding(.bottom, 16)   // 👈 reduced from 40

            PrimaryButton("Continue to my plan", perform: onNext)
                .padding(.top, 8)     // 👈 pulls button closer
                .padding(.bottom, 12)
                .staggerReveal(6)
        }
        .padding(.horizontal, 24)
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            requestReviewIfNeeded()
        }
    }

    private func requestReviewIfNeeded() {
        guard !didRequestReview else { return }
        didRequestReview = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}

// MARK: - Review Card
struct ReviewCard: View {
    let quote: String
    let author: String
    let handle: String
    let result: String

    var body: some View {
        HStack(alignment: .top, spacing: 0) {

            // Blue left accent bar
            Rectangle()
                .fill(Color.fathrBlue)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 12) {

                // Stars
                HStack(spacing: 3) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color.fathrBlue)
                    }
                }

                // Quote
                Text("\"\(quote)\"")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.fathrSub)
                    .lineSpacing(5)
                    .italic()
                    .fixedSize(horizontal: false, vertical: true)

                // Author row
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.fathrBlueLight)
                            .frame(width: 34, height: 34)
                        Text(String(author.prefix(1)))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.fathrBlue)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("@\(handle)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.fathrMuted)
                        Text(result)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.fathrSuccess)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.fathrOff)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.fathrBorder, lineWidth: 1)
        )
    }
}

#Preview {
    OB12_ReviewView(onNext: {})
}
