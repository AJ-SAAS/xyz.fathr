import SwiftUI

struct ResultsView: View {
    let test: TestData
    @EnvironmentObject var purchaseModel: PurchaseModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Detailed Wellness Metrics")
                    .font(.title2)
                    .fontDesign(.rounded)
                    .padding(.bottom)
                
                Text("Visualizations are based on WHO 6th Edition standards for informational purposes only. Fathr is not a medical device. Consult a doctor for fertility concerns.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Analysis")
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .accessibilityHeading(.h2)
                    Text("Tests the physical properties of the semen sample.")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 16)
                        .accessibilityLabel("Analysis section: Tests the physical properties of the semen sample.")
                }
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Motility")
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .accessibilityHeading(.h2)
                    Text("Checks how well sperm move and swim.")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 16)
                        .accessibilityLabel("Motility section: Checks how well sperm move and swim.")
                }
                ProgressStatusBox(
                    title: "Total Mobility",
                    value: test.totalMobility ?? 0.0,
                    maxValue: 100.0,
                    unit: "%",
                    whoRange: 40.0...100.0,
                    description: "How many sperm are moving. WHO recommends ≥40% for healthy fertility.",
                    isAvailable: test.totalMobility != nil
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
                    description: "How many sperm move but don’t swim forward. Lower values are common.",
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Concentration")
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .accessibilityHeading(.h2)
                    Text("Measures the number of sperm in the sample.")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 16)
                        .accessibilityLabel("Concentration section: Measures the number of sperm in the sample.")
                }
                ProgressStatusBox(
                    title: "Sperm Concentration",
                    value: test.spermConcentration ?? 0.0,
                    maxValue: 100.0,
                    unit: "M/mL",
                    whoRange: 16.0...100.0,
                    description: "How many sperm per milliliter. WHO recommends ≥16 M/mL for fertility.",
                    isAvailable: test.spermConcentration != nil
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Morphology")
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .accessibilityHeading(.h2)
                    Text("Examines the shape and structure of sperm.")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 16)
                        .accessibilityLabel("Morphology section: Examines the shape and structure of sperm.")
                }
                ProgressStatusBox(
                    title: "Morphology Rate",
                    value: test.morphologyRate ?? 0.0,
                    maxValue: 100.0,
                    unit: "%",
                    whoRange: 4.0...100.0,
                    description: "How many sperm have normal shape. WHO recommends ≥4% for fertility.",
                    isAvailable: test.morphologyRate != nil
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("DNA Fragmentation")
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .accessibilityHeading(.h2)
                    Text("Assesses damage to sperm DNA.")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 16)
                        .accessibilityLabel("DNA Fragmentation section: Assesses damage to sperm DNA.")
                }
                ProgressStatusBox(
                    title: "DNA Fragmentation Risk",
                    value: Double(test.dnaFragmentationRisk ?? 0),
                    maxValue: 100.0,
                    unit: "%",
                    whoRange: 0.0...30.0,
                    description: "Damage to sperm DNA. Lower percentages (<30%) indicate healthier sperm.",
                    isAvailable: test.dnaFragmentationRisk != nil
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
                
                Text("Results are for personal awareness, not medical diagnosis.")
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundColor(.gray)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Wellness Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EmptyView() // Let default back button appear
            }
        }
        .toolbar(.visible, for: .tabBar) // Ensure tab bar remains visible
    }
}

// ProgressStatusBox remains unchanged
struct ProgressStatusBox: View {
    let title: String
    let value: Double
    let maxValue: Double
    let unit: String
    let whoRange: ClosedRange<Double>?
    let description: String
    let isAvailable: Bool

    init(title: String, value: Double, maxValue: Double, unit: String, whoRange: ClosedRange<Double>? = nil, description: String, isAvailable: Bool = true) {
        self.title = title
        self.value = value
        self.maxValue = maxValue
        self.unit = unit
        self.whoRange = whoRange
        self.description = description
        self.isAvailable = isAvailable
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontDesign(.rounded)
                .foregroundColor(.secondary)
            if isAvailable {
                ProgressView(value: value, total: maxValue)
                    .progressViewStyle(.linear)
                    .tint(withinRange ? .green : .orange)
                Text("\(String(format: "%.1f", value)) \(unit) \(rangeText)")
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
            } else {
                Text("Not Provided")
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundColor(.gray)
            }
            Text(description)
                .font(.caption)
                .fontDesign(.rounded)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(isAvailable ? "\(String(format: "%.1f", value)) \(unit) \(rangeText)" : "Not Provided"). \(description)")
    }
    
    private var withinRange: Bool {
        guard let range = whoRange, isAvailable else { return true }
        return range.contains(value)
    }
    
    private var rangeText: String {
        guard let range = whoRange, isAvailable else { return "" }
        return "(WHO: \(String(format: "%.1f", range.lowerBound))–\(String(format: "%.1f", range.upperBound)) \(unit))"
    }
}

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
