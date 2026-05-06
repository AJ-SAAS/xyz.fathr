import SwiftUI

// MARK: - ResultsView
struct ResultsView: View {
    let test: TestData
    @EnvironmentObject var purchaseModel: PurchaseModel

    // MARK: - Score
    private var fathrScore: Double {
        let motility = min((test.totalMobility ?? 0.0) * 2.5, 100.0)
        let conc = test.spermConcentration ?? 0.0
        let concentration = conc <= 15.0 ? (conc / 15.0) * 50.0 : 50.0 + ((conc - 15.0) / 85.0) * 50.0
        let morph = test.morphologyRate ?? 0.0
        let morphology = morph <= 4.0 ? (morph / 4.0) * 50.0 : 50.0 + ((morph - 4.0) / 11.0) * 50.0
        let dna = Double(test.dnaFragmentationRisk ?? 0)
        let dnaScore = max(100.0 - ((dna / 15.0) * 50.0), 0.0)
        var analysis = 0.0
        if test.appearance == .normal { analysis += 25 }
        if test.liquefaction == .normal { analysis += 25 }
        if let pH = test.pH, pH >= 7.2 && pH <= 8.0 { analysis += 25 }
        if let sq = test.semenQuantity, sq >= 1.4 { analysis += 25 }
        return (0.35 * motility) + (0.30 * min(concentration, 100)) +
               (0.15 * min(morphology, 100)) + (0.10 * dnaScore) + (0.10 * analysis)
    }

    private var scoreGood: Bool { fathrScore >= 70 }
    private var scoreLabel: String { scoreGood ? "In the fertile zone" : "Needs boosting" }

