import SwiftUI

enum PreviousEffortOption: String, CaseIterable {
    case diet = "Diet Changes"
    case exercise = "Exercise"
    case supplements = "Supplements"
    case none = "None"
}

struct OB10_PreviousEffortsView: View {
    @Binding var selectedOptions: [String]
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Title and Subtitle
            VStack(alignment: .leading, spacing: 8) {
                Text("What Have You Tried Before?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .accessibilityLabel("Question: What Have You Tried Before?")
                
                Text("Select all that apply to understand your past efforts.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray) // Replaced Color(hex: "6B7280") with .gray
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Spacer()
            
            // Answer Cards
            VStack(spacing: 12) {
                ForEach(PreviousEffortOption.allCases, id: \.rawValue) { option in
                    Button(action: {
                        if let index = selectedOptions.firstIndex(of: option.rawValue) {
                            selectedOptions.remove(at: index)
                        } else {
                            selectedOptions.append(option.rawValue)
                        }
                    }) {
                        Text(option.rawValue)
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(selectedOptions.contains(option.rawValue) ? Color.white : Color.white)
                            .foregroundColor(.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedOptions.contains(option.rawValue) ? Color.black : Color.gray.opacity(0.2), lineWidth: 2) // Replaced Color(hex: "E5E7EB") with .gray.opacity(0.2)
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
                    .background(.black)
                    .cornerRadius(8)
            }
            .accessibilityLabel("Continue to next step")
            .padding(.horizontal)
        }
    }
}

#Preview {
    OB10_PreviousEffortsView(selectedOptions: .constant([]), onNext: {})
}
