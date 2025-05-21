import SwiftUI

struct OB12_LoadingView: View {
    var onNext: () -> Void
    
    @State private var progress: Double = 0.0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Analyzing Your Responses")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("Analyzing Your Responses")
                .padding(.horizontal)
            
            Text("We’re building your personalized plan.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray) // Replaced Color(hex: "6B7280") with .gray
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            Spacer()
            
            ProgressView(value: min(max(progress, 0.0), 1.0), total: 1.0) // Clamped progress value
                .progressViewStyle(LinearProgressViewStyle())
                .tint(.black)
                .padding(.horizontal)
                .accessibilityLabel("Progress: \(Int(progress * 100))%")
            
            Spacer()
        }
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

#Preview {
    OB12_LoadingView(onNext: {})
}