    // MARK: - Insight
    private var insightText: String {
        let motilityOK = (test.totalMobility ?? 0) >= 40
        let concOK = (test.spermConcentration ?? 0) >= 16
        let morphOK = (test.morphologyRate ?? 0) >= 4
        let dnaOK = (test.dnaFragmentationRisk ?? 100) < 30

        if motilityOK && concOK && morphOK && dnaOK {
            return "All four key metrics are above WHO thresholds. Keep up your current habits and retest in 77 days."
        } else if motilityOK && concOK && !morphOK {
            return "Your motility and concentration are both above WHO thresholds. Focus on improving morphology — diet, antioxidants, and reducing heat exposure can help."
        } else if !motilityOK && concOK {
            return "Your concentration is strong, but motility needs a boost. Regular exercise and reducing stress can improve sperm movement over 2–3 cycles."
        } else if motilityOK && !concOK {
            return "Your motility is good, but concentration is below WHO range. Zinc, selenium, and sleep quality are key levers to improve count."
        } else if !dnaOK {
            return "DNA fragmentation is elevated. Antioxidants like CoQ10, vitamin C, and reducing oxidative stress can lower fragmentation risk over 70–90 days."
        } else {
            return "Several parameters need attention. Small, consistent lifestyle changes compound quickly — retest in 77 days to track your progress."
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                // MARK: Hero Card
                HeroCard(
                    score: fathrScore,
                    scoreLabel: scoreLabel,
                    scoreGood: scoreGood,
                    test: test
                )

                // MARK: Insight Banner
                InsightBanner(text: insightText)

                // MARK: Analysis
                FathrSectionHeader(title: "Analysis", subtitle: "Physical properties of the sample")

                FathrStatusCard(
                    title: "Appearance",
                    status: test.appearance?.rawValue.capitalized ?? "Not Provided",
                    description: "Normal appearance — clear or white — indicates healthy semen composition.",
                    isAvailable: test.appearance != nil
                )
                FathrStatusCard(
                    title: "Liquefaction",
                    status: test.liquefaction?.rawValue.capitalized ?? "Not Provided",
                    description: "Normal liquefaction means semen transitions from gel to liquid at the right speed, aiding sperm movement.",
                    isAvailable: test.liquefaction != nil
                )
                FathrStatusCard(
                    title: "Consistency",
                    status: test.consistency?.rawValue.capitalized ?? "Not Provided",
                    description: "Medium consistency is typical for healthy semen.",
                    isAvailable: test.consistency != nil
                )
                FathrMetricCard(
                    title: "Semen Quantity",
                    value: test.semenQuantity ?? 0,
                    maxValue: 10,
                    unit: "mL",
                    whoRange: 1.4...6.0,
                    description: { v in
                        let inRange = v >= 1.4 && v <= 6.0
                        return inRange
                            ? "At \(v.formatted1)mL your volume is within the WHO range — adequate for effective sperm delivery."
                            : "At \(v.formatted1)mL your volume is \(v < 1.4 ? "below" : "above") the WHO range of 1.4–6.0mL."
                    },
                    isAvailable: test.semenQuantity != nil
                )
                FathrMetricCard(
                    title: "pH",
                    value: test.pH ?? 0,
                    maxValue: 14,
                    unit: "",
                    whoRange: 7.2...8.0,
                    description: { v in
                        let inRange = v >= 7.2 && v <= 8.0
                        return inRange
                            ? "A pH of \(v.formatted1) sits comfortably in the optimal range for sperm function."
                            : "A pH of \(v.formatted1) is outside the optimal 7.2–8.0 range, which can affect sperm function."
                    },
                    isAvailable: test.pH != nil
                )

                // MARK: Motility
                FathrSectionHeader(title: "Motility", subtitle: "How well sperm move and swim")

                FathrMetricCard(
                    title: "Total Mobility",
                    value: test.totalMobility ?? 0,
                    maxValue: 100,
                    unit: "%",
                    whoRange: 40.0...100.0,
                    description: { v in
                        v >= 40
                            ? "\(Int(v))% of your sperm are moving — above the WHO threshold of 40%. This is a strong result."
                            : "At \(Int(v))%, motility is below the WHO threshold of 40%. Improving this can significantly boost fertility."
                    },
                    isAvailable: test.totalMobility != nil,
                    isKeyMetric: true
                )
                FathrMetricCard(
                    title: "Progressive Mobility",
                    value: test.progressiveMobility ?? 0,
                    maxValue: 100,
                    unit: "%",
                    whoRange: 30.0...100.0,
                    description: { v in
                        v >= 30
                            ? "\(Int(v))% of sperm are swimming forward — above the 30% threshold for effective fertilization."
                            : "At \(Int(v))%, forward swimming is below the WHO minimum of 30%, which affects fertilization potential."
                    },
                    isAvailable: test.progressiveMobility != nil
                )
                FathrMetricCard(
                    title: "Non-Progressive Mobility",
                    value: test.nonProgressiveMobility ?? 0,
                    maxValue: 100,
                    unit: "%",
                    whoRange: 0.0...10.0,
                    description: { v in
                        v <= 10
                            ? "At \(Int(v))%, sperm moving without direction are within the normal range of under 10%."
                            : "\(Int(v))% non-progressive mobility is above the typical 10% — these sperm move but don't contribute to fertilization."
                    },
                    isAvailable: test.nonProgressiveMobility != nil
                )
                FathrMetricCard(
                    title: "Travel Speed",
                    value: test.travelSpeed ?? 0,
                    maxValue: 1.0,
                    unit: "mm/sec",
                    goodThreshold: 0.025,
                    description: { v in
                        v >= 0.025
                            ? "Travel speed of \(v.formatted2) mm/sec is within the normal range — sperm are moving at a healthy pace."
                            : "At \(v.formatted2) mm/sec, travel speed is below the 0.025 mm/sec threshold. Faster movement improves fertilization odds."
                    },
                    isAvailable: test.travelSpeed != nil
                )
                FathrMetricCard(
                    title: "Mobility Index",
                    value: test.mobilityIndex ?? 0,
                    maxValue: 100,
                    unit: "%",
                    goodThreshold: 60.0,
                    description: { v in
                        v >= 60
                            ? "A mobility index of \(Int(v))% reflects healthy overall movement quality."
                            : "At \(Int(v))%, the mobility index is below the 60% benchmark — overall movement quality could be improved."
                    },
                    isAvailable: test.mobilityIndex != nil
                )
                FathrMetricCard(
                    title: "Still",
                    value: test.still ?? 0,
                    maxValue: 100,
                    unit: "%",
                    whoRange: 0.0...60.0,
                    description: { v in
                        v <= 60
                            ? "\(Int(v))% of sperm are stationary — within the normal range of under 60%."
                            : "At \(Int(v))%, more than 60% of sperm are not moving, which may reduce fertility potential."
                    },
                    isAvailable: test.still != nil
                )
                FathrStatusCard(
                    title: "Agglutination",
                    status: test.agglutination?.rawValue.capitalized ?? "Not Provided",
                    description: "None or mild agglutination is normal. Severe clumping can indicate immune issues that affect fertility.",
                    isAvailable: test.agglutination != nil
                )

                // MARK: Concentration
                FathrSectionHeader(title: "Concentration", subtitle: "Number of sperm in the sample")

                FathrMetricCard(
                    title: "Sperm Concentration",
                    value: test.spermConcentration ?? 0,
                    maxValue: 100,
                    unit: "M/mL",
                    whoRange: 16.0...100.0,
                    description: { v in
                        v >= 16
                            ? "\(Int(v))M sperm per milliliter — above the WHO minimum of 16M/mL. Good density for conception."
                            : "At \(Int(v))M/mL, concentration is below the WHO minimum of 16M/mL. Improving this increases fertilization odds."
                    },
                    isAvailable: test.spermConcentration != nil,
                    isKeyMetric: true
                )
                FathrMetricCard(
                    title: "Total Spermatozoa",
                    value: test.totalSpermatozoa ?? 0,
                    maxValue: 200,
                    unit: "M/mL",
                    whoRange: 39.0...200.0,
                    description: { v in
                        v >= 39
                            ? "Total count of \(Int(v))M/mL is above the WHO threshold of 39M/mL — a healthy overall count."
                            : "Total count of \(Int(v))M/mL is below the WHO threshold of 39M/mL."
                    },
                    isAvailable: test.totalSpermatozoa != nil
                )
                FathrMetricCard(
                    title: "Functional Spermatozoa",
                    value: test.functionalSpermatozoa ?? 0,
                    maxValue: 100,
                    unit: "M/mL",
                    goodThreshold: 10.0,
                    description: { v in
                        v >= 10
                            ? "\(Int(v))M/mL of sperm are capable of fertilization — above the 10M/mL benchmark."
                            : "Only \(Int(v))M/mL of sperm are considered functional — below the 10M/mL healthy benchmark."
                    },
                    isAvailable: test.functionalSpermatozoa != nil
                )
                FathrMetricCard(
                    title: "Round Cells",
                    value: test.roundCells ?? 0,
                    maxValue: 10,
                    unit: "M/mL",
                    whoRange: 0.0...1.0,
                    description: { v in
                        v <= 1
                            ? "Round cell count of \(v.formatted1)M/mL is within the WHO limit — no signs of inflammation."
                            : "At \(v.formatted1)M/mL, round cells exceed the WHO limit of 1M/mL, which may indicate inflammation."
                    },
                    isAvailable: test.roundCells != nil
                )
                FathrMetricCard(
                    title: "Leukocytes",
                    value: test.leukocytes ?? 0,
                    maxValue: 5,
                    unit: "M/mL",
                    whoRange: 0.0...1.0,
                    description: { v in
                        v <= 1
                            ? "White blood cell count of \(v.formatted1)M/mL is within range — no signs of infection."
                            : "At \(v.formatted1)M/mL, leukocytes exceed the WHO limit. Elevated white cells may signal infection."
                    },
                    isAvailable: test.leukocytes != nil
                )
                FathrMetricCard(
                    title: "Live Spermatozoa",
                    value: test.liveSpermatozoa ?? 0,
                    maxValue: 100,
                    unit: "%",
                    whoRange: 50.0...100.0,
                    description: { v in
                        v >= 50
                            ? "\(Int(v))% of sperm are alive — well above the 50% threshold. Strong vitality is key to reaching the egg."
                            : "At \(Int(v))%, sperm vitality is below the WHO minimum of 50%. Improving this is important for fertilization."
                    },
                    isAvailable: test.liveSpermatozoa != nil
                )

                // MARK: Morphology
                FathrSectionHeader(title: "Morphology", subtitle: "Shape and structure of sperm")

                FathrMetricCard(
                    title: "Morphology Rate",
                    value: test.morphologyRate ?? 0,
                    maxValue: 100,
                    unit: "%",
                    whoRange: 4.0...100.0,
                    description: { v in
                        v >= 4
                            ? "\(v.formatted1)% of sperm have normal shape — above the WHO threshold. Even small improvements here matter."
                            : "At \(v.formatted1)%, morphology is below the WHO minimum of 4%. Shape affects the ability to penetrate an egg."
                    },
                    isAvailable: test.morphologyRate != nil,
                    isKeyMetric: true
                )
                FathrMetricCard(
                    title: "Pathology",
                    value: test.pathology ?? 0,
                    maxValue: 100,
                    unit: "%",
                    whoRange: 0.0...96.0,
                    description: { v in
                        v <= 96
                            ? "\(Int(v))% abnormal forms is within the WHO range of under 96%."
                            : "At \(Int(v))%, abnormal forms exceed the typical WHO range of under 96%."
                    },
                    isAvailable: test.pathology != nil
                )
                FathrMetricCard(
                    title: "Head Defect",
                    value: test.headDefect ?? 0,
                    maxValue: 100,
                    unit: "%",
                    whoRange: 0.0...70.0,
                    description: { v in
                        v <= 70
                            ? "\(Int(v))% head defects — within the typical range of under 70%."
                            : "At \(Int(v))%, head defects exceed the typical 70% threshold."
                    },
                    isAvailable: test.headDefect != nil
                )
                FathrMetricCard(
                    title: "Neck Defect",
                    value: test.neckDefect ?? 0,
                    maxValue: 100,
                    unit: "%",
                    whoRange: 0.0...40.0,
                    description: { v in
                        v <= 40
                            ? "\(Int(v))% neck defects — within the typical range of under 40%."
                            : "At \(Int(v))%, neck defects are above the typical 40% threshold."
                    },
                    isAvailable: test.neckDefect != nil
                )
                FathrMetricCard(
                    title: "Tail Defect",
                    value: test.tailDefect ?? 0,
                    maxValue: 100,
                    unit: "%",
                    whoRange: 0.0...20.0,
                    description: { v in
                        v <= 20
                            ? "\(Int(v))% tail defects — within the typical range of under 20%."
                            : "At \(Int(v))%, tail defects exceed the typical 20% threshold."
                    },
                    isAvailable: test.tailDefect != nil
                )

                // MARK: DNA Fragmentation
                FathrSectionHeader(title: "DNA fragmentation", subtitle: "Damage to sperm DNA")

                FathrMetricCard(
                    title: "DNA Fragmentation Risk",
                    value: Double(test.dnaFragmentationRisk ?? 0),
                    maxValue: 100,
                    unit: "%",
                    whoRange: 0.0...30.0,
                    description: { v in
                        v < 15
                            ? "\(Int(v))% fragmentation is low risk — healthy sperm DNA significantly improves embryo viability."
                            : v < 30
                                ? "At \(Int(v))%, fragmentation is in the moderate range. Antioxidants and lifestyle changes can help."
                                : "At \(Int(v))%, DNA fragmentation is high. Consider consulting a specialist about targeted treatment."
                    },
                    isAvailable: test.dnaFragmentationRisk != nil,
                    isKeyMetric: true
                )
                FathrStatusCard(
                    title: "DNA Risk Category",
                    status: test.dnaRiskCategory ?? "Unknown",
                    description: "Low risk indicates minimal DNA damage — the best outcome for fertility and pregnancy success.",
                    isAvailable: test.dnaRiskCategory != nil
                )
                FathrStatusCard(
                    title: "Overall Status",
                    status: test.overallStatus,
                    description: "A summary of all parameters. Balanced means all key metrics are within healthy ranges.",
                    isAvailable: true
                )

                Text("Results are for personal awareness, not medical diagnosis.")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .background(Color.fathrSurface.ignoresSafeArea())
        .navigationTitle("Wellness Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .tabBar)
    }
}

// MARK: - Hero Card
private struct HeroCard: View {
    let score: Double
    let scoreLabel: String
    let scoreGood: Bool
    let test: TestData

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("Fathr Score")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(Color.white.opacity(0.5))
                .tracking(1.0)
                .padding(.bottom, 6)

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(String(format: "%.0f", score))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 5) {
                    Text("/ 100")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.35))
                    Text(scoreLabel)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
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
                HeroChip(
                    label: "Motility",
                    value: test.totalMobility.map { "\(Int($0))%" } ?? "—",
                    good: (test.totalMobility ?? 0) >= 40
                )
                Spacer()
                HeroChip(
                    label: "Conc.",
                    value: test.spermConcentration.map { "\(Int($0))M" } ?? "—",
                    good: (test.spermConcentration ?? 0) >= 16
                )
                Spacer()
                HeroChip(
                    label: "Morph.",
                    value: test.morphologyRate.map { "\(Int($0))%" } ?? "—",
                    good: (test.morphologyRate ?? 0) >= 4
                )
                Spacer()
                HeroChip(
                    label: "DNA",
                    value: test.dnaFragmentationRisk.map { "\($0)%" } ?? "—",
                    good: (test.dnaFragmentationRisk ?? 100) < 30
                )
            }
            .padding(.bottom, 14)

            Text("Based on WHO 6th Edition. For personal awareness only — not a medical diagnosis.")
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(Color.white.opacity(0.3))
                .lineSpacing(3)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.90, green: 0.40, blue: 0.08),
                    Color(red: 0.75, green: 0.22, blue: 0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
}

