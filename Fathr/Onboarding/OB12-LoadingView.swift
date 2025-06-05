import SwiftUI

struct OB12_LoadingView: View {
    var onNext: () -> Void
    
    @State private var progress: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) { // Adjust spacing for iPad
                // Title
                Text("Analyzing Your Responses")
                    .font(.system(.largeTitle, design: .default, weight: .bold)) // Dynamic type
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                    .accessibilityLabel("Analyzing Your Responses")
                
                // Subtitle
                Text("We’re building your personalized plan.")
                    .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                
                Spacer()
                
                // Progress Bar
                ProgressView(value: min(max(progress, 0.0), 1.0), total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .tint(.black)
                    .frame(maxWidth: min(geometry.size.width * 0.9, 600)) // Cap progress bar width
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                    .accessibilityLabel("Progress: \(Int(progress * 100))%")
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, geometry.size.width > 600 ? 40 : 24) // Adjust vertical padding
            .background(Color.white.ignoresSafeArea())
            .onAppear {
                // Simulate loading progress
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    if progress < 1.0 {
                        progress += 0.05
                    } else {
                        timer.invalidate()
                        onNext()
                    }
                }
            }
        }
    }
}

#Preview("iPhone 14") {
    OB12_LoadingView(onNext: {})
}

#Preview("iPad Pro") {
    OB12_LoadingView(onNext: {})
}
