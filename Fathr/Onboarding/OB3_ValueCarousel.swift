import SwiftUI

struct OB3_ValueCarousel: View {
    let onNext: () -> Void
    @State private var currentIndex = 0
    @State private var isVisible = true

    let items: [(image: String, title: String, description: String)] = [
        ("fathr_welcome", "Welcome to Fathr", "Your journey to a healthier family starts here."),
        ("fathr_track", "Track Sperm Health", "Log unlimited sperm test results to monitor your fertility."),
        ("fathr_boost", "Boost Fertility", "Get personalized tips to improve your sperm health."),
        ("fathr_legacy", "Build Your Legacy", "Reach your family goals faster with expert insights.")
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(items[currentIndex].image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: min(geometry.size.width * 0.9, 400))
                        .padding(.top, geometry.size.width > 600 ? 60 : 40)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : -20)
                        .accessibilityLabel(items[currentIndex].title)

                    Text(items[currentIndex].title)
                        .font(.system(.title2, design: .default, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .opacity(isVisible ? 1 : 0)

                    Text(items[currentIndex].description)
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .opacity(isVisible ? 1 : 0)

                    Spacer()

                    HStack(spacing: 8) {
                        ForEach(0..<items.count, id: \.self) { index in
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(index == currentIndex ? .black : .gray.opacity(0.3))
                        }
                    }
                    .padding(.bottom, 20)

                    Button(action: {
                        withAnimation {
                            isVisible = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                if currentIndex == items.count - 1 {
                                    print("OB3_ValueCarousel: Get Started tapped, moving to OB3_GoalView")
                                    onNext()
                                } else {
                                    currentIndex += 1
                                    isVisible = true
                                    print("OB3_ValueCarousel: Next slide \(currentIndex + 1)")
                                }
                            }
                        }
                    }) {
                        Text(currentIndex == items.count - 1 ? "Get Started" : "Next")
                            .font(.system(.headline, design: .default, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                            .padding()
                            .background(.black)
                            .cornerRadius(10)
                            .opacity(isVisible ? 1 : 0)
                            .scaleEffect(isVisible ? 1 : 0.95)
                    }
                    .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                    .accessibilityLabel(currentIndex == items.count - 1 ? "Get Started" : "Next")
                }
            }
            .onAppear {
                print("OB3_ValueCarousel: Appeared on slide \(currentIndex + 1)")
            }
        }
    }
}

#Preview("iPhone 14") {
    OB3_ValueCarousel(onNext: {})
}

#Preview("iPad Pro") {
    OB3_ValueCarousel(onNext: {})
}
