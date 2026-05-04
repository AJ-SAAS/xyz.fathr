import SwiftUI
import FirebaseAuth
import UIKit  // For haptics

// MARK: - Main View
struct ChallengeOnboardingView: View {
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var authManager: AuthManager

    @State private var currentPage = 0
    @State private var isSavingProgress = false
    @State private var navigateToChallenge = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var xpBounce = false

    var onComplete: () -> Void
    private let totalPages = 4

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fathrSurface.ignoresSafeArea()

                VStack(spacing: 0) {
                    dotsView
                        .padding(.top, 20)
                        .padding(.bottom, 12)

                    TabView(selection: $currentPage) {
                        OnboardingPage1(onNext: nextPage).tag(0)
                        OnboardingPage2(onNext: nextPage).tag(1)
                        OnboardingPage3(onNext: nextPage).tag(2)
                        OnboardingPage4(
                            isSaving: isSavingProgress,
                            xpBounce: $xpBounce,
                            onBegin: startChallenge
                        ).tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToChallenge) {
                if let startDate = testStore.challengeProgress?.startDate {
                    ChallengeView(startDate: startDate)
                        .environmentObject(testStore)
                        .environmentObject(authManager)
                } else {
                    Text("Preparing your transformation...")
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Something went wrong"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func nextPage() {
        triggerHaptic(style: .light)
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            currentPage += 1
        }
    }

    private var dotsView: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { i in
                Circle()
                    .fill(i == currentPage ? Color.fathrGreen : Color.fathrBorder)
                    .frame(width: i == currentPage ? 10 : 8, height: i == currentPage ? 10 : 8)
            }
        }
    }

    private func startChallenge() {
        guard !isSavingProgress, let userId = authManager.currentUserID else {
            errorMessage = "Unable to start: No user signed in."
            showErrorAlert = true
            return
        }

        withAnimation(.spring(response: 0.4)) { xpBounce = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation { xpBounce = false }
        }

        isSavingProgress = true

        var days: [Int: TestStore.ChallengeDayProgress] = [:]
        for day in 1...74 {
            let dayTasks = ChallengeTasks.allDays
                .first(where: { $0.dayNumber == day })?.tasks ?? []
            let taskProgress = dayTasks.map { _ in TestStore.ChallengeTaskProgress(completed: false) }
            days[day] = TestStore.ChallengeDayProgress(
                tasks: taskProgress,
                mood: nil,
                energy: nil,
                journalEntry: nil
            )
        }

        let progress = TestStore.ChallengeProgress(
            startDate: Date(),
            days: days,
            fhi: 0,
            hardcoreMode: false
        )

        testStore.challengeProgress = progress

        testStore.saveChallengeProgress(userId: userId) { success in
            DispatchQueue.main.async {
                isSavingProgress = false
                if success {
                    onComplete()
                    navigateToChallenge = true
                } else {
                    errorMessage = "Failed to save progress. Check your connection and try again."
                    showErrorAlert = true
                }
            }
        }
    }

    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Page 1
struct OnboardingPage1: View {
    let onNext: () -> Void
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 0) {
            MountainIllustrationView(day: 1)
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 40)
                .animation(.easeOut(duration: 0.7), value: showContent)

            VStack(spacing: 16) {
                Text("74 days to a\nbetter you.")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.fathrDark)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .minimumScaleFactor(0.85)

                Text("This isn't a challenge — it's a transformation. Build the daily habits that support your energy, vitality, and long-term wellness.")
                    .font(.system(size: 17))
                    .foregroundColor(.fathrMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 12)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 30)
            .animation(.easeOut(duration: 0.7).delay(0.2), value: showContent)

            Spacer()

            FathrButton(title: "Let's Go", style: .primary, action: onNext)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.5), value: showContent)
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { showContent = true } }
    }
}