// MARK: - Hero Chip
private struct HeroChip: View {
    let label: String
    let value: String
    let good: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(Color.white.opacity(0.45))
            Circle()
                .fill(good
                    ? Color(red: 0.78, green: 0.94, blue: 0.20)
                    : Color(red: 0.98, green: 0.78, blue: 0.45))
                .frame(width: 5, height: 5)
        }
    }
}

// MARK: - Insight Banner
private struct InsightBanner: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 16))
                .foregroundColor(.fathrBlue)
                .padding(.top, 1)

            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.fathrBlue)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.fathrBlueLight)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.fathrBlueMid, lineWidth: 0.5)
        )
    }
}

// MARK: - Section Header
struct FathrSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.fathrText)
            Text(subtitle)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.fathrSub)
        }
        .padding(.top, 12)
        .padding(.bottom, 4)
        .padding(.horizontal, 2)
    }
}

// MARK: - Status Card (Appearance, Liquefaction, etc.)
struct FathrStatusCard: View {
    let title: String
    let status: String
    let description: String
    var isAvailable: Bool = true

    private var isGood: Bool {
        let s = status.lowercased()
        return s.contains("normal") || s.contains("typical") ||
               s.contains("balanced") || s.contains("mild") ||
               s.contains("active") || s.contains("low")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.fathrText)
                Spacer()
                if !isAvailable {
                    Text("Not provided")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.fathrSub)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(Color.fathrSurface)
                        .cornerRadius(20)
                } else {
                    Text(status)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(isGood ? .fathrSuccess : .fathrDanger)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(isGood ? Color.fathrBlueLight : Color.fathrDangerBg)
                        .cornerRadius(20)
                }
            }
            .padding(.bottom, 8)

            Text(description)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.fathrSub)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color.fathrOff)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.fathrBorder, lineWidth: 0.5)
        )
    }
}

