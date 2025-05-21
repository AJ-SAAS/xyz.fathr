import SwiftUI

struct OB15_WhyFathrView: View {
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text("Why Fathr?")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("Why Fathr?")
                .padding(.horizontal)

            // Subtitle
            Text("Fathr uses science-backed insights to help you achieve your goals.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            Spacer()

            // Updated image
            Image("ob_start_1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
                .accessibilityLabel("Why Fathr Illustration")

            Spacer()

            // Button
            Button(action: onNext) {
                Text("Next")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .accessibilityLabel("Continue to next step")
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

#Preview {
    OB15_WhyFathrView(onNext: {})
}

