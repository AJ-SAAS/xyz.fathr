import SwiftUI

struct OB1_SplashScreen: View {
    var onGetStarted: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()

                    Image("Fathr_logo_white")
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width * 0.45, 300))
                        .accessibilityLabel("Fathr Logo")

                    VStack(spacing: 12) {
                        Text("Congratulations.")
                            .font(.system(.title2, design: .default, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)

                        Text("You're taking the first step toward a healthier, stronger legacy.")
                            .font(.system(.body, design: .default, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    }
                    .padding(.top, geometry.size.width > 600 ? 60 : 40)

                    Spacer()

                    Button(action: {
                        onGetStarted()
                    }) {
                        Text("Get Started")
                            .font(.system(.headline, design: .default, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                            .padding()
                            .background(.black)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct OB1_SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        OB1_SplashScreen(onGetStarted: {})
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
        
        OB1_SplashScreen(onGetStarted: {})
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
            .previewDisplayName("iPad Pro")
    }
}