// MARK: - Metric Card (with progress bar)
struct FathrMetricCard: View {
    let title: String
    let value: Double
    let maxValue: Double
    let unit: String
    var whoRange: ClosedRange<Double>? = nil
    var goodThreshold: Double? = nil
    let description: (Double) -> String
    var isAvailable: Bool = true
    var isKeyMetric: Bool = false

    // MARK: - Computed
    private var withinRange: Bool {
        guard isAvailable else { return true }
        if let range = whoRange { return range.contains(value) }
        if let threshold = goodThreshold { return value >= threshold }
        return true
    }

    private var showsBadge: Bool {
        isAvailable && (whoRange != nil || goodThreshold != nil)
    }

    private var badgeText: String {
        if whoRange != nil { return withinRange ? "Normal" : "Below WHO" }
        if goodThreshold != nil { return withinRange ? "Normal" : "Low" }
        return ""
    }

    private var barColor: Color {
        guard isAvailable else { return Color.fathrBorder }
        if !showsBadge { return .fathrBlue }
        return withinRange ? .fathrGreen : Color(red: 0.94, green: 0.62, blue: 0.15)
    }

    private var whoLabel: String? {
        guard let range = whoRange else { return nil }
        let lo = range.lowerBound
        let hi = range.upperBound
        let loStr = lo == lo.rounded() ? "\(Int(lo))" : String(format: "%.1f", lo)
        let hiStr = hi == hi.rounded() ? "\(Int(hi))" : String(format: "%.1f", hi)
        let unitStr = unit.isEmpty ? "" : " \(unit)"
        return "WHO: \(loStr)–\(hiStr)\(unitStr)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Key metric tag
            if isKeyMetric {
                Text("KEY METRIC")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(.fathrGreen)
                    .tracking(0.8)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(red: 0.88, green: 0.96, blue: 0.93))
                    .cornerRadius(20)
                    .padding(.bottom, 10)
            }

