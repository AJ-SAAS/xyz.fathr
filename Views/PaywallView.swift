import SwiftUI

struct PaywallView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Unlock Premium Features")
                .font(.title)
                .bold()

            Text("• View advanced fertility analytics\n• Track your sperm health over time\n• Get personalized health tips\n• And more...")
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                print("Purchase logic will go here")
            }) {
                Text("Subscribe for $4.99/month")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Button("Restore Purchases") {
                print("Restore logic will go here")
            }
            .padding(.top)

            Button("Close") {
                // User can dismiss the sheet manually
            }
            .foregroundColor(.gray)
        }
        .padding()
    }
}

