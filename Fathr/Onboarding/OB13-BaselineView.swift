import SwiftUI

struct OB13_BaselineView: View {
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Your Starting Point")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("Your Starting Point")
                .padding(.horizontal)
            
            Text("Here’s where you stand today.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray) // Replaced Color(hex: "6B7280")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 12) {
                HStack {
                    Text("Vitality Score")
                    Spacer()
                    Text("6/10")
                }
                ProgressView(value: 6, total: 10)
                    .progressViewStyle(LinearProgressViewStyle())
                
                HStack {
                    Text("Fertility Readiness")
                    Spacer()
                    Text("5/10")
                }
                ProgressView(value: 5, total: 10)
                    .progressViewStyle(LinearProgressViewStyle())
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: onNext) {
                Text("Let’s Improve This")
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
    OB13_BaselineView(onNext: {})
}

