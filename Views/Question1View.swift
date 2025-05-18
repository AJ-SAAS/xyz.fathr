import SwiftUI

enum ExerciseFrequency: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case rarely = "Rarely"
    case never = "Never"
}

struct Question1View: View {
    @Binding var selectedOption: String
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("How often do you exercise?")
                .font(.headline)
                .accessibilityLabel("Question: How often do you exercise?")

            ForEach(ExerciseFrequency.allCases, id: \.rawValue) { option in
                Button(action: {
                    selectedOption = option.rawValue
                    onNext()
                }) {
                    Text(option.rawValue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .accessibilityLabel("Select \(option.rawValue)")
            }
        }
        .padding()
    }
}

#Preview {
    Question1View(selectedOption: .constant(""), onNext: {})
}
