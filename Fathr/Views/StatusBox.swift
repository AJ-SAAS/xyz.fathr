import SwiftUI

struct StatusBox: View {
    let title: String
    let status: String
    let description: String

    private var isGood: Bool {
        let s = status.lowercased()
        return s.contains("normal") ||
               s.contains("typical") ||
               s.contains("balanced") ||
               s.contains("mild") ||
               s.contains("active")
    }

    private var textColor: Color {
        isGood ? .fathrSuccess : .fathrDanger
    }

    private var backgroundColor: Color {
        isGood ? Color.fathrBlueLight : Color.fathrDangerBg
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                Spacer()

                Text(status)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(textColor)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(backgroundColor)
                    .cornerRadius(20)
            }
            .padding(.bottom, 8)

            Text(description)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color.fathrOff)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.fathrBorder, lineWidth: 0.5)
        )
    }
}
