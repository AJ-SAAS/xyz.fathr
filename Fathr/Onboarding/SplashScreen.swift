import SwiftUI

struct SplashScreen: View {
    var onComplete: () -> Void

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.82
    @State private var rotation: Double = -8
    @State private var shadowRadius: CGFloat = 10
    @State private var shadowY: CGFloat = 6

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            Image("AppIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .shadow(
                    color: Color.fathrBlue.opacity(0.18),
                    radius: shadowRadius,
                    x: 0,
                    y: shadowY
                )
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .opacity(opacity)
        }
        .onAppear {
            // Phase 1 — spring in from tilted/small with character
            withAnimation(.spring(response: 0.6, dampingFraction: 0.62, blendDuration: 0)) {
                opacity = 1
                scale = 1.04
                rotation = 3
                shadowRadius = 24
                shadowY = 14
            }

            // Phase 2 — settle to neutral after spring
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                withAnimation(.easeOut(duration: 0.35)) {
                    scale = 1.0
                    rotation = 0
                    shadowRadius = 16
                    shadowY = 10
                }
            }

            // Phase 3 — gentle float loop
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    scale = 1.03
                    shadowRadius = 20
                    shadowY = 14
                }
            }

            // Complete after 2.6s
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                onComplete()
            }
        }
    }
}

#Preview {
    SplashScreen(onComplete: {})
}
