import SwiftUI

// MARK: - Status Badge Helper (UNCHANGED)
private func badgeColor(for status: String) -> Color {
    let s = status.lowercased()
    if s.contains("normal") || s.contains("typical") || s.contains("active") ||
       s.contains("mild") || s.contains("balanced") || s.contains("low") {
        return .green
    }
    return .orange
}

// MARK: - Shared brand colors (ResultsView scope)
private extension Color {
    static let fGreen       = Color(red: 0.114, green: 0.620, blue: 0.459)   // #1D9E75
    static let fGreenLight  = Color(red: 0.882, green: 0.961, blue: 0.933)   // #E1F5EE
    static let fGreenDark   = Color(red: 0.059, green: 0.431, blue: 0.337)   // #0F6E56
    static let fAmberLight  = Color(red: 0.980, green: 0.929, blue: 0.855)   // #FAEEDA
    static let fAmberDark   = Color(red: 0.522, green: 0.310, blue: 0.043)   // #854F0B
    static let fSurface     = Color(red: 0.965, green: 0.965, blue: 0.957)   // #F5F5F0
    static let fBorder      = Color(red: 0.878, green: 0.878, blue: 0.863)   // #E0E0DC
    static let fDark        = Color(red: 0.102, green: 0.102, blue: 0.102)   // #1A1A1A
    static let fMuted       = Color(red: 0.373, green: 0.369, blue: 0.353)   // #5F5E5A
}

// MARK: - Progress Status Box
struct ProgressStatusBox: View {
    let title: String
    let value: Double
    let maxValue: Double
    let unit: String
    let whoRange: ClosedRange<Double>?
    let description: String
    let isAvailable: Bool
    var isKeyMetric: Bool = false

    init(title: String, value: Double, maxValue: Double, unit: String,
         whoRange: ClosedRange<Double>? = nil, description: String,
         isAvailable: Bool = true, isKeyMetric: Bool = false) {
        self.title = title
        self.value = value
        self.maxValue = maxValue
        self.unit = unit
        self.whoRange = whoRange
        self.description = description
        self.isAvailable = isAvailable
        self.isKeyMetric = isKeyMetric
    }

    // MARK: - Computed (UNCHANGED logic)
    private var withinRange: Bool {
        guard let range = whoRange, isAvailable else { return true }
        return range.contains(value)
    }

    private var rangeText: String {
        guard let range = whoRange, isAvailable else { return "" }
        return "(WHO: \(String(format: "%.1f", range.lowerBound))–\(String(format: "%.1f", range.upperBound)) \(unit))"
    }

    private var barColor: Color {
        guard isAvailable else { return .gray }
        if whoRange == nil { return Color(red: 0.22, green: 0.60, blue: 0.87) }
        return withinRange ? .fGreen : Color(red: 0.94, green: 0.62, blue: 0.15)
    }

    private var badgeText: String {
        guard isAvailable else { return "Not provided" }
        guard whoRange != nil else { return "" }
        return withinRange ? "Normal" : "Below WHO"
    }

    private var isGoodBadge: Bool { withinRange }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Key metric label
            if isKeyMetric {
                Text("KEY METRIC")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundColor(.fGreenDark)
                    .tracking(0.8)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.fGreenLight)
                    .cornerRadius(20)
                    .padding(.bottom, 10)
            }

            // Title row + badge
            HStack(alignment: .center) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                if isAvailable && whoRange != nil {
                    Text(badgeText)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(withinRange ? .fGreenDark : .fAmberDark)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(withinRange ? Color.fGreenLight : Color.fAmberLight)
                        .cornerRadius(20)
                } else if !isAvailable {
                    Text("Not provided")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(Color.fSurface)
                        .cornerRadius(20)
                }
            }
            .padding(.bottom, 8)

            if isAvailable {
                // Large value display
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(String(format: value == value.rounded() ? "%.0f" : "%.1f", value))
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 8)

                // Progress bar — taller, rounded
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.fSurface)
                            .frame(height: 5)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor)
                            .frame(width: geo.size.width * CGFloat(min(value / maxValue, 1.0)), height: 5)
                    }
                }
                .frame(height: 5)
                .padding(.bottom, 7)

                // WHO range label
                if let range = whoRange {
                    Text("WHO: \(String(format: "%.1f", range.lowerBound))–\(String(format: "%.1f", range.upperBound)) \(unit)")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(withinRange ? .fGreenDark : .fAmberDark)
                        .padding(.bottom, 6)
                }
            }

            // Description (UNCHANGED)
            Text(description)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isKeyMetric
                        ? Color.fGreen.opacity(0.4)
                        : (isAvailable && whoRange != nil && !withinRange
                           ? Color.fAmberDark.opacity(0.25)
                           : Color.fBorder),
                    lineWidth: isKeyMetric ? 1.0 : 0.5
                )
        )
        // UNCHANGED accessibility
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(isAvailable ? "\(String(format: "%.1f", value)) \(unit) \(rangeText)" : "Not Provided"). \(description)")
    }
}

