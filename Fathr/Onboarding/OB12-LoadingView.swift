import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct OB12_LoadingView: View {
    var onNext: () -> Void
    @State private var progress: Double = 0.0
    @Binding var goal: String
    @Binding var situation: String
    @Binding var ageGroup: String
    @Binding var energyLevel: String
    @Binding var stressLevel: String
    @Binding var previousEfforts: [String]

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) {
                Text("Analyzing Your Responses")
                    .font(.system(.largeTitle, design: .default, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .accessibilityLabel("Analyzing Your Responses")

                Text("We’re building your personalized plan.")
                    .font(.system(.subheadline, design: .default, weight: .regular))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)

                Spacer()

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding(.bottom, 16)
                    .accessibilityLabel("Loading your personalized plan")

                ProgressView(value: min(max(progress, 0.0), 1.0), total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .tint(.black)
                    .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .accessibilityLabel("Progress: \(Int(progress * 100))%")

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
            .background(Color.white.ignoresSafeArea())
            .onAppear {
                if let userId = Auth.auth().currentUser?.uid {
                    print("OB12_LoadingView: Saving onboarding data for user \(userId)")
                    Firestore.firestore().collection("users").document(userId).setData([
                        "goal": goal,
                        "situation": situation,
                        "ageGroup": ageGroup,
                        "energyLevel": energyLevel,
                        "stressLevel": stressLevel,
                        "previousEfforts": previousEfforts,
                        "hasCompletedOnboarding": true,
                        "onboardingCompletedAt": Timestamp()
                    ], merge: true) { error in
                        if let error = error {
                            print("OB12_LoadingView: Error saving onboarding data: \(error.localizedDescription)")
                            // Optional: Alert user or retry
                        } else {
                            print("OB12_LoadingView: Onboarding data saved successfully")
                            withAnimation(.linear(duration: 2)) {
                                progress = 1.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                print("OB12_LoadingView: Calling onNext")
                                onNext()
                            }
                        }
                    }
                } else {
                    print("OB12_LoadingView: No user ID, cannot save onboarding data")
                    // Handle missing user ID (rare, as user should be signed in)
                    withAnimation(.linear(duration: 2)) {
                        progress = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        print("OB12_LoadingView: Calling onNext (no user ID)")
                        onNext()
                    }
                }
            }
        }
    }
}

#Preview("iPhone 14") {
    OB12_LoadingView(onNext: {}, goal: .constant(""), situation: .constant(""), ageGroup: .constant(""), energyLevel: .constant(""), stressLevel: .constant(""), previousEfforts: .constant([]))
}

#Preview("iPad Pro") {
    OB12_LoadingView(onNext: {}, goal: .constant(""), situation: .constant(""), ageGroup: .constant(""), energyLevel: .constant(""), stressLevel: .constant(""), previousEfforts: .constant([]))
}
