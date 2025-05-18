import SwiftUI

enum StressLevel: String, CaseIterable {
    case rarely = "Rarely"
    case sometimes = "Sometimes"
    case often = "Often"
    case always = "Always"
}

struct Question4View: View {
    @Binding var selectedOption: String
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("How often do you feel stressed?")
                .font(.headline)
                .accessibilityLabel("Question: How often do you feel stressed?")

            ForEach(StressLevel.allCases, id: \.rawValue) { option in
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
    Question4View(selectedOption: .constant(""), onNext: {})
}