// MARK: - Results View
struct ResultsView: View {
    let test: TestData
    @EnvironmentObject var purchaseModel: PurchaseModel

    // MARK: - Hero score calculation (UNCHANGED)
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

    private var scoreLabel: String { fathrScore >= 70 ? "In the fertile zone" : "Needs boosting" }
    private var scoreGood: Bool { fathrScore >= 70 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                // MARK: - Hero Score Card (dark premium style)
                VStack(alignment: .leading, spacing: 0) {

                    // Top: score label
                    Text("Fathr score")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.5))
                        .tracking(0.8)
                        .padding(.bottom, 8)

                    // Score number + status badge
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(String(format: "%.0f", fathrScore))
                            .font(.system(size: 56, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("/ 100")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.4))
                            Text(scoreLabel)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(scoreGood
                                    ? Color(red: 0.784, green: 0.945, blue: 0.208)   // lime
                                    : Color(red: 0.980, green: 0.780, blue: 0.459))  // amber
                                .padding(.horizontal, 9)
                                .padding(.vertical, 3)
                                .background(
                                    scoreGood
                                        ? Color(red: 0.784, green: 0.945, blue: 0.208).opacity(0.15)
                                        : Color(red: 0.980, green: 0.780, blue: 0.459).opacity(0.15)
                                )
                                .cornerRadius(20)
                        }
                        .padding(.bottom, 6)
                        Spacer()
                    }
                    .padding(.bottom, 16)

                    // Divider
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 0.5)
                        .padding(.bottom, 14)

                    // Key metrics row
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

                    // Disclaimer
                    Text("Based on WHO 6th Edition. For personal awareness only — not a medical diagnosis.")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.35))
                        .lineSpacing(3)
                }
                .padding(18)
                .background(Color.fDark)
                .cornerRadius(16)

                // MARK: - Analysis Section (UNCHANGED structure, updated section headers)
                SectionHeader(title: "Analysis", subtitle: "Physical properties of the sample")

                StatusBox(
                    title: "Appearance",
                    status: test.appearance?.rawValue.capitalized ?? "Not Provided",
                    description: "How the sample looks. Normal is clear or white, indicating healthy semen."
                )
                StatusBox(
                    title: "Liquefaction",
                    status: test.liquefaction?.rawValue.capitalized ?? "Not Provided",
                    description: "How the sample changes from gel to liquid. Normal liquefaction aids sperm movement."
                )
                StatusBox(
                    title: "Consistency",
                    status: test.consistency?.rawValue.capitalized ?? "Not Provided",
                    description: "How thick or thin the sample is. Medium consistency is typical for healthy semen."
                )
                ProgressStatusBox(
                    title: "Semen Quantity",
                    value: test.semenQuantity ?? 0.0,
                    maxValue: 10.0,
                    unit: "mL",
                    whoRange: 1.4...6.0,
                    description: "The volume of the sample. WHO recommends 1.4–6.0 mL for adequate sperm delivery.",
                    isAvailable: test.semenQuantity != nil
                )
                ProgressStatusBox(
                    title: "pH",
                    value: test.pH ?? 0.0,
                    maxValue: 14.0,
                    unit: "",
                    whoRange: 7.2...8.0,
                    description: "The acidity or alkalinity of the sample. A pH of 7.2–8.0 supports sperm function.",
                    isAvailable: test.pH != nil
                )

                // MARK: - Motility Section (UNCHANGED call sites)
                SectionHeader(title: "Motility", subtitle: "How well sperm move and swim")
                    .accessibilityHeading(.h2)
                    .accessibilityLabel("Motility section: Checks how well sperm move and swim.")

                ProgressStatusBox(
                    title: "Total Mobility",
                    value: test.totalMobility ?? 0.0,
                    maxValue: 100.0,
                    unit: "%",
                    whoRange: 40.0...100.0,
                    description: "How many sperm are moving. WHO recommends ≥40% for healthy fertility.",
                    isAvailable: test.totalMobility != nil,
                    isKeyMetric: true
                )
                ProgressStatusBox(
                    title: "Progressive Mobility",
                    value: test.progressiveMobility ?? 0.0,
                    maxValue: 100.0,
                    unit: "%",
                    whoRange: 30.0...100.0,
                    description: "How many sperm swim forward. WHO suggests ≥30% for effective fertilization.",
                    isAvailable: test.progressiveMobility != nil
                )
                ProgressStatusBox(
                    title: "Non-Progressive Mobility",
                    value: test.nonProgressiveMobility ?? 0.0,
                    maxValue: 100.0,
                    unit: "%",
                    description: "How many sperm move but don't swim forward. Lower values are common.",
                    isAvailable: test.nonProgressiveMobility != nil
                )
                ProgressStatusBox(
                    title: "Travel Speed",
                    value: test.travelSpeed ?? 0.0,
                    maxValue: 1.0,
                    unit: "mm/sec",
                    description: "How fast sperm move. Higher speeds suggest better motility.",
                    isAvailable: test.travelSpeed != nil
                )
                ProgressStatusBox(
                    title: "Mobility Index",
                    value: test.mobilityIndex ?? 0.0,
                    maxValue: 100.0,
                    unit: "%",
                    description: "A measure of overall sperm movement quality. Higher values indicate better function.",
                    isAvailable: test.mobilityIndex != nil
                )
                ProgressStatusBox(
                    title: "Still",
                    value: test.still ?? 0.0,
                    maxValue: 100.0,
                    unit: "%",
                    description: "How many sperm are not moving. Lower values mean more active sperm.",
                    isAvailable: test.still != nil
                )
                StatusBox(
                    title: "Agglutination",
                    status: test.agglutination?.rawValue.capitalized ?? "Not Provided",
                    description: "Whether sperm stick together. None or mild is normal, severe may affect fertility."
                )

                // MARK: - Concentration Section (UNCHANGED call sites)
                SectionHeader(title: "Concentration", subtitle: "Number of sperm in the sample")
                    .accessibilityHeading(.h2)
                    .accessibilityLabel("Concentration section: Measures the number of sperm in the sample.")

                ProgressStatusBox(
                    title: "Sperm Concentration",
                    value: test.spermConcentration ?? 0.0,
                    maxValue: 100.0,
                    unit: "M/mL",
                    whoRange: 16.0...100.0,
                    description: "How many sperm per milliliter. WHO recommends ≥16 M/mL for fertility.",
                    isAvailable: test.spermConcentration != nil,
                    isKeyMetric: true
                )
                ProgressStatusBox(
                    title: "Total Spermatozoa",
                    value: test.totalSpermatozoa ?? 0.0,
                    maxValue: 200.0,
                    unit: "M/mL",
                    whoRange: 39.0...200.0,
                    description: "Total sperm in the sample. WHO suggests ≥39 M/mL for conception.",
                    isAvailable: test.totalSpermatozoa != nil
                )
                ProgressStatusBox(
                    title: "Functional Spermatozoa",
                    value: test.functionalSpermatozoa ?? 0.0,
                    maxValue: 100.0,
                    unit: "M/mL",
                    description: "Sperm capable of fertilization. Higher counts improve fertility chances.",
                    isAvailable: test.functionalSpermatozoa != nil
                )
                ProgressStatusBox(
                    title: "Round Cells",
                    value: test.roundCells ?? 0.0,
                    maxValue: 10.0,
                    unit: "M/mL",
                    whoRange: 0.0...1.0,
                    description: "Non-sperm cells in the sample. WHO recommends <1 M/mL to avoid inflammation.",
                    isAvailable: test.roundCells != nil
                )
                ProgressStatusBox(
                    title: "Leukocytes",
                    value: test.leukocytes ?? 0.0,
                    maxValue: 5.0,
                    unit: "M/mL",
                    whoRange: 0.0...1.0,
                    description: "White blood cells in the sample. WHO suggests <1 M/mL to rule out infection.",
                    isAvailable: test.leukocytes != nil
                )
                ProgressStatusBox(
                    title: "Live Spermatozoa",
                    value: test.liveSpermatozoa ?? 0.0,
                    maxValue: 100.0,
                    unit: "%",
                    whoRange: 50.0...100.0,
                    description: "How many sperm are alive. ≥50% is typical for healthy semen.",
                    isAvailable: test.liveSpermatozoa != nil
                )

                // MARK: - Morphology Section (UNCHANGED call sites)
                SectionHeader(title: "Morphology", subtitle: "Shape and structure of sperm")
                    .accessibilityHeading(.h2)
                    .accessibilityLabel("Morphology section: Examines the shape and structure of sperm.")

                ProgressStatusBox(
                    title: "Morphology Rate",
                    value: test.morphologyRate ?? 0.0,
                    maxValue: 100.0,
                    unit: "%",
                    whoRange: 4.0...100.0,
                    description: "How many sperm have normal shape. WHO recommends ≥4% for fertility.",
                    isAvailable: test.morphologyRate != nil,
                    isKeyMetric: true
                )
                ProgressStatusBox(
                    title: "Pathology",
                    value: test.pathology ?? 0.0,
                    maxValue: 100.0,
                    unit: "%",
                    description: "How many sperm have abnormal shapes. Lower percentages indicate healthier semen.",
                    isAvailable: test.pathology != nil
                )
                ProgressStatusBox(
                    title: "Head Defect",
                    value: test.headDefect ?? 0.0,
                    maxValue: 100.0,
                    unit: "%",
                    description: "Sperm with head abnormalities. Fewer defects suggest better fertility.",
                    isAvailable: test.headDefect != nil
                )
                ProgressStatusBox(
                    title: "Neck Defect",
                    value: test.neckDefect ?? 0.0,
                    maxValue: 100.0,
                    unit: "%",
                    description: "Sperm with neck or midpiece issues. Lower values are better for sperm function.",
                    isAvailable: test.neckDefect != nil
                )
                ProgressStatusBox(
                    title: "Tail Defect",
                    value: test.tailDefect ?? 0.0,
                    maxValue: 100.0,
                    unit: "%",
                    description: "Sperm with tail abnormalities. Fewer defects improve sperm movement.",
                    isAvailable: test.tailDefect != nil
                )

                // MARK: - DNA Fragmentation Section (UNCHANGED call sites)
                SectionHeader(title: "DNA fragmentation", subtitle: "Damage to sperm DNA")
                    .accessibilityHeading(.h2)
                    .accessibilityLabel("DNA Fragmentation section: Assesses damage to sperm DNA.")

                ProgressStatusBox(
                    title: "DNA Fragmentation Risk",
                    value: Double(test.dnaFragmentationRisk ?? 0),
                    maxValue: 100.0,
                    unit: "%",
                    whoRange: 0.0...30.0,
                    description: "Damage to sperm DNA. Lower percentages (<30%) indicate healthier sperm.",
                    isAvailable: test.dnaFragmentationRisk != nil,
                    isKeyMetric: true
                )
                StatusBox(
                    title: "DNA Risk Category",
                    status: test.dnaRiskCategory ?? "Unknown",
                    description: "Risk level of sperm DNA damage. Low risk is best for fertility."
                )

                StatusBox(
                    title: "Overall Status",
                    status: test.overallStatus,
                    description: "A summary of your test results. Normal indicates healthy semen parameters."
                )

                // UNCHANGED footer disclaimer
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
        .background(Color.fSurface.ignoresSafeArea())
        // UNCHANGED modifiers
        .navigationTitle("Wellness Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EmptyView()
            }
        }
        .toolbar(.visible, for: .tabBar)
    }
}

// MARK: - Section Header (replaces the inline VStack pattern — same semantics)
private struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            Text(subtitle)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.top, 6)
        .padding(.horizontal, 2)
    }
}

// MARK: - Hero Chip
// Layout changed: vertical stack, dark background. Logic (good/bad, values) UNCHANGED.
private struct HeroChip: View {
    let label: String
    let value: String
    let good: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(Color.white.opacity(0.45))
            Circle()
                .fill(good
                    ? Color(red: 0.784, green: 0.945, blue: 0.208)   // lime = good
                    : Color(red: 0.980, green: 0.780, blue: 0.459))  // amber = warn
                .frame(width: 5, height: 5)
        }
    }
}

// MARK: - Preview (UNCHANGED)
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
