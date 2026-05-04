import SwiftUI
import FirebaseAuth
import StoreKit

enum Trend {
    case up, down, none
}

extension Color {
    func darker(by percentage: Double) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return Color(UIColor(
            red: max(red - CGFloat(percentage), 0),
            green: max(green - CGFloat(percentage), 0),
            blue: max(blue - CGFloat(percentage), 0),
            alpha: alpha
        ))
    }
}

struct DashboardView: View {
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel
    @EnvironmentObject var authManager: AuthManager
    @State private var showInput = false
    @State private var showPaywall = false
    @State private var showSignUp = false
    @AppStorage("lastTipDate") private var lastTipDate: String = ""
    @State private var checkedTips: [Int: Bool] = [:]
    @Binding var selectedTab: Int
    @State private var showFullAnalysis = false
    @State private var selectedTest: TestData?
    @State private var isLoadingChallengeProgress = true
    @State private var navigateToChallenge = false
    @AppStorage("hasCompletedChallengeOnboarding") private var hasCompletedChallengeOnboarding = false

    @AppStorage("fathr_lastReviewRequestDate") private var lastReviewRequestDate: String = ""
    private let reviewCooldownDays: Double = 30

    var body: some View {
        NavigationStack {
                ZStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {   // Increased spacing
                            
                            // MARK: - IMPROVED HERO SECTION
                            VStack(spacing: 20) {
                                
                                // Logo
                                Image("fathr-logo-dash-2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 112)
                                    .padding(.top, 12)
                                
                                // Dynamic Greeting
                                VStack(spacing: 6) {
                                    Text(greetingText())
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 20)
                                    
                                    Text(formattedDate())
                                        .font(.system(size: 17, weight: .medium, design: .rounded))
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 20)
                                }
                            }
                            .padding(.bottom, 8)

                            // MARK: - CONTENT STARTS HERE
                            if testStore.tests.isEmpty {
                                HStack(alignment: .center, spacing: 16) {
                                    Button {
                                        if authManager.isGuest {
                                            showSignUp = true
                                        } else {
                                            showInput = true
                                        }
                                    } label: {
                                        AddTestCardView()
                                            .frame(maxWidth: .infinity, maxHeight: 160)
                                    }

                                    Button {
                                        navigateToChallenge = true
                                    } label: {
                                        SeventyFourDayResetCardView()
                                            .frame(maxWidth: .infinity, maxHeight: 160)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }

                            if !testStore.tests.isEmpty {
                                FertilitySnapshotView(
                                    selectedTab: $selectedTab,
                                    showPaywall: $showPaywall,
                                    showFullAnalysis: $showFullAnalysis,
                                    showInput: $showInput,
                                    showSignUp: $showSignUp,
                                    navigateToChallenge: $navigateToChallenge
                                )

                                CoreMetricsOverviewView()

                                FertilitySnapshotBarView(
                                    showPaywall: $showPaywall,
                                    showFullAnalysis: $showFullAnalysis
                                )

                                ChallengePromptCard(navigateToChallenge: $navigateToChallenge)

                                RecentTestsSection(
                                    selectedTab: $selectedTab,
                                    showPaywall: $showPaywall,
                                    selectedTest: $selectedTest
                                )

                                if let latestTest = testStore.tests.first {
                                    let (winningMetrics, improvementMetrics) = evaluateMetrics(for: latestTest)
                                    MetricCardView(
                                        title: "Where You Are Winning",
                                        metrics: winningMetrics,
                                        isWinning: true
                                    )
                                    MetricCardView(
                                        title: "Your Next Steps",
                                        metrics: improvementMetrics,
                                        isWinning: false
                                    )
                                }

                                DailyBoostTipsView(
                                    checkedTips: checkedTips,
                                    onTipToggle: { index in
                                        checkedTips[index] = !(checkedTips[index] ?? false)
                                    }
                                )
                            } else {
                                RecentTestsSection(
                                    selectedTab: $selectedTab,
                                    showPaywall: $showPaywall,
                                    selectedTest: $selectedTest
                                )
                            }

                            ArticlesView()
                            DisclaimerView()
                        }
                        .padding(.vertical)
                    }
                    .background(Color.white)
                }
            .navigationTitle("")
            .sheet(isPresented: $showInput) {
                TestInputView()
                    .environmentObject(testStore)
                    .environmentObject(purchaseModel)
            }
            .sheet(isPresented: $showPaywall) {
                PurchaseView(isPresented: $showPaywall, purchaseModel: purchaseModel)
            }
            .sheet(isPresented: $showSignUp) {
                AuthView(onAuthSuccess: {
                    showSignUp = false
                })
                .environmentObject(authManager)
                .environmentObject(purchaseModel)
            }
            .navigationDestination(isPresented: $showFullAnalysis) {
                if let latestTest = testStore.tests.first {
                    ResultsView(test: latestTest)
                        .environmentObject(purchaseModel)
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedTest != nil },
                set: { if !$0 { selectedTest = nil } }
            )) {
                if let test = selectedTest {
                    ResultsView(test: test)
                        .environmentObject(purchaseModel)
                }
            }
            .navigationDestination(isPresented: $navigateToChallenge) {
                challengeDestinationView()
            }
            .onAppear {
                updateDailyTips()
                loadChallengeProgress()
            }
            .onChange(of: testStore.tests) { newTests in
                guard let latest = newTests.first else { return }
                if Calendar.current.isDateInToday(latest.date) {
                    requestReviewIfEligible()
                }
            }
        }
    }

    // MARK: - Helper Functions (Added here)
    private func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default:      return "Good night"
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    @ViewBuilder
    private func challengeDestinationView() -> some View {
        if isLoadingChallengeProgress {
            ProgressView("Loading...").padding()
        } else if hasCompletedChallengeOnboarding,
                  let startDate = testStore.challengeProgress?.startDate {
            ChallengeView(startDate: startDate)
                .environmentObject(testStore)
                .environmentObject(authManager)
        } else if hasCompletedChallengeOnboarding {
            ChallengeView(startDate: Date())
                .environmentObject(testStore)
                .environmentObject(authManager)
        } else {
            ChallengeOnboardingView(
                onComplete: {
                    hasCompletedChallengeOnboarding = true
                    var days: [Int: TestStore.ChallengeDayProgress] = [:]
                    for day in 1...74 {
                        let dayTasks = ChallengeTasks.allDays
                            .first(where: { $0.dayNumber == day })?
                            .tasks ?? []
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
                        hardcoreMode: true
                    )
                    testStore.challengeProgress = progress
                    if let userId = authManager.currentUserID {
                        testStore.saveChallengeProgress(userId: userId) { success in
                            if !success {
                                print("DashboardView: Failed to save initial challenge progress")
                            }
                        }
                    }
                }
            )
            .environmentObject(testStore)
            .environmentObject(authManager)
        }
    }

    private func loadChallengeProgress() {
        guard let userId = authManager.currentUserID else {
            print("DashboardView: No user ID found — skipping challenge progress load.")
            isLoadingChallengeProgress = false
            return
        }
        print("DashboardView: Fetching challenge progress for user: \(userId)")
        testStore.fetchChallengeProgress(userId: userId) { progress in
            DispatchQueue.main.async {
                self.isLoadingChallengeProgress = false
                if progress?.startDate != nil {
                    self.hasCompletedChallengeOnboarding = true
                    print("DashboardView: Challenge progress found — marking onboarding as complete.")
                } else {
                    print("DashboardView: No startDate found — onboarding still pending.")
                }
            }
        }
    }

    private func evaluateMetrics(for test: TestData) -> ([String], [String]) {
        var winningMetrics: [String] = []
        var improvementMetrics: [String] = []

        let motilityThreshold = 40.0
        let concentrationThreshold = 15.0
        let morphologyThreshold = 4.0
        let dnaFragmentationThreshold = 15.0
        let semenQuantityThreshold = 1.4
        let pHMinThreshold = 7.2
        let pHMaxThreshold = 8.0

        func hasDeclinedDouble(metric: Double, historicalKeyPath: KeyPath<TestData, Double?>, threshold: Double) -> Bool {
            guard testStore.tests.count > 1 else { return false }
            let previousTests = testStore.tests.dropFirst()
            let avgHistorical = previousTests.reduce(0.0) { sum, test in
                sum + (test[keyPath: historicalKeyPath] ?? 0.0)
            } / Double(previousTests.count)
            return metric < avgHistorical && metric >= threshold
        }

        func hasDeclinedInt(metric: Int, historicalKeyPath: KeyPath<TestData, Int?>, threshold: Double) -> Bool {
            guard testStore.tests.count > 1 else { return false }
            let previousTests = testStore.tests.dropFirst()
            let avgHistorical = previousTests.reduce(0.0) { sum, test in
                sum + Double(test[keyPath: historicalKeyPath] ?? 0)
            } / Double(previousTests.count)
            return Double(metric) < avgHistorical && Double(metric) >= threshold
        }

        let motility = test.totalMobility ?? 0.0
        if motility >= motilityThreshold {
            winningMetrics.append("Motility: \(Int(motility))% (Great movement!)")
            if hasDeclinedDouble(metric: motility, historicalKeyPath: \.totalMobility, threshold: motilityThreshold) {
                improvementMetrics.append("Motility: \(Int(motility))% is strong, but down from your average. Try regular exercise to maintain it.")
            } else if motility < 50.0 {
                improvementMetrics.append("Motility: \(Int(motility))% is good. Aim for ≥ 50% with a diet rich in antioxidants.")
            }
        } else {
            improvementMetrics.append("Motility: \(Int(motility))% (Aim for ≥ 40% with zinc-rich foods like pumpkin seeds)")
        }

        if improvementMetrics.isEmpty {
            improvementMetrics.append("All metrics are excellent! Maintain with daily hydration and a nutrient-rich diet.")
        }

        return (winningMetrics, improvementMetrics)
    }

    private func updateDailyTips() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = formatter.string(from: Date())
        if lastTipDate != currentDate {
            checkedTips = [:]
            lastTipDate = currentDate
        }
    }

    private func requestReviewIfEligible() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        if let lastDate = formatter.date(from: lastReviewRequestDate),
           let cooldownDate = Calendar.current.date(byAdding: .day, value: Int(reviewCooldownDays), to: lastDate),
           cooldownDate > Date() {
            return
        }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
            lastReviewRequestDate = todayString
        }
    }

    private func calculateTrend() -> Trend {
        guard testStore.tests.count > 1 else { return .none }
        return .none
    }

    private func calculateAnalysisScore(_ test: TestData) -> Double {
        var score: Double = 0
        if test.appearance == .normal { score += 25 }
        if test.liquefaction == .normal { score += 25 }
        if let pH = test.pH, pH >= 7.2 && pH <= 8.0 { score += 25 }
        if let semenQuantity = test.semenQuantity, semenQuantity >= 1.4 { score += 25 }
        return score
    }
}

