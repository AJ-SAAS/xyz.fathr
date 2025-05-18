import SwiftUI
import FirebaseAnalytics

struct AnalyticsConsentView: View {
    @AppStorage("analyticsConsent") private var analyticsConsent = false
    @State private var showPrompt = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if showPrompt {
            VStack(spacing: 20) {
                Text("Help Us Improve Fathr")
                    .font(.title2)
                Text("Allow analytics to track app usage anonymously. No personal data is collected.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                Button("Allow") {
                    analyticsConsent = true
                    Analytics.setAnalyticsCollectionEnabled(true)
                    UserDefaults.standard.set(true, forKey: "hasSeenConsentPrompt")
                    showPrompt = false
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                Button("Decline") {
                    analyticsConsent = false
                    Analytics.setAnalyticsCollectionEnabled(false)
                    UserDefaults.standard.set(true, forKey: "hasSeenConsentPrompt")
                    showPrompt = false
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
}

struct AnalyticsConsentView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsConsentView()
    }
}
