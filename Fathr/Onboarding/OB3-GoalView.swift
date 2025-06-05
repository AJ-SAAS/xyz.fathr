import SwiftUI

enum GoalOption: String, CaseIterable {
    case haveChild = "Have a Child"
    case boostVitality = "Boost Vitality & Energy"
    case trackSperm = "Track Sperm Health"
    case optimizeTestosterone = "Optimize Testosterone"
}

struct OB3_GoalView: View {
    @Binding var selectedOption: String
    var onNext: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) { // Adjust spacing for iPad
                // Title and Subtitle
                VStack(alignment: .leading, spacing: 8) {
                    Text("What’s Your Main Goal?")
                        .font(.system(.largeTitle, design: .default, weight: .bold)) // Dynamic type
                        .foregroundColor(.black)
                        .accessibilityLabel("Question: What’s Your Main Goal?")
                    
                    Text("This will help us tailor your plan.")
                        .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                .padding(.top, geometry.size.width > 600 ? 40 : 24) // Adjust top padding
                
                Spacer()
                
                // Answer Cards
                VStack(spacing: 12) {
                    ForEach(GoalOption.allCases, id: \.rawValue) { option in
                        Button(action: {
                            selectedOption = option.rawValue
                        }) {
                            Text(option.rawValue)
                                .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                                .frame(maxWidth: min(geometry.size.width * 0.9, 600), alignment: .leading) // Cap card width
                                .padding()
                                .background(selectedOption == option.rawValue ? Color.white : Color.white)
                                .foregroundColor(.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedOption == option.rawValue ? Color.black : Color.gray.opacity(0.2), lineWidth: 2)
                                )
                        }
                        .accessibilityLabel("Select \(option.rawValue)")
                    }
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                
                Spacer()
                
                // Next Button
                Button(action: onNext) {
                    Text("Next")
                        .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400)) // Cap button width
                        .padding()
                        .background(selectedOption.isEmpty ? Color.gray.opacity(0.2) : Color.black)
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
    OB3_GoalView(selectedOption: .constant(""), onNext: {})
}

#Preview("iPad Pro") {
    OB3_GoalView(selectedOption: .constant(""), onNext: {})
}