// MARK: - Add Test Card (UNCHANGED)
struct AddTestCardView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus")
                .font(.system(size: 20))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Add a New Sperm Test")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color(red: 0.7, green: 0.9, blue: 1.0))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

// MARK: - 74 Day Card (UNCHANGED)
struct SeventyFourDayResetCardView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "star.fill")
                .font(.system(size: 20))
                .foregroundColor(.yellow)
                .padding(8)
                .background(Color(red: 0.7, green: 0.9, blue: 1.0))
                .clipShape(Circle())
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("74 Day Reset Challenge")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color(red: 0.7, green: 0.9, blue: 1.0))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

// MARK: - Welcome Header (UNCHANGED)
struct WelcomeHeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome")
                    .font(.title)
                    .fontDesign(.rounded)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Text(formattedDate())
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundColor(.gray.opacity(0.8))
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}

// MARK: - Fertility Snapshot View (REDESIGNED)
struct FertilitySnapshotView: View {
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel
    @EnvironmentObject var authManager: AuthManager
    @Binding var selectedTab: Int
    @Binding var showPaywall: Bool
    @Binding var showFullAnalysis: Bool
    @Binding var showInput: Bool
    @Binding var showSignUp: Bool
    @Binding var navigateToChallenge: Bool

    private func scoreLabel(for score: Double) -> String {
        if score >= 70 { return "Looking strong" }
        if score >= 50 { return "Room to improve" }
        return "Let's get to work"
    }

