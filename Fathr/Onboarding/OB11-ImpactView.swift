import SwiftUI

struct OB11_ImpactView: View {
    var onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 32 : 24) { // Adjust spacing for iPad
                Spacer()
                
                // Title
                Text("You have great potential to crush your goal")
                    .font(.system(.title, design: .default, weight: .bold)) // Dynamic type
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                    .accessibilityLabel("You have great potential to crush your goal")
                
                // Full-size image
                Image("ob_image_1")
                    .resizable()
                    .scaledToFit() // Fixed: replaced incorrect .scaled Concept with .scaledToFit()
                    .frame(maxWidth: min(geometry.size.width * 0.9, 500)) // Cap image width
                    .accessibilityLabel("Motivational illustration")
                
                Spacer()
                
                // Next Button
                Button(action: onNext) {
                    Text("Next")
                        .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400)) // Cap button width
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                .padding(.bottom, geometry.size.width > 600 ? 60 : 40) // Adjust for iPad
                .accessibilityLabel("Continue to next step")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, geometry.size.width > 600 ? 40 : 24) // Adjust vertical padding
            .background(Color.white.ignoresSafeArea())
        }
    }
}

#Preview("iPhone 14") {
    OB11_ImpactView(onNext: {})
}

#Preview("iPad Pro") {
    OB11_ImpactView(onNext: {})
}
