import SwiftUI

struct TrackView: View {
    @EnvironmentObject var testStore: TestStore
    @State private var showTestInput = false

    var body: some View {
        NavigationStack {
            ScrollView {
                TrackContentView(showTestInput: $showTestInput)
            }
            .background(Color.white)
            .navigationTitle("Track")
            .sheet(isPresented: $showTestInput) {
                TestInputView()
                    .environmentObject(testStore)
            }
            .toolbar(.visible, for: .tabBar)
        }
    }
}

struct TrackContentView: View {
    @EnvironmentObject var testStore: TestStore
    @Binding var showTestInput: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if testStore.tests.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No Test Results")
                        .font(.title2)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    Text("Add your first test from the Dashboard to start tracking your progress.")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
            } else {
                if let latestTest = testStore.tests.first {
                    TrackHeroCard(test: latestTest)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, -4)
                }
                NextTestProgressBarView(showTestInput: $showTestInput)
                if let latestTest = testStore.tests.first {
                    TrackInsightBanner(test: latestTest)
                        .padding(.horizontal)
                }
                SummaryCardsView()
                RecentResultsBreakdownView()
            }
        }
        .padding(.vertical, 0)
    }
}

// MARK: - Track Hero Card
struct TrackHeroCard: View {
    let test: TestData

    private var fathrScore: Double {
        let motility = min((test.totalMobility ?? 0.0) * 2.5, 100.0)
        let conc = test.spermConcentration ?? 0.0
        let concentration = conc <= 15.0 ? (conc / 15.0) * 50.0 : 50.0 + ((conc - 15.0) / 85.0) * 50.0
        let morph = test.morphologyRate ?? 0.0
        let morphology = morph <= 4.0 ? (morph / 4.0) * 50.0 : 50.0 + ((morph - 4.0) / 11.0) * 50.0
        let dna = Double(test.dnaFragmentationRisk ?? 0)
        let dnaScore = max(100.0 - ((dna / 15.0) * 50.0), 0.0)
        var analysis = 0.0
        if test.appearance == .normal  { analysis += 25 }
        if test.liquefaction == .normal { analysis += 25 }
        if let pH = test.pH, pH >= 7.2 && pH <= 8.0 { analysis += 25 }
        if let sq = test.semenQuantity, sq >= 1.4 { analysis += 25 }
        return (0.35 * motility) + (0.30 * min(concentration, 100)) +
               (0.15 * min(morphology, 100)) + (0.10 * dnaScore) + (0.10 * analysis)
    }

    private var scoreGood: Bool { fathrScore >= 70 }
    private var scoreLabel: String { scoreGood ? "In the fertile zone" : "Needs boosting" }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("Fathr Score")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color.white)
                .tracking(0.5)
                .padding(.bottom, 6)

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(String(format: "%.0f", fathrScore))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 5) {
                    Text("/ 100")
                        .font(.system(size: 17, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.5))
                    Text(scoreLabel)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(scoreGood
                            ? Color(red: 0.78, green: 0.94, blue: 0.20)
                            : Color(red: 0.98, green: 0.78, blue: 0.45))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(
                            scoreGood
                                ? Color(red: 0.78, green: 0.94, blue: 0.20).opacity(0.18)
                                : Color(red: 0.98, green: 0.78, blue: 0.45).opacity(0.18)
                        )
                        .cornerRadius(20)
                }
                .padding(.bottom, 8)
                Spacer()
            }
            .padding(.bottom, 14)

            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 0.5)
                .padding(.bottom, 14)

            HStack(spacing: 0) {
                TrackHeroChip(
                    label: "Motility",
                    value: test.totalMobility.map { "\(Int($0))%" } ?? "—",
                    good: (test.totalMobility ?? 0) >= 40
                )
                Spacer()
                TrackHeroChip(
                    label: "Conc.",
                    value: test.spermConcentration.map { "\(Int($0))M" } ?? "—",
                    good: (test.spermConcentration ?? 0) >= 16
                )
                Spacer()
                TrackHeroChip(
                    label: "Morph.",
                    value: test.morphologyRate.map { "\(Int($0))%" } ?? "—",
                    good: (test.morphologyRate ?? 0) >= 4
                )
                Spacer()
                TrackHeroChip(
                    label: "DNA",
                    value: test.dnaFragmentationRisk.map { "\($0)%" } ?? "—",
                    good: (test.dnaFragmentationRisk ?? 100) < 30
                )
            }
            .padding(.bottom, 14)

            Text("Most recent test · Based on WHO 6th Edition")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(Color.white.opacity(0.6))
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#016eef"),
                    Color(hex: "#00c2ff")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
}

