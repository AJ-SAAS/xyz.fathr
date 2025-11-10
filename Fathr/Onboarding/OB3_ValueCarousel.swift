import SwiftUI

struct OB3_ValueCarousel: View {
    let onNext: () -> Void
    
    @State private var currentIndex = 0
    @State private var isVisible = true
    
    private let items: [(image: String, title: String, description: String)] = [
        ("fathr-white-blue",    "Welcome to Fathr",                     "Your journey to a healthier family starts here."),
        ("ob_signup",         "Track Your Progress",                  "Easily log sperm test results and see how your health improves over time."),
        ("wellness-coach-2",   "Ask Your Wellness Coach",              "Get instant, personalized wellness guidance for better fertility and energy."),
        ("74-day-challenge",  "Join the Fertility Challenge",         "Follow simple daily habits to strengthen your health and vitality."),
        ("fathrpro",          "Explore Your Resource Center",         "Read expert-backed tips and stay informed on every step of your journey."),
        ("fathr-legacy1",     "Build Your Legacy",                    "Reach your family goals faster with insights made for men ready to grow.")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 20)
            
            // ✅ Larger square image — responsive up to 60% of screen width
            Image(items[currentIndex].image)
                .resizable()
                .scaledToFit()
                .frame(
                    width: UIScreen.main.bounds.width * 0.6,
                    height: UIScreen.main.bounds.width * 0.6
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(radius: 8, y: 4)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : -20)
                .animation(.easeOut(duration: 0.3), value: isVisible)
                .accessibilityLabel(items[currentIndex].title)
            
            // ---- Title ----
            Text(items[currentIndex].title)
                .font(.system(.title, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .opacity(isVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: isVisible)
            
            // ---- Description ----
            Text(items[currentIndex].description)
                .font(.system(.body))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(isVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: isVisible)
            
            Spacer()
            
            // ---- Page dots ----
            HStack(spacing: 8) {
                ForEach(items.indices, id: \.self) { i in
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(i == currentIndex ? .white : .white.opacity(0.4))
                        .animation(.easeInOut(duration: 0.2), value: currentIndex)
                }
            }
            .padding(.bottom, 16)
            
            // ---- Button ----
            Button(action: advance) {
                Text(currentIndex == items.count - 1 ? "Let's Begin" : "Next")
                    .font(.system(.headline, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white)
                    .clipShape(Capsule())
            }
            .frame(maxWidth: 340)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.94)
            .animation(.spring(response: 0.32, dampingFraction: 0.8), value: isVisible)
        }
        .onAppear {
            isVisible = true
            print("OB3_ValueCarousel: slide \(currentIndex + 1)")
        }
    }
    
    private func advance() {
        withAnimation { isVisible = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.5)) {
                if currentIndex == items.count - 1 {
                    onNext()
                } else {
                    currentIndex += 1
                    isVisible = true
                }
            }
        }
    }
}

#Preview("iPhone 15") {
    OB3_ValueCarousel(onNext: {})
}
