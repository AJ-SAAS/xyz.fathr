import SwiftUI
import UIKit

struct FathrProgressCurve: View {

    private struct Milestone {
        let label: String
        let score: Int
        let t: Double
    }

    private let milestones: [Milestone] = [
        .init(label: "Today",   score: 32, t: 0.00),
        .init(label: "7 Days",  score: 38, t: 0.15),
        .init(label: "30 Days", score: 54, t: 0.42)
    ]

    private let goalT: Double = 0.88

    @State private var drawProgress: CGFloat = 0
    @State private var dotPulse: CGFloat = 1.0
    @State private var goalPulse: CGFloat = 1.0
    @State private var goalVisible: Bool = false
    @State private var milestoneScales: [CGFloat] = [1, 1, 1]
    @State private var triggeredMilestones: Set<Int> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("YOUR 90-DAY CURVE")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color.fathrMuted)
                        .kerning(0.8)
                    Text("Sperm quality score")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.fathrSub)
                }
                Spacer()
            }
            .padding(.bottom, 14)

            // Canvas - Full width graph
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let pts = curvePoints(w: w, h: h)
                let fullPath = curvePath(pts: pts)
                let travelT = min(Double(drawProgress), goalT)
                let dotPos = interpolate(pts: pts, t: travelT)
                let goalPos = interpolate(pts: pts, t: goalT)

                ZStack {
                    // Faint dashed background
                    fullPath
                        .stroke(Color.fathrBlueMid.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))

                    // Gradient fill
                    Path { p in
                        p.addPath(fullPath.trimmedPath(from: 0, to: CGFloat(travelT)))
                        p.addLine(to: CGPoint(x: dotPos.x, y: h))
                        p.addLine(to: CGPoint(x: 0, y: h))
                        p.closeSubpath()
                    }
                    .fill(LinearGradient(colors: [Color.fathrBlue.opacity(0.18), .clear], startPoint: .top, endPoint: .bottom))

                    // Main smooth curve
                    fullPath
                        .trim(from: 0, to: CGFloat(travelT))
                        .stroke(Color.fathrBlue, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    // Milestone dots
                    ForEach(milestones.indices, id: \.self) { i in
                        let m = milestones[i]
                        let p = interpolate(pts: pts, t: m.t)
                        let reached = Double(drawProgress) >= m.t - 0.01

                        ZStack {
                            Circle().stroke(Color.fathrBlue, lineWidth: 2.5).frame(width: 14, height: 14)
                            Circle().fill(Color.white).frame(width: 10, height: 10)
                            if reached {
                                Circle().fill(Color.fathrBlue).frame(width: 7, height: 7)
                            }
                        }
                        .scaleEffect(milestoneScales[i])
                        .position(p)
                        .opacity(reached ? 1 : 0.25)
                    }

                    // Goal dot with natural gradient pulse
                    if goalVisible {
                        Circle()
                            .fill(RadialGradient(colors: [Color(hex: "#A8E6B8").opacity(0.5), .clear], center: .center, startRadius: 10, endRadius: 32))
                            .frame(width: 42 * goalPulse, height: 42 * goalPulse)
                            .position(goalPos)
                        
                        Circle().fill(Color(hex: "#34C759")).frame(width: 22, height: 22).position(goalPos)
                        Circle().fill(Color.white).frame(width: 12, height: 12).position(goalPos)
                        Circle().fill(Color(hex: "#34C759")).frame(width: 7, height: 7).position(goalPos)
                    }

                    // Travelling dot
                    if !goalVisible {
                        Circle().fill(Color.fathrBlue.opacity(0.25)).frame(width: 32 * dotPulse, height: 32 * dotPulse).position(dotPos)
                        Circle().fill(Color.white).frame(width: 17, height: 17).shadow(color: Color.fathrBlue.opacity(0.4), radius: 5).position(dotPos)
                        Circle().fill(Color.fathrBlue).frame(width: 9, height: 9).position(dotPos)
                    }
                }
                .onChange(of: drawProgress) { checkMilestones(progress: Double($0), pts: pts) }
            }
            .frame(height: 155)

            // X-axis labels aligned with dots
            HStack(spacing: 0) {
                ForEach(milestones.indices, id: \.self) { i in
                    let reached = Double(drawProgress) >= milestones[i].t - 0.01
                    Text(milestones[i].label)
                        .font(.system(size: 11, weight: reached ? .semibold : .medium))
                        .foregroundColor(reached ? Color.fathrBlue : Color.fathrMuted)
                        .frame(maxWidth: .infinity)
                }
                
                Text("Day 74")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(goalVisible ? Color(hex: "#34C759") : Color.fathrMuted)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 12)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.fathrBorder, lineWidth: 1))
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8)) { drawProgress = 1.0 }
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { dotPulse = 1.6 }
        }
    }

    private func checkMilestones(progress: Double, pts: [CGPoint]) {
        for (i, m) in milestones.enumerated() {
            if progress >= m.t - 0.01 && !triggeredMilestones.contains(i) {
                triggeredMilestones.insert(i)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { milestoneScales[i] = 1.45 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { milestoneScales[i] = 1.0 }
                }
            }
        }
        
        if progress >= goalT - 0.01 && !goalVisible {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) { goalVisible = true }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) { goalPulse = 1.65 }
        }
    }

    private func curvePoints(w: CGFloat, h: CGFloat) -> [CGPoint] {
        let raw: [(Double, Double)] = [
            (0.00, 0.93), (0.06, 0.88), (0.14, 0.82), (0.24, 0.71),
            (0.35, 0.58), (0.47, 0.47), (0.58, 0.37), (0.69, 0.27),
            (0.78, 0.20), (0.85, 0.16), (0.92, 0.13), (1.00, 0.11)
        ]
        return raw.map { CGPoint(x: $0.0 * w, y: $0.1 * h) }
    }

    private func curvePath(pts: [CGPoint]) -> Path {
        var path = Path()
        guard pts.count > 1 else { return path }
        path.move(to: pts[0])
        for i in 1..<pts.count {
            let p = pts[i-1]
            let n = pts[i]
            let cp1 = CGPoint(x: p.x + (n.x - p.x) * 0.58, y: p.y)
            let cp2 = CGPoint(x: n.x - (n.x - p.x) * 0.52, y: n.y)
            path.addCurve(to: n, control1: cp1, control2: cp2)
        }
        return path
    }

    private func interpolate(pts: [CGPoint], t: Double) -> CGPoint {
        guard pts.count > 1 else { return .zero }
        let s = max(0, min(1, t)) * Double(pts.count - 1)
        let i = min(Int(s), pts.count - 2)
        let f = s - Double(i)
        let a = pts[i], b = pts[i + 1]
        return CGPoint(x: a.x + CGFloat(f) * (b.x - a.x), y: a.y + CGFloat(f) * (b.y - a.y))
    }
}

#Preview {
    FathrProgressCurve().padding(24)
}
