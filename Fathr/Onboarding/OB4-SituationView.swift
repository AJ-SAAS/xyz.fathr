import SwiftUI

enum SituationOption: String, CaseIterable {
    case trying = "Actively Trying to Conceive"
    case planning = "Planning for the Future"
    case exploring = "Just Exploring My Health"
}

struct OB4_SituationView: View {
    @Binding var selectedOption: String
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Title and Subtitle
            VStack(alignment: .leading, spacing: 8) {
                Text("What’s Your Current Situation?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .accessibilityLabel("Question: What’s Your Current Situation?")
                
                Text("Let’s understand where you’re starting.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Spacer()
            
            // Answer Cards
            VStack(spacing: 12) {
                ForEach(SituationOption.allCases, id: \.rawValue) { option in
                    Button(action: {
                        selectedOption = option.rawValue
                    }) {
                        Text(option.rawValue)
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedOption == option.rawValue ? Color.black : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                    }
                    .accessibilityLabel("Select \(option.rawValue)")
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedOption.isEmpty ? Color.gray.opacity(0.3) : Color.black)
                    .cornerRadius(8)
            }
            .disabled(selectedOption.isEmpty)
            .accessibilityLabel("Continue to next step")
            .padding(.horizontal)
        }
    }
}

#Preview {
    OB4_SituationView(selectedOption: .constant(""), onNext: {})
}

