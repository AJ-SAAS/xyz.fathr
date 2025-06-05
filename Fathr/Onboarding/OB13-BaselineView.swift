import SwiftUI

struct OB13_BaselineView: View {
    var onNext: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) { // Adjust spacing for iPad
                // Title
                Text("Your Starting Point")
                    .font(.system(.largeTitle, design: .default, weight: .bold)) // Dynamic type
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                    .accessibilityLabel("Your Starting Point")
                
                // Subtitle
                Text("Here’s where you stand today.")
                    .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                
                Spacer()
                
                // Progress Indicators
                VStack(spacing: 12) {
                    HStack {
                        Text("Vitality Score")
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                        Spacer()
                        Text("6/10")
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                    }
                    ProgressView(value: 6, total: 10)
                        .progressViewStyle(LinearProgressViewStyle())
                        .tint(.black)
                        .frame(maxWidth: min(geometry.size.width * 0.9, 600)) // Cap progress bar width
                    
                    HStack {
                        Text("Fertility Readiness")
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                        Spacer()
                        Text("5/10")
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                    }
                    ProgressView(value: 5, total: 10)
                        .progressViewStyle(LinearProgressViewStyle())
                        .tint(.black)
                        .frame(maxWidth: min(geometry.size.width * 0.9, 600)) // Cap progress bar width
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                
                Spacer()
                
                // Next Button
                Button(action: onNext) {
                    Text("Let’s Improve This")
                        .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400)) // Cap button width
                        .padding()
                        .background(.black)
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
    OB13_BaselineView(onNext: {})
}

#Preview("iPad Pro") {
    OB13_BaselineView(onNext: {})
}
