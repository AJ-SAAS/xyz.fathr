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
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) { // Adjust spacing for iPad
                // Title and Subtitle
                VStack(alignment: .leading, spacing: 8) {
                    Text("What Have You Tried Before?")
                        .font(.system(.largeTitle, design: .default, weight: .bold)) // Dynamic type
                        .foregroundColor(.black)
                        .accessibilityLabel("Question: What Have You Tried Before?")
                    
                    Text("Select all that apply to understand your past efforts.")
                        .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                .padding(.top, geometry.size.width > 600 ? 40 : 24) // Adjust top padding
                
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
                                .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                                .frame(maxWidth: min(geometry.size.width * 0.9, 600), alignment: .leading) // Cap card width
                                .padding()
                                .background(selectedOptions.contains(option.rawValue) ? Color.white : Color.white)
                                .foregroundColor(.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedOptions.contains(option.rawValue) ? Color.black : Color.gray.opacity(0.2), lineWidth: 2)
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
                        .background(.black)
                        .cornerRadius(8)
                }
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
    OB10_PreviousEffortsView(selectedOptions: .constant([]), onNext: {})
}

#Preview("iPad Pro") {
    OB10_PreviousEffortsView(selectedOptions: .constant([]), onNext: {})
}