private struct TrackHeroChip: View {
    let label: String
    let value: String
    let good: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color.white.opacity(0.75))
            Circle()
                .fill(good
                    ? Color(red: 0.78, green: 0.94, blue: 0.20)
                    : Color(red: 0.98, green: 0.78, blue: 0.45))
                .frame(width: 5, height: 5)
        }
    }
}

// MARK: - Track Insight Banner
struct TrackInsightBanner: View {
    let test: TestData

    private var insightText: String {
        let motilityOK = (test.totalMobility ?? 0) >= 40
        let concOK     = (test.spermConcentration ?? 0) >= 16
        let morphOK    = (test.morphologyRate ?? 0) >= 4
        let dnaOK      = (test.dnaFragmentationRisk ?? 100) < 30

        if motilityOK && concOK && morphOK && dnaOK {
            return "All four key metrics are above WHO thresholds. Keep up your current habits and retest in 77 days."
        } else if motilityOK && concOK && !morphOK {
            return "Your motility and concentration are both above WHO thresholds. Focus on maintaining these while improving morphology."
        } else if !motilityOK && concOK {
            return "Your concentration is strong, but motility needs a boost. Regular exercise and reducing stress can improve sperm movement over 2–3 cycles."
        } else if motilityOK && !concOK {
            return "Your motility is good, but concentration is below WHO range. Zinc, selenium, and sleep quality are key levers to improve count."
        } else if !dnaOK {
            return "DNA fragmentation is elevated. Antioxidants like CoQ10 and vitamin C can lower fragmentation risk over 70–90 days."
        } else {
            return "Several parameters need attention. Small, consistent lifestyle changes compound quickly — retest in 77 days to track your progress."
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 18))
                .foregroundColor(.fathrBlue)
                .padding(.top, 1)

            Text(insightText)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.fathrBlue)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.fathrBlueLight)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.fathrBlueMid, lineWidth: 0.5)
        )
    }
}

// MARK: - Next Test Progress Bar
struct NextTestProgressBarView: View {
    @EnvironmentObject var testStore: TestStore
    @Binding var showTestInput: Bool

    private let regenerationDays = 77

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Days Until Next Test")
                .font(.title2)
                .fontDesign(.rounded)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)

            if let latestTest = testStore.tests.first {
                let daysSinceTest = daysSince(date: latestTest.date)
                let progress = min(Double(daysSinceTest) / Double(regenerationDays), 1.0)
                let daysLeft = max(regenerationDays - daysSinceTest, 0)
                let isOverdue = daysSinceTest > regenerationDays

                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .tint(Color(hex: "#00ff1d"))
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    Text(isOverdue
                        ? "You're overdue — take your next test now to track progress."
                        : "\(daysLeft) days until next fertility test. Good work!")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(isOverdue ? .red : .white)
                    if isOverdue {
                        Button(action: { showTestInput = true }) {
                            Text("Add New Test")
                                .font(.subheadline.bold())
                                .fontDesign(.rounded)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .accessibilityLabel("Add new test to track progress")
                    }
                }
                .padding()
                .background(Color(hex: "#0D0D0F"))
                .cornerRadius(15)
                .padding(.horizontal)
            }
        }
    }

    private func daysSince(date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
    }
}

// MARK: - Summary Cards
struct SummaryCardsView: View {
    @EnvironmentObject var testStore: TestStore
    @State private var expandedCards: [String: Bool] = [
        "Analysis": false,
        "Motility": false,
        "Concentration": false,
        "Morphology": false,
        "DNA Fragmentation": false
    ]

    private struct Averages {
        let overallScore: Double
        let motility: Double
        let concentration: Double
        let morphology: Double
        let dnaFragmentation: Double
        let spermAnalysis: Double
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Health Summary")
                .font(.title2)
                .fontDesign(.rounded)
                .fontWeight(.bold)
                .padding(.horizontal)

