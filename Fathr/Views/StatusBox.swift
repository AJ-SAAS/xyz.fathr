import SwiftUI

struct StatusBox: View {
    let title: String
    let status: String
    let description: String

    private var isGood: Bool {
        let s = status.lowercased()
        return s.contains("normal") || s.contains("typical") || s.contains("active") ||
               s.contains("mild") || s.contains("balanced") || s.contains("low")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Text(status)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(isGood ? Color(red: 0.23, green: 0.43, blue: 0.07) : Color(red: 0.52, green: 0.31, blue: 0.04))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(isGood ? Color(red: 0.92, green: 0.95, blue: 0.87) : Color(red: 0.98, green: 0.93, blue: 0.85))
                    .cornerRadius(20)
            }
            .padding(.bottom, 6)

            Text(description)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) status: \(status). \(description)")
    }
}