            // Title + badge row
            HStack(alignment: .center) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.fathrText)
                Spacer()
                if !isAvailable {
                    Text("Not provided")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.fathrSub)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(Color.fathrSurface)
                        .cornerRadius(20)
                } else if showsBadge {
                    Text(badgeText)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(withinRange ? .fathrSuccess : Color(red: 0.52, green: 0.31, blue: 0.04))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(withinRange
                            ? Color(red: 0.88, green: 0.96, blue: 0.93)
                            : Color(red: 0.98, green: 0.93, blue: 0.86))
                        .cornerRadius(20)
                }
            }
            .padding(.bottom, 8)

            if isAvailable {
                // Value
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value == value.rounded() ? String(format: "%.0f", value) : String(format: "%.1f", value))
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.fathrText)
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.fathrSub)
                    }
                }
                .padding(.bottom, 8)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.fathrSurface)
                            .frame(height: 5)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor)
                            .frame(width: geo.size.width * CGFloat(min(value / maxValue, 1.0)), height: 5)
                    }
                }
                .frame(height: 5)
                .padding(.bottom, 7)

                // WHO range label
                if let label = whoLabel {
                    Text(label)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(withinRange ? .fathrSuccess : Color(red: 0.52, green: 0.31, blue: 0.04))
                        .padding(.bottom, 6)
                }
            }

            // Contextual description
            Text(isAvailable ? description(value) : "No data provided for this metric.")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.fathrSub)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isKeyMetric
                        ? Color.fathrGreen.opacity(0.35)
                        : (isAvailable && showsBadge && !withinRange
                           ? Color(red: 0.52, green: 0.31, blue: 0.04).opacity(0.25)
                           : Color.fathrBorder),
                    lineWidth: isKeyMetric ? 1.0 : 0.5
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(isAvailable ? "\(String(format: "%.1f", value)) \(unit)" : "Not Provided"). \(isAvailable ? description(value) : "")")
    }
}

// MARK: - Double helpers
private extension Double {
    var formatted1: String { String(format: "%.1f", self) }
    var formatted2: String { String(format: "%.3f", self) }
}

// MARK: - Preview
struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ResultsView(test: TestData(
                id: nil,
                appearance: .normal,
                liquefaction: .normal,
                consistency: .medium,
                semenQuantity: 2.0,
                pH: 7.4,
                totalMobility: 50.0,
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
            ))
            .environmentObject(PurchaseModel())
        }
    }
}