            if let latestTest = testStore.tests.first {
                let averages = calculateAverages()
                SummaryCardView(
                    title: "Analysis",
                    score: averages.spermAnalysis,
                    summary: latestTest.analysisStatus == "Typical"
                        ? "Normal range, excellent semen quality."
                        : "Needs attention, consult a specialist.",
                    isExpanded: Binding(
                        get: { expandedCards["Analysis"] ?? false },
                        set: { expandedCards["Analysis"] = $0 }
                    ),
                    details: SummaryCardDetails(
                        what: "Measures physical properties like appearance, liquefaction, volume, and pH.",
                        why: "Ensures semen provides a suitable environment for sperm to survive and function.",
                        whoRange: "Normal appearance, liquefaction, pH 7.2–8.0, volume ≥1.4 mL.",
                        improvementTime: "Usually improves over 1–2 cycles (roughly 35–70 days).",
                        tips: ["Stay hydrated.", "Avoid smoking and alcohol.", "Maintain a healthy diet."]
                    ),
                    isGood: latestTest.analysisStatus == "Typical"
                )
                SummaryCardView(
                    title: "Motility",
                    score: averages.motility,
                    summary: (latestTest.totalMobility ?? 0) >= 40
                        ? "Normal range, great sperm movement."
                        : "Below normal, aim for ≥40%.",
                    isExpanded: Binding(
                        get: { expandedCards["Motility"] ?? false },
                        set: { expandedCards["Motility"] = $0 }
                    ),
                    details: SummaryCardDetails(
                        what: "Percentage of sperm that are moving, especially forward (progressive motility).",
                        why: "Sperm must swim to reach and fertilize the egg.",
                        whoRange: "Total motility ≥40%, progressive motility ≥30%.",
                        improvementTime: "Usually improves over 2–3 cycles (roughly 70–90 days).",
                        tips: ["Exercise regularly.", "Eat antioxidant-rich foods like berries.", "Avoid heat exposure (e.g., hot tubs)."]
                    ),
                    isGood: (latestTest.totalMobility ?? 0) >= 40
                )
                SummaryCardView(
                    title: "Concentration",
                    score: averages.concentration,
                    summary: (latestTest.spermConcentration ?? 0) >= 15
                        ? "Normal range, strong sperm count."
                        : "Below normal, aim for ≥15 M/mL.",
                    isExpanded: Binding(
                        get: { expandedCards["Concentration"] ?? false },
                        set: { expandedCards["Concentration"] = $0 }
                    ),
                    details: SummaryCardDetails(
                        what: "Number of sperm per milliliter of semen.",
                        why: "Higher counts increase the chance of fertilization.",
                        whoRange: "≥16 M/mL (WHO 6th Edition).",
                        improvementTime: "Usually improves over 2–3 cycles (roughly 70–90 days).",
                        tips: ["Take zinc and selenium supplements.", "Avoid stress.", "Sleep 7–8 hours nightly."]
                    ),
                    isGood: (latestTest.spermConcentration ?? 0) >= 15
                )
                SummaryCardView(
                    title: "Morphology",
                    score: averages.morphology,
                    summary: (latestTest.morphologyRate ?? 0) >= 4
                        ? "Normal range, good sperm structure."
                        : "Below normal, aim for ≥4%.",
                    isExpanded: Binding(
                        get: { expandedCards["Morphology"] ?? false },
                        set: { expandedCards["Morphology"] = $0 }
                    ),
                    details: SummaryCardDetails(
                        what: "Percentage of sperm with normal shape and structure.",
                        why: "Normal-shaped sperm are more likely to fertilize an egg.",
                        whoRange: "≥4% normal forms.",
                        improvementTime: "Usually improves over 2–3 cycles (roughly 70–90 days).",
                        tips: ["Eat foods rich in folate (e.g., spinach).", "Avoid pesticides.", "Take CoQ10 supplements."]
                    ),
                    isGood: (latestTest.morphologyRate ?? 0) >= 4
                )
                SummaryCardView(
                    title: "DNA Fragmentation",
                    score: averages.dnaFragmentation,
                    summary: (latestTest.dnaFragmentationRisk ?? 0) <= 15
                        ? "Low risk, healthy sperm DNA."
                        : "Moderate/high risk, aim for <15%.",
                    isExpanded: Binding(
                        get: { expandedCards["DNA Fragmentation"] ?? false },
                        set: { expandedCards["DNA Fragmentation"] = $0 }
                    ),
                    details: SummaryCardDetails(
                        what: "Percentage of sperm with damaged DNA.",
                        why: "Low DNA damage improves embryo viability and pregnancy success.",
                        whoRange: "<15% for low risk, <30% for moderate risk.",
                        improvementTime: "Usually improves over 2–3 cycles (roughly 70–90 days).",
                        tips: ["Reduce oxidative stress with antioxidants.", "Avoid smoking.", "Consult a specialist for high risk."]
                    ),
                    isGood: (latestTest.dnaFragmentationRisk ?? 0) <= 15
                )
            }
        }
    }

    private struct SummaryCardDetails {
        let what: String
        let why: String
        let whoRange: String
        let improvementTime: String
        let tips: [String]
    }

    private struct SummaryCardView: View {
        let title: String
        let score: Double
        let summary: String
        @Binding var isExpanded: Bool
        let details: SummaryCardDetails
        let isGood: Bool

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Button(action: { isExpanded.toggle() }) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.headline)
                                .fontDesign(.rounded)
                                .foregroundColor(.black)
                            Text(String(format: "%.1f", score))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.black)
                            Text(summary)
                                .font(.subheadline)
                                .fontDesign(.rounded)
                                .foregroundColor(.gray)
                            Text(isGood ? "You are in the fertile zone" : "You are close to optimal")
                                .font(.caption)
                                .fontDesign(.rounded)
                                .foregroundColor(isGood ? .green : .orange)
                                .italic()
                                .padding(.top, 2)
                        }
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
                .accessibilityLabel("\(title): Score \(String(format: "%.1f", score)), \(summary), \(isGood ? "In the fertile zone" : "Close to optimal"), Tap to \(isExpanded ? "collapse" : "expand") details")

                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What is it?").font(.subheadline.bold()).fontDesign(.rounded)
                        Text(details.what).font(.subheadline).fontDesign(.rounded).foregroundColor(.gray)
                        Text("Why it matters?").font(.subheadline.bold()).fontDesign(.rounded)
                        Text(details.why).font(.subheadline).fontDesign(.rounded).foregroundColor(.gray)
                        Text("WHO Recommendation").font(.subheadline.bold()).fontDesign(.rounded)
                        Text(details.whoRange).font(.subheadline).fontDesign(.rounded).foregroundColor(.gray)
                        Text("How long to improve?").font(.subheadline.bold()).fontDesign(.rounded)
                        Text(details.improvementTime).font(.subheadline).fontDesign(.rounded).foregroundColor(.gray)
                        Text("Tips to Improve").font(.subheadline.bold()).fontDesign(.rounded)
                        ForEach(details.tips, id: \.self) { tip in
                            HStack(alignment: .top) {
                                Text("•").font(.subheadline).foregroundColor(.gray)
                                Text(tip).font(.subheadline).fontDesign(.rounded).foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
            .padding(.horizontal)
        }
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
        let totalDna = testStore.tests.reduce(0.0) {
            let dna = Double($1.dnaFragmentationRisk ?? 0)
            return $0 + max(100.0 - ((dna / 15.0) * 50.0), 0.0)
        }
        let totalAnalysis = testStore.tests.reduce(0.0) { $0 + calculateAnalysisScore($1) }

        let avgMotility = totalMotility / Double(count)
        let avgConcentration = totalConcentration / Double(count)
        let avgMorphology = totalMorphology / Double(count)
        let avgDna = totalDna / Double(count)
        let avgAnalysis = totalAnalysis / Double(count)
        let overall = (0.35 * avgMotility) + (0.30 * avgConcentration) + (0.15 * avgMorphology) +
                      (0.10 * avgDna) + (0.10 * avgAnalysis)

        return Averages(overallScore: overall, motility: avgMotility, concentration: avgConcentration,
                        morphology: avgMorphology, dnaFragmentation: avgDna, spermAnalysis: avgAnalysis)
    }

    private func calculateAnalysisScore(_ test: TestData) -> Double {
        var score: Double = 0
        if test.appearance == .normal { score += 25 }
        if test.liquefaction == .normal { score += 25 }
        if let pH = test.pH, pH >= 7.2 && pH <= 8.0 { score += 25 }
        if let sq = test.semenQuantity, sq >= 1.4 { score += 25 }
        return score
    }
}

