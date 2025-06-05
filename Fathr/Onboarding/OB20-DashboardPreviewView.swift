import SwiftUI

struct OB20_DashboardPreviewView: View {
    var onNext: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) { // Adjust spacing for iPad
                // Title
                Text("Your Custom Plan is Ready")
                    .font(.system(.largeTitle, design: .default, weight: .bold)) // Dynamic type
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                    .accessibilityLabel("Your Custom Plan is Ready")
                
                Spacer()
                
                // Dashboard Content
                VStack(spacing: 12) {
                    Text("Daily Recommendations")
                        .font(.system(.title3, design: .default, weight: .bold)) // Dynamic type
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Sleep: 8 hours\nHydration: 2L\nStress: Mindfulness")
                        .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
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
                    
                    Text("Tips")
                        .font(.system(.title3, design: .default, weight: .bold)) // Dynamic type
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("• Track habits daily\n• Upload tests to see trends")
                        .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                
                Spacer()
                
                // Button
                Button(action: onNext) {
                    Text("Let’s Get Started")
                        .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400)) // Cap button width
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .accessibilityLabel("Start using the app")
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
    OB20_DashboardPreviewView(onNext: {})
}

#Preview("iPad Pro") {
    OB20_DashboardPreviewView(onNext: {})
}
