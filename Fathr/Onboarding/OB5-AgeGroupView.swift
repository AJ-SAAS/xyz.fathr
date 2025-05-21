import SwiftUI

enum AgeGroupOption: String, CaseIterable {
    case under25 = "Under 25"
    case twentyFiveTo34 = "25–34"
    case thirtyFiveTo44 = "35–44"
    case over44 = "Over 44"
}

struct OB5_AgeGroupView: View {
    @Binding var selectedOption: String
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Title and Subtitle
            VStack(alignment: .leading, spacing: 8) {
                Text("What’s Your Age Group?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .accessibilityLabel("Question: What’s Your Age Group?")
                
                Text("This helps us tailor recommendations.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray) // Replaced Color(hex: "6B7280") with .gray
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Spacer()
            
            // Answer Cards
            VStack(spacing: 12) {
                ForEach(AgeGroupOption.allCases, id: \.rawValue) { option in
                    Button(action: {
                        selectedOption = option.rawValue
                    }) {
                        Text(option.rawValue)
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(selectedOption == option.rawValue ? Color.white : Color.white)
                            .foregroundColor(.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedOption == option.rawValue ? Color.black : Color.gray.opacity(0.2), lineWidth: 2) // Replaced Color(hex: "E5E7EB") with .gray.opacity(0.2)
                            )
                    }
                    .accessibilityLabel("Select \(option.rawValue)")
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Next Button
            Button(action: onNext) {
                Text("Next")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedOption.isEmpty ? Color.gray.opacity(0.2) : Color.black) // Replaced Color(hex: "E5E7EB") with .gray.opacity(0.2)
                    .cornerRadius(8)
            }
            .disabled(selectedOption.isEmpty)
            .accessibilityLabel("Continue to next step")
            .padding(.horizontal)
        }
    }
}

#Preview {
    OB5_AgeGroupView(selectedOption: .constant(""), onNext: {})
}
