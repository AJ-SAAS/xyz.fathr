import SwiftUI

struct OB11_ImpactView: View {
    var onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 32 : 24) {
                Spacer()
                
                // Title
                Text("You have great potential to crush your goal")
                    .font(.system(.title, design: .default, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .accessibilityLabel("You have great potential to crush your goal")
                
                // New Bold Text Above Image
                Text("Your sperm health transition")
                    .font(.system(.title2, design: .default, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .padding(.top, 16)
                    .accessibilityLabel("Your sperm health transition")
                
                // Full-Width Image
                Image("ob_image_1")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped() // Ensure image doesn't overflow
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .accessibilityLabel("Motivational illustration of sperm health transition")
                
                // New Text Below Image
                Text("Based on Fathr’s historical data, Most men see sperm improvements within 30 days. By day 74, count, motility, and quality often improve significantly!")
                    .font(.system(.body, design: .default, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .padding(.top, 8)
                    .accessibilityLabel("Based on Fathr’s historical data, most men see sperm improvements within 30 days. By day 74, count, motility, and quality often improve significantly.")
                
                Spacer()
                
                // Next Button
                Button(action: onNext) {
                    Text("Next")
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                .accessibilityLabel("Continue to next step")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
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
