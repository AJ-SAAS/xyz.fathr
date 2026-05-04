import SwiftUI

// MARK: - MAIN HERO VIEW
struct MountainIllustrationView: View {
    let day: Int

    private var progress: Double {
        Double(day) / 74.0
    }

    private var isSummit: Bool {
        day >= 74
    }

    var body: some View {
        ZStack {

            // 🌅 SKY (sunrise → sunset)
            LinearGradient(
                colors: skyColors(),
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))

            // ☀️ SUN PATH
            Circle()
                .fill(Color.yellow.opacity(0.9))
                .frame(width: 52, height: 52)
                .offset(x: 90, y: CGFloat(120 - progress * 180))

            // ☁️ CLOUDS
            CloudLayer(progress: progress)

            // ⛰️ MOUNTAIN
            MountainShape(progress: progress)
                .fill(
                    LinearGradient(
                        colors: [.white, Color.gray.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 200)
                .offset(y: 60)

            // 🚩 MILESTONES
            MilestoneFlags(day: day)

            // 🏁 SUMMIT EFFECT
            if isSummit {
                SummitGlow()
            }
        }
        .frame(height: 240)
        .clipped()
        .overlay(
            VStack {
                Spacer()
                Text(isSummit ? "🏁 SUMMIT REACHED" : "Climbing...")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.bottom, 10)
            }
        )
    }

    // MARK: SKY SHIFT
    private func skyColors() -> [Color] {
        let t = progress

        return [
            Color(red: 0.55 + 0.15*t, green: 0.75 - 0.2*t, blue: 1.0 - 0.4*t),
            Color(red: 0.95 - 0.3*t, green: 0.65 - 0.25*t, blue: 0.9 - 0.3*t)
        ]
    }
}

// MARK: - MOUNTAIN SHAPE
struct MountainShape: Shape {
    var progress: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.6))
        path.addLine(to: CGPoint(x: w * 0.5, y: h * (0.8 - progress * 0.5)))
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.55))
        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()

        return path
    }
}

// MARK: - CLOUDS
struct CloudLayer: View {
    let progress: Double

    var body: some View {
        HStack {
            Circle()
                .fill(Color.white.opacity(0.35))
                .frame(width: 60, height: 28)
                .offset(x: CGFloat(progress * 50))

            Circle()
                .fill(Color.white.opacity(0.25))
                .frame(width: 80, height: 36)
                .offset(x: CGFloat(-progress * 60))
        }
        .padding(.top, 40)
    }
}

// MARK: - FLAGS
struct MilestoneFlags: View {
    let day: Int

    private let milestones = [7,14,21,28,35,42,49,56,63,70,74]

    var body: some View {
        ZStack {
            ForEach(milestones, id: \.self) { m in
                if day >= m {
                    VStack(spacing: 2) {
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 2, height: 18)

                        Image(systemName: "flag.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.red)
                    }
                    .offset(x: CGFloat(m) * 2.5 - 90, y: CGFloat(-m))
                }
            }
        }
    }
}

// MARK: - SUMMIT GLOW
struct SummitGlow: View {
    @State private var pulse = false

    var body: some View {
        Circle()
            .fill(Color.yellow.opacity(0.25))
            .frame(width: 140, height: 140)
            .scaleEffect(pulse ? 1.35 : 0.9)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}