    private func scoreColor(for score: Double) -> Color {
        if score >= 70 { return Color.green.darker(by: 0.2) }
        if score >= 50 { return Color.orange.darker(by: 0.1) }
        return Color.orange.darker(by: 0.2)
    }

    var body: some View {
        if !testStore.tests.isEmpty {
            let averages = calculateAverages()
            let latest = testStore.tests[0]

            HStack(alignment: .top, spacing: 12) {

                // MARK: Score card
                VStack(alignment: .center, spacing: 6) {
                    Text("Your Fathr Score")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)

                    Text(String(format: "%.1f", averages.overallScore))
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.black)

                    Text(scoreLabel(for: averages.overallScore))
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(scoreColor(for: averages.overallScore))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(scoreColor(for: averages.overallScore).opacity(0.12))
                        .cornerRadius(20)

                    if let trend = calculateScoreTrend() {
                        HStack(spacing: 3) {
                            Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 9, weight: .semibold))
                            Text(String(format: "%+.1f from last test", trend))
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(trend >= 0 ? Color.green.darker(by: 0.2) : .orange)
                    }

                    Divider().padding(.vertical, 2)

                    VStack(alignment: .leading, spacing: 4) {
                        ScoreChip(
                            label: "Motility",
                            value: latest.totalMobility.map { "\(Int($0))%" } ?? "—",
                            good: (latest.totalMobility ?? 0) >= 40
                        )
                        ScoreChip(
                            label: "Concentration",
                            value: latest.spermConcentration.map { "\(Int($0)) M/mL" } ?? "—",
                            good: (latest.spermConcentration ?? 0) >= 16
                        )
                        ScoreChip(
                            label: "Morphology",
                            value: latest.morphologyRate.map { "\(Int($0))%" } ?? "—",
                            good: (latest.morphologyRate ?? 0) >= 4
                        )
                        ScoreChip(
                            label: "DNA frag.",
                            value: latest.dnaFragmentationRisk.map { "\($0)%" } ?? "—",
                            good: (latest.dnaFragmentationRisk ?? 100) < 30
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(14)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )

                // MARK: Action cards column (now fully tappable)
                VStack(spacing: 10) {
                    Button {
                        if authManager.isGuest {
                            showSignUp = true
                        } else {
                            showInput = true
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "plus")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color(red: 0.09, green: 0.37, blue: 0.65))
                            }
                            Text("Add sperm test")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.04, green: 0.17, blue: 0.33))
                            Text("Log your results")
                                .font(.system(size: 10, design: .rounded))
                                .foregroundColor(Color(red: 0.09, green: 0.37, blue: 0.65))
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .background(Color(red: 0.7, green: 0.9, blue: 1.0))
                        .cornerRadius(14)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add a New Sperm Test")