// MARK: - Recent Results Breakdown
struct RecentResultsBreakdownView: View {
    @EnvironmentObject var testStore: TestStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Most Recent Results")
                .font(.title2)
                .fontDesign(.rounded)
                .fontWeight(.bold)
                .padding(.horizontal)

            if let t = testStore.tests.first {

                // Analysis
                FathrSectionHeader(title: "Analysis", subtitle: "Physical properties of the sample")
                    .padding(.horizontal)

                FathrStatusCard(title: "Appearance",
                                status: t.appearance?.rawValue.capitalized ?? "Not Provided",
                                description: "Normal is clear or white.",
                                isAvailable: t.appearance != nil)
                    .padding(.horizontal)

                FathrStatusCard(title: "Liquefaction",
                                status: t.liquefaction?.rawValue.capitalized ?? "Not Provided",
                                description: "Normal aids sperm movement.",
                                isAvailable: t.liquefaction != nil)
                    .padding(.horizontal)

                FathrStatusCard(title: "Consistency",
                                status: t.consistency?.rawValue.capitalized ?? "Not Provided",
                                description: "Medium is typical.",
                                isAvailable: t.consistency != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "Semen Quantity",
                                value: t.semenQuantity ?? 0, maxValue: 10, unit: "mL",
                                whoRange: 1.4...6.0,
                                description: { v in v >= 1.4 && v <= 6.0 ? "Within WHO range of 1.4–6.0 mL." : "Outside WHO range of 1.4–6.0 mL." },
                                isAvailable: t.semenQuantity != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "pH",
                                value: t.pH ?? 0, maxValue: 14, unit: "",
                                whoRange: 7.2...8.0,
                                description: { v in v >= 7.2 && v <= 8.0 ? "Within the optimal pH range of 7.2–8.0." : "Outside the optimal pH range of 7.2–8.0." },
                                isAvailable: t.pH != nil)
                    .padding(.horizontal)

                // Motility
                FathrSectionHeader(title: "Motility", subtitle: "How well sperm move and swim")
                    .padding(.horizontal)

                FathrMetricCard(title: "Total Mobility",
                                value: t.totalMobility ?? 0, maxValue: 100, unit: "%",
                                whoRange: 40.0...100.0,
                                description: { v in v >= 40 ? "Above WHO threshold of 40%." : "Below WHO threshold of 40%." },
                                isAvailable: t.totalMobility != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "Progressive Mobility",
                                value: t.progressiveMobility ?? 0, maxValue: 100, unit: "%",
                                whoRange: 30.0...100.0,
                                description: { v in v >= 30 ? "Above WHO minimum of 30%." : "Below WHO minimum of 30%." },
                                isAvailable: t.progressiveMobility != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "Non-Progressive Mobility",
                                value: t.nonProgressiveMobility ?? 0, maxValue: 100, unit: "%",
                                whoRange: 0.0...10.0,
                                description: { v in v <= 10 ? "Within the normal range of under 10%." : "Above the typical 10% threshold." },
                                isAvailable: t.nonProgressiveMobility != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "Travel Speed",
                                value: t.travelSpeed ?? 0, maxValue: 1.0, unit: "mm/sec",
                                goodThreshold: 0.025,
                                description: { v in v >= 0.025 ? "Normal travel speed." : "Below normal travel speed of 0.025 mm/sec." },
                                isAvailable: t.travelSpeed != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "Mobility Index",
                                value: t.mobilityIndex ?? 0, maxValue: 100, unit: "%",
                                goodThreshold: 60.0,
                                description: { v in v >= 60 ? "Healthy mobility index." : "Below the 60% benchmark." },
                                isAvailable: t.mobilityIndex != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "Still",
                                value: t.still ?? 0, maxValue: 100, unit: "%",
                                whoRange: 0.0...60.0,
                                description: { v in v <= 60 ? "Within normal range of under 60%." : "Above 60% — more sperm than typical are stationary." },
                                isAvailable: t.still != nil)
                    .padding(.horizontal)

                FathrStatusCard(title: "Agglutination",
                                status: t.agglutination?.rawValue.capitalized ?? "Not Provided",
                                description: "Mild or none is normal.",
                                isAvailable: t.agglutination != nil)
                    .padding(.horizontal)

                // Concentration
                FathrSectionHeader(title: "Concentration", subtitle: "Number of sperm in the sample")
                    .padding(.horizontal)

                FathrMetricCard(title: "Sperm Concentration",
                                value: t.spermConcentration ?? 0, maxValue: 100, unit: "M/mL",
                                whoRange: 16.0...100.0,
                                description: { v in v >= 16 ? "Above WHO minimum of 16 M/mL." : "Below WHO minimum of 16 M/mL." },
                                isAvailable: t.spermConcentration != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "Total Spermatozoa",
                                value: t.totalSpermatozoa ?? 0, maxValue: 200, unit: "M/mL",
                                whoRange: 39.0...200.0,
                                description: { v in v >= 39 ? "Above WHO threshold of 39 M/mL." : "Below WHO threshold of 39 M/mL." },
                                isAvailable: t.totalSpermatozoa != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "Functional Spermatozoa",
                                value: t.functionalSpermatozoa ?? 0, maxValue: 100, unit: "M/mL",
                                goodThreshold: 10.0,
                                description: { v in v >= 10 ? "Above the 10 M/mL healthy benchmark." : "Below the 10 M/mL healthy benchmark." },
                                isAvailable: t.functionalSpermatozoa != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "Round Cells",
                                value: t.roundCells ?? 0, maxValue: 10, unit: "M/mL",
                                whoRange: 0.0...1.0,
                                description: { v in v <= 1 ? "Within WHO limit of <1 M/mL." : "Above WHO limit of 1 M/mL — may indicate inflammation." },
                                isAvailable: t.roundCells != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "Leukocytes",
                                value: t.leukocytes ?? 0, maxValue: 5, unit: "M/mL",
                                whoRange: 0.0...1.0,
                                description: { v in v <= 1 ? "Within WHO limit of <1 M/mL." : "Above WHO limit — may signal infection." },
                                isAvailable: t.leukocytes != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "Live Spermatozoa",
                                value: t.liveSpermatozoa ?? 0, maxValue: 100, unit: "%",
                                whoRange: 50.0...100.0,
                                description: { v in v >= 50 ? "Above WHO minimum of 50%." : "Below WHO minimum of 50%." },
                                isAvailable: t.liveSpermatozoa != nil)
                    .padding(.horizontal)

                // Morphology
                FathrSectionHeader(title: "Morphology", subtitle: "Shape and structure of sperm")
                    .padding(.horizontal)

                FathrMetricCard(title: "Morphology Rate",
                                value: t.morphologyRate ?? 0, maxValue: 100, unit: "%",
                                whoRange: 4.0...100.0,
                                description: { v in v >= 4 ? "Above WHO minimum of 4%." : "Below WHO minimum of 4%." },
                                isAvailable: t.morphologyRate != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "Pathology",
                                value: t.pathology ?? 0, maxValue: 100, unit: "%",
                                whoRange: 0.0...96.0,
                                description: { v in v <= 96 ? "Within the normal range of under 96%." : "Above the typical 96% threshold." },
                                isAvailable: t.pathology != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "Head Defect",
                                value: t.headDefect ?? 0, maxValue: 100, unit: "%",
                                whoRange: 0.0...70.0,
                                description: { v in v <= 70 ? "Within the typical range of under 70%." : "Above the typical 70% threshold." },
                                isAvailable: t.headDefect != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "Neck Defect",
                                value: t.neckDefect ?? 0, maxValue: 100, unit: "%",
                                whoRange: 0.0...40.0,
                                description: { v in v <= 40 ? "Within the typical range of under 40%." : "Above the typical 40% threshold." },
                                isAvailable: t.neckDefect != nil)
                    .padding(.horizontal)

                FathrMetricCard(title: "Tail Defect",
                                value: t.tailDefect ?? 0, maxValue: 100, unit: "%",
                                whoRange: 0.0...20.0,
                                description: { v in v <= 20 ? "Within the typical range of under 20%." : "Above the typical 20% threshold." },
                                isAvailable: t.tailDefect != nil)
                    .padding(.horizontal)

                // DNA Fragmentation
                FathrSectionHeader(title: "DNA Fragmentation", subtitle: "Damage to sperm DNA")
                    .padding(.horizontal)

                FathrMetricCard(title: "DNA Fragmentation Risk",
                                value: Double(t.dnaFragmentationRisk ?? 0), maxValue: 100, unit: "%",
                                whoRange: 0.0...30.0,
                                description: { v in v < 30 ? "Low/moderate risk — under the 30% threshold." : "High risk — consider consulting a specialist." },
                                isAvailable: t.dnaFragmentationRisk != nil)
                    .padding(.horizontal)

                FathrStatusCard(title: "DNA Risk Category",
                                status: t.dnaRiskCategory ?? "Unknown",
                                description: "Low risk is best for fertility.",
                                isAvailable: t.dnaRiskCategory != nil)
                    .padding(.horizontal)
            }
        }
        .padding(.bottom, 24)
    }
}

// MARK: - Preview
struct TrackView_Previews: PreviewProvider {
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
                date: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
                dnaFragmentationRisk: 10,
                dnaRiskCategory: "Low"
            )
        ]
        return NavigationStack {
            TrackView()
                .environmentObject(testStore)
        }
    }
}