// MARK: - Page 2: Three Phases (Fixed Subtext)
struct OnboardingPage2: View {
    let onNext: () -> Void
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 0) {
            PhaseBarsView()
                .frame(height: 170)
                .padding(.horizontal, 24)
                .padding(.top, 20)

            VStack(spacing: 16) {
                Text("Three phases")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.fathrDark)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .minimumScaleFactor(0.85)

                Text("Your 74 days are structured so each phase builds on the last — habits compound, and so do the results.")
                    .font(.system(size: 16.5))
                    .foregroundColor(.fathrMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                PhaseRow(range: "Days 1–25", name: "Foundation", description: "Build the core habits", shade: Color(red: 0.624, green: 0.792, blue: 0.647), textColor: Color(red: 0.031, green: 0.204, blue: 0.169))
                PhaseRow(range: "Days 26–50", name: "Optimization", description: "Deepen and intensify", shade: Color(red: 0.365, green: 0.792, blue: 0.647), textColor: Color(red: 0.016, green: 0.204, blue: 0.169))
                PhaseRow(range: "Days 51–74", name: "Mastery", description: "Lock it in for life", shade: Color.fathrGreen, textColor: .white)
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)

            Spacer()

            FathrButton(title: "Next", style: .primary, action: onNext)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { showContent = true } }
    }
}

// MARK: - Page 3: Five Pillars (Fixed Title + Subtext)
struct OnboardingPage3: View {
    let onNext: () -> Void
    @State private var showContent = false

    private let pillars: [(icon: String, color: Color, textColor: Color, name: String, detail: String)] = [
        ("drop.fill",          Color(red: 0.902, green: 0.945, blue: 0.984), Color(red: 0.094, green: 0.373, blue: 0.647), "Nutrition",       "Whole foods, hydration, nourishing your body daily"),
        ("figure.run",         Color(red: 0.980, green: 0.929, blue: 0.855), Color(red: 0.522, green: 0.310, blue: 0.043), "Exercise",        "Movement, strength, and cardio to build lasting energy"),
        ("moon.fill",          Color(red: 0.933, green: 0.929, blue: 0.996), Color(red: 0.325, green: 0.290, blue: 0.718), "Sleep",           "Rest and recovery — the foundation of everything else"),
        ("brain.head.profile", Color(red: 0.984, green: 0.918, blue: 0.941), Color(red: 0.600, green: 0.204, blue: 0.345), "Mental wellness", "Mindfulness, journaling, and stress management"),
        ("sun.max.fill",       Color(red: 0.918, green: 0.953, blue: 0.871), Color(red: 0.231, green: 0.427, blue: 0.067), "Lifestyle",       "Sunlight, heat avoidance, and daily check-ins")
    ]

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                Text("Five pillars.")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.fathrDark)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .minimumScaleFactor(0.85)
                    .padding(.horizontal, 20)

                Text("Each day has five quests — one per pillar. Small actions, consistent over time, add up to real change.")
                    .font(.system(size: 16.5))
                    .foregroundColor(.fathrMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 20)
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                ForEach(pillars, id: \.name) { pillar in
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(pillar.color)
                                .frame(width: 44, height: 44)
                            Image(systemName: pillar.icon)
                                .font(.system(size: 20))
                                .foregroundColor(pillar.textColor)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(pillar.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.fathrDark)
                            Text(pillar.detail)
                                .font(.system(size: 14))
                                .foregroundColor(.fathrMuted)
                                .lineSpacing(2)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.fathrBorder, lineWidth: 0.5))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Text("For health and wellness purposes only. Not medical advice. Consult a healthcare professional before making significant lifestyle changes.")
                .font(.system(size: 11))
                .foregroundColor(Color(red: 0.706, green: 0.702, blue: 0.682))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 20)

            Spacer()

            FathrButton(title: "Next", style: .primary, action: onNext)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { showContent = true } }
    }
}