                    Button {
                        navigateToChallenge = true
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.14, green: 0.42, blue: 0.07))
                            }
                            Text("74-day challenge")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.09, green: 0.20, blue: 0.02))
                            Text("Keep the streak")
                                .font(.system(size: 10, design: .rounded))
                                .foregroundColor(Color(red: 0.14, green: 0.42, blue: 0.07))
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .background(Color(red: 0.91, green: 0.95, blue: 0.87))
                        .cornerRadius(14)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("74 Day Reset Challenge")
                }
                .frame(maxWidth: .infinity)
            }
            .frame(minHeight: 220)
            .padding(.horizontal)
        }
    }

    private struct Averages {
        let overallScore: Double
        let motility: Double
        let concentration: Double
        let morphology: Double
        let dnaFragmentation: Double
        let spermAnalysis: Double
    }

    private func calculateAverages() -> Averages {
        let count = testStore.tests.count
        guard count > 0 else {
            return Averages(overallScore: 0, motility: 0, concentration: 0, morphology: 0, dnaFragmentation: 0, spermAnalysis: 0)
        }
        let totalMotility = testStore.tests.reduce(0.0) { $0 + min(($1.totalMobility ?? 0.0) * 2.5, 100.0) }
        let totalConcentration = testStore.tests.reduce(0.0) {
            let conc = $1.spermConcentration ?? 0.0
            let score = conc <= 15.0 ? (conc / 15.0) * 50.0 : 50.0 + ((conc - 15.0) / 85.0) * 50.0
            return $0 + min(score, 100.0)
        }
        let totalMorphology = testStore.tests.reduce(0.0) {
            let morph = $1.morphologyRate ?? 0.0
            let score = morph <= 4.0 ? (morph / 4.0) * 50.0 : 50.0 + ((morph - 4.0) / 11.0) * 50.0
            return $0 + min(score, 100.0)
        }
        let totalDnaFragmentation = testStore.tests.reduce(0.0) {
            let dna = Double($1.dnaFragmentationRisk ?? 0)
            let score = max(100.0 - ((dna / 15.0) * 50.0), 0.0)
            return $0 + score
        }
        let totalSpermAnalysis = testStore.tests.reduce(0.0) { $0 + calculateAnalysisScore($1) }
        let avgMotility = totalMotility / Double(count)
        let avgConcentration = totalConcentration / Double(count)
        let avgMorphology = totalMorphology / Double(count)
        let avgDnaFragmentation = totalDnaFragmentation / Double(count)
        let avgSpermAnalysis = totalSpermAnalysis / Double(count)
        let overallScore = (0.35 * avgMotility) + (0.30 * avgConcentration) + (0.15 * avgMorphology) +
                           (0.10 * avgDnaFragmentation) + (0.10 * avgSpermAnalysis)
        return Averages(
            overallScore: overallScore,
            motility: avgMotility,
            concentration: avgConcentration,
            morphology: avgMorphology,
            dnaFragmentation: avgDnaFragmentation,
            spermAnalysis: avgSpermAnalysis
        )
    }

    private func calculateAnalysisScore(_ test: TestData) -> Double {
        var score: Double = 0
        if test.appearance == .normal { score += 25 }
        if test.liquefaction == .normal { score += 25 }
        if let pH = test.pH, pH >= 7.2 && pH <= 8.0 { score += 25 }
        if let semenQuantity = test.semenQuantity, semenQuantity >= 1.4 { score += 25 }
        return score
    }

    private func calculateScoreTrend() -> Double? {
        guard testStore.tests.count >= 2 else { return nil }
        let latest = testStore.tests[0]
        let previous = testStore.tests[1]
        func score(for test: TestData) -> Double {
            let motility = min((test.totalMobility ?? 0.0) * 2.5, 100.0)
            let conc = test.spermConcentration ?? 0.0
            let concentration = conc <= 15.0 ? (conc / 15.0) * 50.0 : 50.0 + ((conc - 15.0) / 85.0) * 50.0
            let morph = test.morphologyRate ?? 0.0
            let morphology = morph <= 4.0 ? (morph / 4.0) * 50.0 : 50.0 + ((morph - 4.0) / 11.0) * 50.0
            let dna = Double(test.dnaFragmentationRisk ?? 0)
            let dnaScore = max(100.0 - ((dna / 15.0) * 50.0), 0.0)
            let analysis = calculateAnalysisScore(test)
            return (0.35 * motility) + (0.30 * min(concentration, 100)) +
                   (0.15 * min(morphology, 100)) + (0.10 * dnaScore) + (0.10 * analysis)
        }
        return score(for: latest) - score(for: previous)
    }
}

