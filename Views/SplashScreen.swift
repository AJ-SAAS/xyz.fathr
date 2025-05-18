import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack {
                // Placeholder: Mimics black background with white "Fathr" text
                Text("Fathr")
                    .font(.largeTitle)
                    .fontDesign(.rounded)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(20)
                    .background(Color.black)
                    .cornerRadius(10)
                    .accessibilityLabel("Fathr App Logo")
                
                // Uncomment after adding FathrLogo image set
                /*
                Image("FathrLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .accessibilityLabel("Fathr App Logo")
                */
            }
        }
    }
}

#Preview {
    SplashScreen()
}
