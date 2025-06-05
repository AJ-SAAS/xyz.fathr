import SwiftUI
import FirebaseAnalytics

struct AnalyticsConsentView: View {
    @AppStorage("analyticsConsent") private var analyticsConsent = false
    @State private var showPrompt = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            if showPrompt {
                VStack(spacing: geometry.size.width > 600 ? 24 : 20) { // Adjust spacing for iPad
                    // Title
                    Text("Help Us Improve Fathr")
                        .font(.system(.title2, design: .default, weight: .bold)) // Dynamic type
                        .foregroundColor(.black)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                        .accessibilityLabel("Help Us Improve Fathr")
                    
                    // Description
                    Text("Allow analytics to track app usage anonymously. No personal data is collected.")
                        .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                        .accessibilityLabel("Allow analytics to track app usage anonymously. No personal data is collected.")
                    
                    // Allow Button
                    Button(action: {
                        analyticsConsent = true
                        Analytics.setAnalyticsCollectionEnabled(true)
                        UserDefaults.standard.set(true, forKey: "hasSeenConsentPrompt")
                        showPrompt = false
                        dismiss()
                    }) {
                        Text("Allow")
                            .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                            .foregroundColor(.white)
                            .frame(maxWidth: min(geometry.size.width * 0.8, 400)) // Cap button width
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                    .accessibilityLabel("Allow analytics")
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                    
                    // Decline Button
                    Button(action: {
                        analyticsConsent = false
                        Analytics.setAnalyticsCollectionEnabled(false)
                        UserDefaults.standard.set(true, forKey: "hasSeenConsentPrompt")
                        showPrompt = false
                        dismiss()
                    }) {
                        Text("Decline")
                            .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                            .foregroundColor(.black)
                            .frame(maxWidth: min(geometry.size.width * 0.8, 400)) // Cap button width
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel("Decline analytics")
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                    .padding(.bottom, geometry.size.width > 600 ? 60 : 40) // Adjust for iPad
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, geometry.size.width > 600 ? 40 : 24) // Adjust vertical padding
                .background(Color.white.ignoresSafeArea())
            }
        }
    }
}

#Preview("iPhone 14") {
    AnalyticsConsentView()
}

#Preview("iPad Pro") {
    AnalyticsConsentView()
}