// MARK: - Score Chip
private struct ScoreChip: View {
    let label: String
    let value: String
    let good: Bool

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(good ? Color(red: 0.39, green: 0.60, blue: 0.13) : Color(red: 0.94, green: 0.62, blue: 0.15))
                .frame(width: 6, height: 6)
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Core Metrics Overview (REDESIGNED — 2x2 grid)
struct CoreMetricsOverviewView: View {
    @EnvironmentObject var testStore: TestStore

    var body: some View {
        if let latest = testStore.tests.first {
            VStack(alignment: .leading, spacing: 8) {
                Text("Key metrics")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 10) {
                    MetricTileView(
                        label: "Motility",
                        value: latest.totalMobility ?? 0,
                        maxValue: 100,
                        unit: "%",
                        whoMin: 40,
                        whoMax: 100
                    )
                    MetricTileView(
                        label: "Concentration",
                        value: latest.spermConcentration ?? 0,
                        maxValue: 100,
                        unit: "M/mL",
                        whoMin: 16,
                        whoMax: 100
                    )
                    MetricTileView(
                        label: "Morphology",
                        value: latest.morphologyRate ?? 0,
                        maxValue: 100,
                        unit: "%",
                        whoMin: 4,
                        whoMax: 100
                    )
                    MetricTileView(
                        label: "DNA frag.",
                        value: Double(latest.dnaFragmentationRisk ?? 0),
                        maxValue: 100,
                        unit: "%",
                        whoMin: 0,
                        whoMax: 30,
                        lowerIsBetter: true
                    )
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Metric Tile
struct MetricTileView: View {
    let label: String
    let value: Double
    let maxValue: Double
    let unit: String
    let whoMin: Double
    let whoMax: Double
    var lowerIsBetter: Bool = false

    private var isGood: Bool {
        lowerIsBetter ? value <= whoMax : value >= whoMin
    }

    private var barColor: Color {
        isGood ? Color(red: 0.39, green: 0.60, blue: 0.13) : Color(red: 0.94, green: 0.62, blue: 0.15)
    }

    private var statusLabel: String {
        isGood ? "On track" : "Room to improve"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.gray)

            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value == value.rounded() ? "\(Int(value))" : String(format: "%.1f", value))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                Text(unit)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.gray)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.12))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor)
                        .frame(width: geo.size.width * CGFloat(min(value / maxValue, 1.0)), height: 4)
                }
            }
            .frame(height: 4)

            Text(statusLabel)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(isGood ? Color(red: 0.23, green: 0.43, blue: 0.07) : Color(red: 0.52, green: 0.31, blue: 0.04))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.12), lineWidth: 0.5)
        )
    }
}

// MARK: - Fertility Snapshot Bar Card
struct FertilitySnapshotBarView: View {
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel
    @Binding var showPaywall: Bool
    @Binding var showFullAnalysis: Bool

    private func analysisScore(for test: TestData) -> Double {
        var score: Double = 0
        if test.appearance == .normal { score += 25 }
        if test.liquefaction == .normal { score += 25 }
        if let pH = test.pH, pH >= 7.2 && pH <= 8.0 { score += 25 }
        if let semenQuantity = test.semenQuantity, semenQuantity >= 1.4 { score += 25 }
        return score
    }

