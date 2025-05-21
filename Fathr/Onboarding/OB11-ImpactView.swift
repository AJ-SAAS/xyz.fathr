import SwiftUI

struct OB11_ImpactView: View {
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Title
            Text("You have great potential to crush your goal")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .accessibilityLabel("You have great potential to crush your goal")
            
            // Full-size image
            Image("ob_image_1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Motivational illustration")

            Spacer()
            
            // Next button
            Button(action: onNext) {
                Text("Next")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .accessibilityLabel("Continue to next step")
        }
        .padding(.vertical)
    }
}

#Preview {
    OB11_ImpactView(onNext: {})
}

