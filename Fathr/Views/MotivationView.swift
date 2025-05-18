import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MotivationView: View {
    let exerciseFrequency: String
    let dietQuality: String
    let sleepHours: Double
    let stressLevel: String
    var onNext: () -> Void

    private let db = Firestore.firestore()

    var body: some View {
        VStack(spacing: 20) {
            Text("Small changes today can lead to big improvements in your wellness. Let’s get started!")
                .font(.body)
                .multilineTextAlignment(.center)
                .accessibilityLabel("Motivation: Small changes today improve your wellness.")

            Button("Continue") {
                saveAnswersToFirestore()
                onNext()
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10)
            .accessibilityLabel("Complete onboarding")
        }
        .padding()
    }

    private func saveAnswersToFirestore() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No user logged in")
            return
        }

        let answers: [String: Any] = [
            "exerciseFrequency": exerciseFrequency,
            "dietQuality": dietQuality,
            "sleepHours": sleepHours,
            "stressLevel": stressLevel,
            "completedAt": Timestamp()
        ]

        db.collection("users").document(userID).collection("onboarding").document("answers").setData(answers) { error in
            if let error = error {
                print("Error saving answers: \(error.localizedDescription)")
            } else {
                print("Answers saved successfully")
            }
        }
    }
}

#Preview {
    MotivationView(exerciseFrequency: "", dietQuality: "", sleepHours: 7.0, stressLevel: "", onNext: {})
}