    var body: some View {
        if let latest = testStore.tests.first {
            VStack(alignment: .leading, spacing: 10) {
                Text("Fertility snapshot")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.black)

                SnapshotBarRow(label: "Analysis", value: min(analysisScore(for: latest), 100), maxValue: 100)
                SnapshotBarRow(label: "Motility", value: min(latest.totalMobility ?? 0, 100), maxValue: 100)
                SnapshotBarRow(label: "Concentration", value: min(latest.spermConcentration ?? 0, 100), maxValue: 100)
                SnapshotBarRow(label: "Morphology", value: min(latest.morphologyRate ?? 0, 100), maxValue: 100)

                Divider()

                Button(action: {
                    if purchaseModel.isSubscribed {
                        showFullAnalysis = true
                    } else {
                        showPaywall = true
                    }
                }) {
                    Text("View full analysis →")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 13)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
                .accessibilityLabel("View Full Analysis")
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.12), lineWidth: 0.5)
            )
            .padding(.horizontal)
        }
    }
}

// MARK: - Snapshot Bar Row
private struct SnapshotBarRow: View {
    let label: String
    let value: Double
    let maxValue: Double

    private var barColor: Color {
        value > 75 ? Color(red: 0.39, green: 0.60, blue: 0.13) : Color(red: 0.94, green: 0.62, blue: 0.15)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.gray)
                .frame(width: 90, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 5)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor)
                        .frame(width: geo.size.width * CGFloat(min(value / maxValue, 1.0)), height: 5)
                }
            }
            .frame(height: 5)

            Text("\(Int(value))")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
                .frame(width: 28, alignment: .trailing)
        }
    }
}

// MARK: - Challenge Prompt Card
struct ChallengePromptCard: View {
    @EnvironmentObject var testStore: TestStore
    @Binding var navigateToChallenge: Bool

    var body: some View {
        Button(action: { navigateToChallenge = true }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 40, height: 40)
                    Image(systemName: "star.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 0.98, green: 0.78, blue: 0.46))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("74-day reset challenge")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    if let startDate = testStore.challengeProgress?.startDate {
                        let day = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
                        let remaining = max(74 - day, 0)
                        Text("Day \(day + 1) · \(remaining) days remaining")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.6))
                    } else {
                        Text("Start your journey today")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            .padding(14)
            .background(Color.black)
            .cornerRadius(16)
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("74 Day Reset Challenge")
    }
}

// MARK: - Progress Bar View (UNCHANGED)
struct ProgressBarView: View {
    let label: String
    let value: Double
    let maxValue: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 17))
                    .fontDesign(.rounded)
                    .foregroundColor(.black)
                Spacer()
                Text("\(Int(value))/100")
                    .font(.system(size: 17))
                    .fontDesign(.rounded)
                    .foregroundColor(.black)
            }
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(barColor.opacity(0.3))
                    .frame(height: 18)
                Rectangle()
                    .fill(barColor)
                    .frame(width: CGFloat(value / maxValue) * UIScreen.main.bounds.width * 0.9, height: 18)
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            Text(statusText)
                .font(.system(size: 13))
                .fontDesign(.rounded)
                .foregroundColor(barColor)
                .padding(.leading, 2)
        }
        .padding(.horizontal)
    }

    private var barColor: Color {
        value > 75 ? .green : value >= 25 ? .yellow : .orange
    }

    private var statusText: String {
        value > 75 ? "Optimal" : value >= 25 ? "Needs boost" : "Low"
    }
}

// MARK: - Recent Tests Section (UNCHANGED)
struct RecentTestsSection: View {
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel
    @Binding var selectedTab: Int
    @Binding var showPaywall: Bool
    @Binding var selectedTest: TestData?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Logs")
                .font(.title2)
                .fontDesign(.rounded)
                .fontWeight(.bold)
                .padding(.horizontal)

