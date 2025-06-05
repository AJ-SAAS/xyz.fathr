import SwiftUI

struct OB15_WhyFathrView: View {
    var onNext: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) { // Adjust spacing for iPad
                // Title
                Text("Why Fathr?")
                    .font(.system(.largeTitle, design: .default, weight: .bold)) // Dynamic type
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                    .accessibilityLabel("Why Fathr?")
                
                // Subtitle
                Text("Fathr uses science-backed insights to help you achieve your goals.")
                    .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                
                Spacer()
                
                // Image
                Image("ob_start_1")
                    .resizable()
                    .scaledToFit() // Changed to scaledToFit for clarity
                    .frame(maxWidth: min(geometry.size.width * 0.9, 500)) // Cap image width
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                    .accessibilityLabel("Why Fathr Illustration")
                
                Spacer()
                
                // Button
                Button(action: onNext) {
                    Text("Next")
                        .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400)) // Cap button width
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .accessibilityLabel("Continue to next step")
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                .padding(.bottom, geometry.size.width > 600 ? 60 : 40) // Adjust for iPad
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, geometry.size.width > 600 ? 40 : 24) // Adjust vertical padding
            .background(Color.white.ignoresSafeArea())
        }
    }
}

#Preview("iPhone 14") {
    OB15_WhyFathrView(onNext: {})
}

#Preview("iPad Pro") {
    OB15_WhyFathrView(onNext: {})
}
