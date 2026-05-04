import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct OB12_LoadingView: View {
    var onNext: () -> Void

    @Binding var goal: String
    @Binding var situation: String
    @Binding var ageGroup: String
    @Binding var energyLevel: String
    @Binding var stressLevel: String
    @Binding var previousEfforts: [String]

    @EnvironmentObject var purchaseModel: PurchaseModel

    @State private var progress: Double = 0.0
    @State private var showPurchaseView: Bool = false
    @State private var currentStep: Int = 0

    let steps: [(icon: String, text: String)] = [
        ("doc.text.magnifyingglass", "Reading your answers"),
        ("heart.text.square",       "Mapping your fertility profile"),
        ("chart.line.uptrend.xyaxis", "Calculating your 90-day window"),
        ("checkmark.seal",          "Building your action plan")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Headline
            Group {
                Text("Building your\n")
                    .font(.playfair(36))
                    .foregroundColor(Color.fathrBlack)
                + Text("personal plan.")
                    .font(.playfairItalic(36))
                    .foregroundColor(Color.fathrBlue)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 60)
            .padding(.bottom, 10)

            Text("This only takes a moment.")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.fathrSub)
                .padding(.bottom, 52)

            // Animated step list
            VStack(alignment: .leading, spacing: 20) {
                ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                    LoadingStepRow(
                        icon: step.icon,
                        text: step.text,
                        state: stepState(for: i)
                    )
                }
            }
            .padding(.bottom, 52)

            // Progress bar
            VStack(alignment: .leading, spacing: 10) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.fathrBlueMid)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.fathrBlue)
                            .frame(width: geo.size.width * progress, height: 6)
                            .animation(.linear(duration: 0.3), value: progress)
                    }
                }
                .frame(height: 6)

                Text("\(Int(progress * 100))% complete")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.fathrMuted)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $showPurchaseView, onDismiss: {
            onNext()
        }) {
            PurchaseView(isPresented: $showPurchaseView, purchaseModel: purchaseModel)
                .environmentObject(purchaseModel)
        }
        .onAppear {
            startStepAnimation()
            saveOnboardingData()
        }
    }

    // MARK: - Step state
    private func stepState(for index: Int) -> LoadingStepState {
        if index < currentStep { return .done }
        if index == currentStep { return .active }
        return .waiting
    }

    // MARK: - Animate through steps
    private func startStepAnimation() {
        for i in 0..<steps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.52) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStep = i
                    progress = Double(i + 1) / Double(steps.count)
                }
            }
        }
    }

    // MARK: - UPDATED: Save Locally (Since Auth is after onboarding)
    private func saveOnboardingData() {
        OnboardingDataManager.shared.saveOnboardingData(
            journeyStage: situation,
            mainGoal: goal
        )
        
        // Still show paywall after animation
        simulateLoadingAndShowPaywall()
    }

    private func simulateLoadingAndShowPaywall() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            showPurchaseView = true
        }
    }
}

// MARK: - Step Row
enum LoadingStepState { case waiting, active, done }

struct LoadingStepRow: View {
    let icon: String
    let text: String
    let state: LoadingStepState

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconBg)
                    .frame(width: 40, height: 40)

                if state == .done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.fathrSuccess)
                } else if state == .active {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.fathrBlue)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.fathrMuted.opacity(0.5))
                }
            }

            Text(text)
                .font(.system(size: 15, weight: state == .active ? .semibold : .regular))
                .foregroundColor(textColor)
                .animation(.easeInOut(duration: 0.2), value: state)

            Spacer()

            if state == .done {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.fathrSuccess)
                    .transition(.scale.combined(with: .opacity))
            } else if state == .active {
                ProgressView()
                    .tint(Color.fathrBlue)
                    .scaleEffect(0.8)
            }
        }
    }

    private var iconBg: Color {
        switch state {
        case .done:   return Color(hex: "#E8F7EE")
        case .active: return Color.fathrBlueLight
        case .waiting: return Color.fathrOff
        }
    }

    private var textColor: Color {
        switch state {
        case .done:    return Color.fathrSub
        case .active:  return Color.fathrBlack
        case .waiting: return Color.fathrMuted
        }
    }
}

#Preview {
    OB12_LoadingView(
        onNext: {},
        goal: .constant("Improving sperm quality"),
        situation: .constant("Just starting to try"),
        ageGroup: .constant(""),
        energyLevel: .constant(""),
        stressLevel: .constant(""),
        previousEfforts: .constant([])
    )
    .environmentObject(PurchaseModel())
}