            if testStore.tests.isEmpty {
                VStack(spacing: 8) {
                    Text("No tests available.")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.gray)
                    Text("Tap the Add a New Sperm Test card to add your first test.")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.gray.opacity(0.8))
                }
                .padding(.horizontal)
            } else {
                ForEach(testStore.tests.prefix(5)) { test in
                    Button(action: {
                        if purchaseModel.isSubscribed {
                            selectedTest = test
                        } else {
                            showPaywall = true
                        }
                    }) {
                        TestCardView(test: test)
                            .overlay(
                                Group {
                                    if !purchaseModel.isSubscribed {
                                        Color.white.opacity(0.5)
                                            .cornerRadius(10)
                                        Image(systemName: "lock.fill")
                                            .font(.title)
                                            .foregroundColor(.gray)
                                    }
                                }
                            )
                    }
                    .padding(.horizontal)
                }

                if testStore.tests.count > 5 {
                    Button(action: {
                        if purchaseModel.isSubscribed {
                            selectedTab = 1
                        } else {
                            showPaywall = true
                        }
                    }) {
                        Text("View All Results")
                            .font(.subheadline.bold())
                            .fontDesign(.rounded)
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal)
                    .accessibilityLabel("View all test results")
                }
            }
        }
    }
}

// MARK: - Test Card View (UNCHANGED)
struct TestCardView: View {
    let test: TestData

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: statusIcon(for: test.analysisStatus))
                .foregroundColor(statusColor(for: test.analysisStatus))
                .font(.system(size: 18))
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate(test.date))
                    .font(.headline)
                    .fontDesign(.rounded)
                    .foregroundColor(.black)
                Text(statusLabel(for: test.analysisStatus))
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(statusColor(for: test.analysisStatus).opacity(0.2))
                    .foregroundColor(statusColor(for: test.analysisStatus))
                    .cornerRadius(6)
                Text("Count: \(Int(test.spermConcentration ?? 0)) M/mL • Motility: \(Int(test.totalMobility ?? 0))%")
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    private func statusLabel(for status: String) -> String {
        switch status.lowercased() {
        case "typical": return "Healthy"
        case "atypical": return "Needs Attention"
        default: return "Unknown"
        }
    }

    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "typical": return .green
        case "atypical": return .orange
        default: return .gray
        }
    }

    private func statusIcon(for status: String) -> String {
        switch status.lowercased() {
        case "typical": return "checkmark.seal.fill"
        case "atypical": return "exclamationmark.triangle.fill"
        default: return "questionmark.circle.fill"
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let relativeDate = formatter.localizedString(for: date, relativeTo: Date())
        return relativeDate == "in 0 seconds" ? "Today" : relativeDate.capitalized
    }
}

// MARK: - Daily Boost Tips (UNCHANGED)
struct DailyBoostTipsView: View {
    let checkedTips: [Int: Bool]
    let onTipToggle: (Int) -> Void

    var body: some View {
        Text("Daily Boost Tips")
            .font(.title2)
            .fontDesign(.rounded)
            .fontWeight(.bold)
            .padding(.horizontal)

        let dailyTips = getDailyTips()
        ForEach(dailyTips, id: \.self) { tipIndex in
            let tip = DailyBoostTips.tips[tipIndex]
            HStack(alignment: .center, spacing: 8) {
                Button(action: {
                    onTipToggle(tipIndex)
                }) {
                    Image(systemName: checkedTips[tipIndex] == true ? "checkmark.square.fill" : "square")
                        .foregroundColor(checkedTips[tipIndex] == true ? Color.blue : .gray)
                        .font(.system(size: 20))
                }
                .accessibilityLabel(checkedTips[tipIndex] == true ? "Uncheck tip" : "Check tip")

                Text(tip)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.vertical, 4)
            .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
            .padding(.horizontal)
        }
    }

    private func getDailyTips() -> [Int] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = formatter.string(from: Date())
        let seed = Int(currentDate.replacingOccurrences(of: "-", with: "")) ?? 0
        var random = SeededRandomGenerator(seed: seed)
        var indices = Array(0..<DailyBoostTips.tips.count)
        var selectedIndices: [Int] = []
        for _ in 0..<3 {
            guard !indices.isEmpty else { break }
            let randomIndex = Int(random.next() % UInt64(indices.count))
            selectedIndices.append(indices.remove(at: randomIndex))
        }
        return selectedIndices.sorted()
    }
}

// MARK: - Disclaimer (UNCHANGED)
struct DisclaimerView: View {
    var body: some View {
        Text("Visualizations are based on WHO 6th Edition standards for informational purposes only. Fathr is not a medical device. Consult a doctor for fertility concerns.")
            .font(.caption)
            .foregroundColor(.gray)
            .italic()
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .padding(.top)
    }
}

// MARK: - Metric Card (UNCHANGED)
struct MetricCardView: View {
    let title: String
    let metrics: [String]
    let isWinning: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontDesign(.rounded)
                .fontWeight(.bold)
                .foregroundColor(.black)

