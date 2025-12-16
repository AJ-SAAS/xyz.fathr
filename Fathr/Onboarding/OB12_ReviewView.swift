import SwiftUI
import StoreKit

struct OB12_ReviewView: View {
    var onNext: () -> Void
    @State private var didRequestReview = false

    var body: some View {
        VStack(spacing: 0) {
            // 🔥 Image: full width, maintains aspect ratio
            Image("fathrreviewimage1")
                .resizable()
                .scaledToFit()                    // Keeps aspect ratio
                .frame(maxWidth: .infinity)       // Forces it to fill width edge-to-edge

            // Any natural white space below the image remains

            Spacer() // Pushes the button to the very bottom

            // ✅ Only the black "Next >" button
            Button(action: onNext) {
                Text("Next >")
                    .font(.system(.headline, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32) // Nice spacing above home indicator
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white) // Ensures area below image is white
        .onAppear {
            requestReviewIfNeeded()
        }
    }

    private func requestReviewIfNeeded() {
        guard !didRequestReview else { return }
        didRequestReview = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}
