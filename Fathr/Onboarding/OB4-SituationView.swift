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
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) { // Adjust spacing for iPad
                // Title and Subtitle
                VStack(alignment: .leading, spacing: 8) {
                    Text("What’s Your Current Situation?")
                        .font(.system(.largeTitle, design: .default, weight: .bold)) // Dynamic type
                        .foregroundColor(.black)
                        .accessibilityLabel("Question: What’s Your Current Situation?")
                    
                    Text("Let’s understand where you’re starting.")
                        .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                .padding(.top, geometry.size.width > 600 ? 40 : 24) // Adjust top padding
                
                Spacer()
                
                // Answer Cards
                VStack(spacing: 12) {
                    ForEach(SituationOption.allCases, id: \.rawValue) { option in
                        Button(action: {
                            selectedOption = option.rawValue
                        }) {
                            Text(option.rawValue)
                                .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                                .frame(maxWidth: min(geometry.size.width * 0.9, 600), alignment: .leading) // Cap card width
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
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                
                Spacer()
                
                Button(action: onNext) {
                    Text("Next")
                        .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400)) // Cap button width
                        .padding()
                        .background(selectedOption.isEmpty ? Color.gray.opacity(0.3) : Color.black)
                        .cornerRadius(8)
                }
                .disabled(selectedOption.isEmpty)
                .accessibilityLabel("Continue to next step")
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                .padding(.bottom, geometry.size.width > 600 ? 60 : 40) // Adjust for iPad
            }
            .frame(maxWidth: .infinity)
            .background(Color.white.ignoresSafeArea())
        }
    }
}

#Preview("iPhone 14") {
    OB4_SituationView(selectedOption: .constant(""), onNext: {})
}

#Preview("iPad Pro") {
    OB4_SituationView(selectedOption: .constant(""), onNext: {})
}