            if metrics.isEmpty {
                Text("No metrics to display.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                ForEach(metrics, id: \.self) { metric in
                    HStack {
                        Image(systemName: isWinning ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(isWinning ? .green : .orange)
                        Text(metric)
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

// MARK: - Daily Boost Tips Data (UNCHANGED)
struct DailyBoostTips {
    static let tips = [
        "Drink at least 2L of water today.",
        "Avoid hot tubs and saunas this week.",
        "Take 10 minutes to meditate and reduce stress.",
        "Cut caffeine intake below 200mg today.",
        "Wear looser underwear to improve testicular cooling.",
        "Take a brisk 30-minute walk.",
        "Sleep at least 7 hours tonight.",
        "Eat a handful of walnuts — great for sperm motility.",
        "Avoid alcohol completely today.",
        "Switch from plastic bottles to glass or stainless steel.",
        "Eat dark leafy greens with at least one meal.",
        "Add zinc-rich foods like pumpkin seeds to your diet today.",
        "Avoid using your laptop directly on your lap.",
        "No smoking or vaping today — sperm health depends on it.",
        "Stretch for 5–10 minutes after waking up.",
        "Cook with olive oil instead of vegetable oils.",
        "Replace sugary snacks with fruit today.",
        "Skip porn for the day — dopamine reset.",
        "Avoid any exposure to pesticides (wash veggies well).",
        "Don't microwave food in plastic containers.",
        "Focus on chewing your food slowly today.",
        "Avoid screen time 30 minutes before bed.",
        "Switch from soda to sparkling water.",
        "Take your multivitamin with CoQ10 today.",
        "Eat fatty fish (like salmon) at least once this week.",
        "Add L-carnitine supplement to your routine — boosts sperm movement.",
        "Do 20 squats today — improves blood flow to the pelvic region.",
        "Avoid trans fats — they're lethal to motility.",
        "Try antioxidant-rich berries today (blueberries, strawberries).",
        "Avoid bike rides longer than 30 minutes today.",
        "Eat Brazil nuts for selenium to support sperm count.",
        "Add a boiled egg to your breakfast — full of nutrients for sperm production.",
        "Avoid soy products today — may affect hormone balance.",
        "Reduce screen time after dinner — supports hormonal recovery.",
        "Try a short cold shower (30s–1min) to stimulate testosterone.",
        "Eat foods rich in folate: spinach, lentils, avocado.",
        "Avoid processed meats today.",
        "Don't skip meals — your body needs fuel to build quality sperm.",
        "Take a Vitamin C supplement today.",
        "Cook dinner using garlic or turmeric — both have fertility benefits.",
        "Avoid stress triggers today — even brief stress spikes affect sperm DNA.",
        "Take an Omega-3 capsule or eat sardines today.",
        "Stay off your phone for the first hour after waking.",
        "Sleep with blackout curtains or eye mask.",
        "Eat dark chocolate with high cocoa content — supports antioxidants.",
        "Today's goal: no sugar at all. Focus on clean eating.",
        "Journal for 5 minutes before bed — lower cortisol = better sperm.",
        "No alcohol, no screens after 8pm — discipline wins.",
        "Do deep breathing: 4 seconds in, 4 out. Repeat 10 times.",
        "Text your partner something loving — connection supports health, too."
    ]
}

// MARK: - Seeded Random Generator (UNCHANGED)
struct SeededRandomGenerator {
    private var seed: UInt64
    private var state: UInt64

    init(seed: Int) {
        self.seed = UInt64(abs(seed))
        self.state = self.seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

// MARK: - Preview (UNCHANGED)
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let testStore = TestStore()
        testStore.tests = [
            TestData(
                id: UUID().uuidString,
                appearance: .normal,
                liquefaction: .normal,
                consistency: .medium,
                semenQuantity: 2.0,
                pH: 7.4,
                totalMobility: 80.0,
                progressiveMobility: 40.0,
                nonProgressiveMobility: 10.0,
                travelSpeed: 0.1,
                mobilityIndex: 60.0,
                still: 30.0,
                agglutination: .mild,
                spermConcentration: 20.0,
                totalSpermatozoa: 40.0,
                functionalSpermatozoa: 15.0,
                roundCells: 0.5,
                leukocytes: 0.2,
                liveSpermatozoa: 70.0,
                morphologyRate: 5.0,
                pathology: 10.0,
                headDefect: 3.0,
                neckDefect: 2.0,
                tailDefect: 1.0,
                date: Date(),
                dnaFragmentationRisk: 10,
                dnaRiskCategory: "Low"
            )
        ]
        return DashboardView(selectedTab: .constant(0))
            .environmentObject(testStore)
            .environmentObject(PurchaseModel())
            .environmentObject(AuthManager())
    }
}