// MARK: - Page 4
struct OnboardingPage4: View {
    let isSaving: Bool
    @Binding var xpBounce: Bool
    let onBegin: () -> Void
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color.fathrLime)
                    .frame(width: 110, height: 110)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(red: 0.165, green: 0.290, blue: 0.000))
            }
            .padding(.top, 30)
            .scaleEffect(xpBounce ? 1.18 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.5), value: xpBounce)

            Text("Day 1 starts now.")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.fathrDark)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .minimumScaleFactor(0.85)

            Text("74 days. Five pillars. One transformation.\nThat's the deal you just made with yourself.")
                .font(.system(size: 17))
                .foregroundColor(.fathrMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 28)
                .padding(.top, 12)

            VStack(spacing: 0) {
                CommitRow(label: "Duration",     value: "74 days")
                CommitRow(label: "Daily quests", value: "5 per day",     isLast: false)
                CommitRow(label: "XP to earn",   value: "Up to 370/day", isLast: false)
                CommitRow(label: "Final level",  value: "Transformed",   isLast: true)
            }
            .background(Color.white)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.fathrBorder, lineWidth: 0.5))
            .padding(.horizontal, 24)
            .padding(.top, 28)

            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.165, green: 0.290, blue: 0.000))
                Text("+100 XP starter bonus")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(red: 0.165, green: 0.290, blue: 0.000))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 11)
            .background(Color.fathrLime)
            .cornerRadius(30)
            .padding(.top, 20)

            Spacer()

            Button(action: onBegin) {
                HStack(spacing: 8) {
                    if isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.165, green: 0.290, blue: 0.000)))
                            .scaleEffect(0.9)
                        Text("Starting...")
                    } else {
                        Text("Begin Day 1")
                    }
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 0.165, green: 0.290, blue: 0.000))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(isSaving ? Color.fathrLime.opacity(0.7) : Color.fathrLime)
                .cornerRadius(16)
            }
            .disabled(isSaving)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { showContent = true } }
    }
}

// MARK: - Supporting Views (unchanged from previous)
struct PhaseBarsView: View {
    @State private var bar1Progress: CGFloat = 0
    @State private var bar2Progress: CGFloat = 0
    @State private var bar3Progress: CGFloat = 0

    private let phases: [(label: String, targetHeight: CGFloat, color: Color)] = [
        ("1–25",  0.48, Color(red: 0.624, green: 0.882, blue: 0.773)),
        ("26–50", 0.72, Color(red: 0.365, green: 0.792, blue: 0.647)),
        ("51–74", 0.95, Color.fathrGreen)
    ]

    var body: some View {
        GeometryReader { geo in
            let barW = (geo.size.width - 64) / 3.0
            let maxBarHeight = geo.size.height - 60

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.882, green: 0.961, blue: 0.933))

                HStack(alignment: .bottom, spacing: 16) {
                    ForEach(0..<3, id: \.self) { i in
                        let progress = i == 0 ? bar1Progress : (i == 1 ? bar2Progress : bar3Progress)
                        let ph = phases[i]

                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(ph.color)
                                .frame(width: barW, height: maxBarHeight * progress)
                                .shadow(color: ph.color.opacity(0.4), radius: 6, y: 4)

                            Text(ph.label)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(red: 0.031, green: 0.204, blue: 0.169))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.3)) {
                bar1Progress = phases[0].targetHeight
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.9)) {
                bar2Progress = phases[1].targetHeight
            }
            withAnimation(.spring(response: 0.65, dampingFraction: 0.75).delay(1.5)) {
                bar3Progress = phases[2].targetHeight
            }
        }
    }
}

struct PhaseRow: View {
    let range: String
    let name: String
    let description: String
    let shade: Color
    let textColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Text(range)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(textColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(shade)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.fathrDark)
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.fathrMuted)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(red: 0.965, green: 0.965, blue: 0.957))
        .cornerRadius(14)
    }
}

struct CommitRow: View {
    let label: String
    let value: String
    var isLast: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.fathrMuted)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.fathrDark)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 15)
        .overlay(
            Group {
                if !isLast {
                    Divider()
                        .padding(.leading, 18)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        )
    }
}

struct FathrButton: View {
    enum Style { case primary, ghost }

    let title: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(style == .primary
                    ? Color(red: 0.165, green: 0.290, blue: 0.000)
                    : .fathrMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(style == .primary ? Color.fathrLime : Color.clear)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(style == .ghost ? Color.fathrBorder : Color.clear, lineWidth: 1)
                )
        }
    }
}
