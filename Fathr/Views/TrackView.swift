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
            .toolbar(.visible, for: .tabBar) // Ensure tab bar remains visible
        }
    }
}

struct TrackContentView: View {
    @EnvironmentObject var testStore: TestStore
    @Binding var showTestInput: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // Reduced spacing from 16 to 8
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
                NextTestProgressBarView(showTestInput: $showTestInput)
                SummaryCardsView()
                RecentResultsBreakdownView()
            }
        }
        .padding(.vertical, 0) // Changed from 2 to 0 to minimize gap
    }
}

// MARK: - Next Test Progress Bar
struct NextTestProgressBarView: View {
    @EnvironmentObject var testStore: TestStore
    @Binding var showTestInput: Bool

    private let regenerationDays = 77 // Sperm regeneration cycle

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
                        .tint(Color(hex: "#00ff1d")) // Filled color: bright green
                        .background(Color.white) // Unfilled color: white
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    Text(isOverdue ? "You're overdue — take your next test now to track progress." : "\(daysLeft) days until next fertility test. Good work!")
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
                .cornerRadius(15)
                .padding(.horizontal)
            }
        }
    }

    private func daysSince(date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: Date())
        return components.day ?? 0
    }
}

// Extension to support hex color initialization
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
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

    // Define Averages struct locally to avoid DashboardView dependency
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
                    summary: latestTest.analysisStatus == "Typical" ? "Normal range, excellent semen quality." : "Needs attention, consult a specialist.",
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
                    summary: (latestTest.totalMobility ?? 0) >= 40 ? "Normal range, great sperm movement." : "Below normal, aim for ≥40%.",
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
                    summary: (latestTest.spermConcentration ?? 0) >= 15 ? "Normal range, strong sperm count." : "Below normal, aim for ≥15 M/mL.",
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
                    summary: (latestTest.morphologyRate ?? 0) >= 4 ? "Normal range, good sperm structure." : "Below normal, aim for ≥4%.",
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
                    summary: (latestTest.dnaFragmentationRisk ?? 0) <= 15 ? "Low risk, healthy sperm DNA." : "Moderate/high risk, aim for <15%.",
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

        private func scoreColor(score: Double) -> Color {
            switch score {
            case 0..<50: return .red
            case 50..<70: return .orange
            case 70..<85: return .yellow
            case 85...100: return .green
            default: return .gray
            }
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

            if let latestTest = testStore.tests.first {
                // Analysis Metrics
                Group {
                    Text("Analysis")
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    StatusBox(
                        title: "Appearance",
                        status: latestTest.appearance?.rawValue.capitalized ?? "Not Provided",
                        description: "Normal is clear or white."
                    )
                    StatusBox(
                        title: "Liquefaction",
                        status: latestTest.liquefaction?.rawValue.capitalized ?? "Not Provided",
                        description: "Normal aids sperm movement."
                    )
                    StatusBox(
                        title: "Consistency",
                        status: latestTest.consistency?.rawValue.capitalized ?? "Not Provided",
                        description: "Medium is typical."
                    )
                    ProgressStatusBox(
                        title: "Semen Quantity",
                        value: latestTest.semenQuantity ?? 0.0,
                        maxValue: 10.0,
                        unit: "mL",
                        whoRange: 1.4...6.0,
                        description: "WHO: 1.4–6.0 mL.",
                        isAvailable: latestTest.semenQuantity != nil
                    )
                    ProgressStatusBox(
                        title: "pH",
                        value: latestTest.pH ?? 0.0,
                        maxValue: 14.0,
                        unit: "",
                        whoRange: 7.2...8.0,
                        description: "WHO: 7.2–8.0.",
                        isAvailable: latestTest.pH != nil
                    )
                }

                // Motility Metrics
                Group {
                    Text("Motility")
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    ProgressStatusBox(
                        title: "Total Mobility",
                        value: latestTest.totalMobility ?? 0.0,
                        maxValue: 100.0,
                        unit: "%",
                        whoRange: 40.0...100.0,
                        description: "WHO: ≥40%.",
                        isAvailable: latestTest.totalMobility != nil
                    )
                    ProgressStatusBox(
                        title: "Progressive Mobility",
                        value: latestTest.progressiveMobility ?? 0.0,
                        maxValue: 100.0,
                        unit: "%",
                        whoRange: 30.0...100.0,
                        description: "WHO: ≥30%.",
                        isAvailable: latestTest.progressiveMobility != nil
                    )
                    ProgressStatusBox(
                        title: "Non-Progressive Mobility",
                        value: latestTest.nonProgressiveMobility ?? 0.0,
                        maxValue: 100.0,
                        unit: "%",
                        description: "Lower values are common.",
                        isAvailable: latestTest.nonProgressiveMobility != nil
                    )
                    ProgressStatusBox(
                        title: "Travel Speed",
                        value: latestTest.travelSpeed ?? 0.0,
                        maxValue: 1.0,
                        unit: "mm/sec",
                        description: "Higher speeds are better.",
                        isAvailable: latestTest.travelSpeed != nil
                    )
                    ProgressStatusBox(
                        title: "Mobility Index",
                        value: latestTest.mobilityIndex ?? 0.0,
                        maxValue: 100.0,
                        unit: "%",
                        description: "Higher values are better.",
                        isAvailable: latestTest.mobilityIndex != nil
                    )
                    ProgressStatusBox(
                        title: "Still",
                        value: latestTest.still ?? 0.0,
                        maxValue: 100.0,
                        unit: "%",
                        description: "Lower values are better.",
                        isAvailable: latestTest.still != nil
                    )
                    StatusBox(
                        title: "Agglutination",
                        status: latestTest.agglutination?.rawValue.capitalized ?? "Not Provided",
                        description: "Mild or none is normal."
                    )
                }

                // Concentration Metrics
                Group {
                    Text("Concentration")
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    ProgressStatusBox(
                        title: "Sperm Concentration",
                        value: latestTest.spermConcentration ?? 0.0,
                        maxValue: 100.0,
                        unit: "M/mL",
                        whoRange: 16.0...100.0,
                        description: "WHO: ≥16 M/mL.",
                        isAvailable: latestTest.spermConcentration != nil
                    )
                    ProgressStatusBox(
                        title: "Total Spermatozoa",
                        value: latestTest.totalSpermatozoa ?? 0.0,
                        maxValue: 200.0,
                        unit: "M/mL",
                        whoRange: 39.0...200.0,
                        description: "WHO: ≥39 M/mL.",
                        isAvailable: latestTest.totalSpermatozoa != nil
                    )
                    ProgressStatusBox(
                        title: "Functional Spermatozoa",
                        value: latestTest.functionalSpermatozoa ?? 0.0,
                        maxValue: 100.0,
                        unit: "M/mL",
                        description: "Higher counts are better.",
                        isAvailable: latestTest.functionalSpermatozoa != nil
                    )
                    ProgressStatusBox(
                        title: "Round Cells",
                        value: latestTest.roundCells ?? 0.0,
                        maxValue: 10.0,
                        unit: "M/mL",
                        whoRange: 0.0...1.0,
                        description: "WHO: <1 M/mL.",
                        isAvailable: latestTest.roundCells != nil
                    )
                    ProgressStatusBox(
                        title: "Leukocytes",
                        value: latestTest.leukocytes ?? 0.0,
                        maxValue: 5.0,
                        unit: "M/mL",
                        whoRange: 0.0...1.0,
                        description: "WHO: <1 M/mL.",
                        isAvailable: latestTest.leukocytes != nil
                    )
                    ProgressStatusBox(
                        title: "Live Spermatozoa",
                        value: latestTest.liveSpermatozoa ?? 0.0,
                        maxValue: 100.0,
                        unit: "%",
                        whoRange: 50.0...100.0,
                        description: "WHO: ≥50%.",
                        isAvailable: latestTest.liveSpermatozoa != nil
                    )
                }

                // Morphology Metrics
                Group {
                    Text("Morphology")
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    ProgressStatusBox(
                        title: "Morphology Rate",
                        value: latestTest.morphologyRate ?? 0.0,
                        maxValue: 100.0,
                        unit: "%",
                        whoRange: 4.0...100.0,
                        description: "WHO: ≥4%.",
                        isAvailable: latestTest.morphologyRate != nil
                    )
                    ProgressStatusBox(
                        title: "Pathology",
                        value: latestTest.pathology ?? 0.0,
                        maxValue: 100.0,
                        unit: "%",
                        description: "Lower percentages are better.",
                        isAvailable: latestTest.pathology != nil
                    )
                    ProgressStatusBox(
                        title: "Head Defect",
                        value: latestTest.headDefect ?? 0.0,
                        maxValue: 100.0,
                        unit: "%",
                        description: "Fewer defects are better.",
                        isAvailable: latestTest.headDefect != nil
                    )
                    ProgressStatusBox(
                        title: "Neck Defect",
                        value: latestTest.neckDefect ?? 0.0,
                        maxValue: 100.0,
                        unit: "%",
                        description: "Fewer defects are better.",
                        isAvailable: latestTest.neckDefect != nil
                    )
                    ProgressStatusBox(
                        title: "Tail Defect",
                        value: latestTest.tailDefect ?? 0.0,
                        maxValue: 100.0,
                        unit: "%",
                        description: "Fewer defects are better.",
                        isAvailable: latestTest.tailDefect != nil
                    )
                }

                // DNA Fragmentation Metrics
                Group {
                    Text("DNA Fragmentation")
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    ProgressStatusBox(
                        title: "DNA Fragmentation Risk",
                        value: Double(latestTest.dnaFragmentationRisk ?? 0),
                        maxValue: 100.0,
                        unit: "%",
                        whoRange: 0.0...30.0,
                        description: "Lower is better (<30%).",
                        isAvailable: latestTest.dnaFragmentationRisk != nil
                    )
                    StatusBox(
                        title: "DNA Risk Category",
                        status: latestTest.dnaRiskCategory ?? "Unknown",
                        description: "Low risk is best."
                    )
                }
            }
        }
    }
}

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
