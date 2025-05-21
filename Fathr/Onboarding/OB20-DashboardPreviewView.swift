import SwiftUI

struct OB20_DashboardPreviewView: View {
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Your Custom Plan is Ready")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("Your Custom Plan is Ready")
                .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 12) {
                Text("Daily Recommendations")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Sleep: 8 hours\nHydration: 2L\nStress: Mindfulness")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Text("Vitality Score")
                    Spacer()
                    Text("6/10")
                }
                ProgressView(value: 6, total: 10)
                    .progressViewStyle(LinearProgressViewStyle())
                
                Text("Tips")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("• Track habits daily\n• Upload tests to see trends")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: onNext) {
                Text("Let’s Get Started")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .accessibilityLabel("Start using the app")
            .padding(.horizontal)
        }
    }
}

#Preview {
    OB20_DashboardPreviewView(onNext: {})
}
