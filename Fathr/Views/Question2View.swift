import SwiftUI

enum DietQuality: String, CaseIterable {
    case balanced = "Balanced"
    case highProtein = "High-protein"
    case needsImprovement = "Needs improvement"
    case unsure = "Unsure"
}

struct Question2View: View {
    @Binding var selectedOption: String
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("How would you describe your diet?")
                .font(.headline)
                .accessibilityLabel("Question: How would you describe your diet?")

            ForEach(DietQuality.allCases, id: \.rawValue) { option in
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
    Question2View(selectedOption: .constant(""), onNext: {})
}
