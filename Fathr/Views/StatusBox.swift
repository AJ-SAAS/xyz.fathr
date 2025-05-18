import SwiftUI

struct StatusBox: View {
    let title: String
    let status: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontDesign(.rounded)
            Text(status)
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundColor(colorForStatus(status))
            Text(description)
                .font(.caption)
                .fontDesign(.rounded)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) status: \(status). \(description)")
    }

    private func colorForStatus(_ status: String) -> Color {
        let lowercasedStatus = status.lowercased()
        if lowercasedStatus.contains("normal") ||
           lowercasedStatus.contains("typical") ||
           lowercasedStatus.contains("active") ||
           lowercasedStatus.contains("mild") ||
           lowercasedStatus.contains("balanced") {
            return .green
        }
        return .orange
    }
}
