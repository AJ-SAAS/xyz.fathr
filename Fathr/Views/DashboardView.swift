import SwiftUI

// Move Trend enum to file level to ensure accessibility
enum Trend {
    case up, down, none
}

// Move Color extension to file scope
extension Color {
    func darker(by percentage: Double) -> Color {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let red = max(components[0] - CGFloat(percentage), 0)
        let green = max(components[1] - CGFloat(percentage), 0)
        let blue = max(components[2] - CGFloat(percentage), 0)
        return Color(UIColor(red: red, green: green, blue: blue, alpha: components[3]))
    }
}

struct DashboardView: View {
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel
    @State private var showInput = false
    @State private var showPaywall = false
    @AppStorage("lastTipDate") private var lastTipDate: String = ""
    @State private var checkedTips: [Int: Bool] = [:]
    @Binding var selectedTab: Int
    @State private var showFullAnalysis = false
    @State private var selectedTest: TestData?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Logo at top center
                    Image("Fathr-logo-dash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    
                    WelcomeHeaderView(showInput: $showInput)
                    
                    // Show premium content only if tests exist
                    if !testStore.tests.isEmpty {
                        FertilitySnapshotView(
                            selectedTab: $selectedTab,
                            showPaywall: $showPaywall,
                            showFullAnalysis: $showFullAnalysis
                        )
                        
                        CoreMetricsOverviewView()
                        
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
                    }
                    
                    DisclaimerView()
                }
                .padding(.vertical)
            }
            .background(Color.white)
            .navigationTitle("")
            .sheet(isPresented: $showInput) {
                TestInputView()
                    .environmentObject(testStore)
                    .environmentObject(purchaseModel)
            }
            .sheet(isPresented: $showPaywall) {
                PurchaseView(isPresented: $showPaywall, purchaseModel: purchaseModel)
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
            .onAppear {
                updateDailyTips()
                print("DashboardView: testStore.tests count: \(testStore.tests.count)")
                for test in testStore.tests {
                    print("Test: ID: \(test.id ?? "nil"), analysisStatus: \(test.analysisStatus), overallStatus: \(test.overallStatus), Date: \(test.date), Concentration: \(test.spermConcentration ?? 0), Motility: \(test.totalMobility ?? 0)")
                }
            }
            .onChange(of: lastTipDate) {
                updateDailyTips()
            }
        }
    }

    private func evaluateMetrics(for test: TestData) -> ([String], [String]) {
        var winningMetrics: [String] = []
        var improvementMetrics: [String] = []

        // Define thresholds based on WHO standards
        let motilityThreshold = 40.0
        let concentrationThreshold = 15.0
        let morphologyThreshold = 4.0
        let dnaFragmentationThreshold = 15.0 // Example threshold for DNA fragmentation risk
        let semenQuantityThreshold = 1.4
        let pHMinThreshold = 7.2
        let pHMaxThreshold = 8.0

        // Helper function to check historical decline for Double? properties
        func hasDeclinedDouble(metric: Double, historicalKeyPath: KeyPath<TestData, Double?>, threshold: Double) -> Bool {
            guard testStore.tests.count > 1 else { return false }
            let previousTests = testStore.tests.dropFirst()
            let avgHistorical = previousTests.reduce(0.0) { sum, test in
                sum + (test[keyPath: historicalKeyPath] ?? 0.0)
            } / Double(previousTests.count)
            return metric < avgHistorical && metric >= threshold
        }

        // Helper function to check historical decline for Int? properties
        func hasDeclinedInt(metric: Int, historicalKeyPath: KeyPath<TestData, Int?>, threshold: Double) -> Bool {
            guard testStore.tests.count > 1 else { return false }
            let previousTests = testStore.tests.dropFirst()
            let avgHistorical = previousTests.reduce(0.0) { sum, test in
                sum + Double(test[keyPath: historicalKeyPath] ?? 0)
            } / Double(previousTests.count)
            return Double(metric) < avgHistorical && Double(metric) >= threshold
        }

        // Motility
        let motility = test.totalMobility ?? 0.0
        if motility >= motilityThreshold {
            winningMetrics.append("Motility: \(Int(motility))% (Great movement!)")
            if hasDeclinedDouble(metric: motility, historicalKeyPath: \.totalMobility, threshold: motilityThreshold) {
                improvementMetrics.append("Motility: \(Int(motility))% is strong, but down from your average. Try regular exercise to maintain it.")
            } else if motility < 50.0 { // Aspirational threshold
                improvementMetrics.append("Motility: \(Int(motility))% is good. Aim for ≥ 50% with a diet rich in antioxidants.")
            }
        } else {
            improvementMetrics.append("Motility: \(Int(motility))% (Aim for ≥ 40% with zinc-rich foods like pumpkin seeds)")
        }

        // Concentration
        let concentration = test.spermConcentration ?? 0.0
        if concentration >= concentrationThreshold {
            winningMetrics.append("Concentration: \(Int(concentration)) million/mL (Strong count!)")
            if hasDeclinedDouble(metric: concentration, historicalKeyPath: \.spermConcentration, threshold: concentrationThreshold) {
                improvementMetrics.append("Concentration: \(Int(concentration)) million/mL is good, but lower than your average. Avoid heat exposure.")
            } else if concentration < 20.0 { // Aspirational threshold
                improvementMetrics.append("Concentration: \(Int(concentration)) million/mL is solid. Boost to ≥ 20 million/mL with Brazil nuts for selenium.")
            }
        } else {
            improvementMetrics.append("Concentration: \(Int(concentration)) million/mL (Aim for ≥ 15 million/mL with a balanced diet)")
        }

        // Morphology
        let morphology = test.morphologyRate ?? 0.0
        if morphology >= morphologyThreshold {
            winningMetrics.append("Morphology: \(Int(morphology))% normal forms (Solid structure!)")
            if hasDeclinedDouble(metric: morphology, historicalKeyPath: \.morphologyRate, threshold: morphologyThreshold) {
                improvementMetrics.append("Morphology: \(Int(morphology))% is good, but below your average. Reduce stress to maintain it.")
            } else if morphology < 6.0 { // Aspirational threshold
                improvementMetrics.append("Morphology: \(Int(morphology))% is strong. Aim for ≥ 6% with Omega-3 supplements.")
            }
        } else {
            improvementMetrics.append("Morphology: \(Int(morphology))% normal forms (Aim for ≥ 4% with CoQ10 supplements)")
        }

        // Sperm Analysis Status
        if test.analysisStatus == "Typical" {
            winningMetrics.append("Sperm Analysis: Typical (Excellent overall health!)")
        } else {
            improvementMetrics.append("Sperm Analysis: \(test.analysisStatus) (Consult a specialist for personalized advice)")
        }

        // Additional Metric: DNA Fragmentation Risk
        let dnaFragmentation = test.dnaFragmentationRisk ?? 0
        if Double(dnaFragmentation) <= dnaFragmentationThreshold {
            winningMetrics.append("DNA Fragmentation: Low risk (Healthy sperm DNA!)")
            if hasDeclinedInt(metric: dnaFragmentation, historicalKeyPath: \.dnaFragmentationRisk, threshold: dnaFragmentationThreshold) {
                improvementMetrics.append("DNA Fragmentation: Low but slightly up from your average. Avoid oxidative stress with berries.")
            } else if Double(dnaFragmentation) > 10.0 { // Aspirational threshold
                improvementMetrics.append("DNA Fragmentation: Low risk. Keep it below 10% with antioxidant-rich foods.")
            }
        } else {
            improvementMetrics.append("DNA Fragmentation: \(Int(dnaFragmentation))% (Aim for ≤ 15% by avoiding smoking and stress)")
        }

        // Additional Metric: Semen Quantity
        let semenQuantity = test.semenQuantity ?? 0.0
        if semenQuantity >= semenQuantityThreshold {
            winningMetrics.append("Semen Volume: \(String(format: "%.1f", semenQuantity)) mL (Good volume!)")
            if hasDeclinedDouble(metric: semenQuantity, historicalKeyPath: \.semenQuantity, threshold: semenQuantityThreshold) {
                improvementMetrics.append("Semen Volume: \(String(format: "%.1f", semenQuantity)) mL is good, but below your average. Stay hydrated.")
            } else if semenQuantity < 2.0 { // Aspirational threshold
                improvementMetrics.append("Semen Volume: \(String(format: "%.1f", semenQuantity)) mL is sufficient. Aim for ≥ 2.0 mL with adequate hydration.")
            }
        } else {
            improvementMetrics.append("Semen Volume: \(String(format: "%.1f", semenQuantity)) mL (Aim for ≥ 1.4 mL with adequate hydration)")
        }

        // Additional Metric: pH
        let pH = test.pH ?? 0.0
        if pH >= pHMinThreshold && pH <= pHMaxThreshold {
            winningMetrics.append("pH: \(String(format: "%.1f", pH)) (Optimal range!)")
            if hasDeclinedDouble(metric: pH, historicalKeyPath: \.pH, threshold: pHMinThreshold) {
                improvementMetrics.append("pH: \(String(format: "%.1f", pH)) is optimal but shifted from your average. Maintain balance with a healthy diet.")
            }
        } else {
            improvementMetrics.append("pH: \(String(format: "%.1f", pH)) (Aim for 7.2–8.0 with a balanced diet)")
        }

        // Fallback: If no improvement metrics, provide general maintenance tips
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
}

struct WelcomeHeaderView: View {
    @Binding var showInput: Bool

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
            Button(action: {
                showInput = true
            }) {
                Image(systemName: "plus")
                    .font(.body.bold())
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Add New Test")
        }
        .padding(.horizontal)
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}

struct FertilitySnapshotView: View {
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel
    @Binding var selectedTab: Int
    @Binding var showPaywall: Bool
    @Binding var showFullAnalysis: Bool

    var body: some View {
        if !testStore.tests.isEmpty {
            let averages = calculateAverages()
            let scoreStatus = averages.overallScore >= 70 ? "good" : "bad"
            HStack(alignment: .top, spacing: 16) {
                // Your Fathr Score Card
                VStack(alignment: .center, spacing: 8) {
                    Text("Your Fathr Score")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .foregroundColor(.black)
                    Text(String(format: "%.1f", averages.overallScore))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.black)
                    Text(scoreStatus == "good" ? "In the fertile zone" : "Needs boosting")
                        .font(.caption)
                        .foregroundColor(scoreStatus == "good" ? Color.green.darker(by: 0.2) : Color.yellow.darker(by: 0.2))
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 160)
                .background(Color.white)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.black, lineWidth: 1)
                )
                .shadow(color: .gray.opacity(0.1), radius: 5)

                // Fertility Snapshot Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Fertility Snapshot")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .foregroundColor(.black)
                    if testStore.tests.first != nil {
                        Button(action: {
                            if purchaseModel.isSubscribed {
                                showFullAnalysis = true
                            } else {
                                showPaywall = true
                            }
                        }) {
                            Text("View Full Analysis")
                                .font(.subheadline.bold())
                                .fontDesign(.rounded)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .accessibilityLabel("View Full Analysis")
                    }
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 160)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: .gray.opacity(0.1), radius: 5)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
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

    private func calculateTrend() -> Trend {
        guard testStore.tests.count > 1 else { return .none }

        let latestTest = testStore.tests[0]
        let motilityScore = min((latestTest.totalMobility ?? testStore.tests[0].totalMobility ?? 0.0) * 2.5, 100.0)
        let concentrationScore: Double = {
            let conc = latestTest.spermConcentration ?? 0.0
            return conc <= 15.0 ? (conc / 15.0) * 50.0 : 50.0 + ((conc - 15.0) / 85.0) * 50.0
        }()
        let morphologyScore: Double = {
            let morph = latestTest.morphologyRate ?? 0.0
            return morph <= 4.0 ? (morph / 4.0) * 50.0 : 50.0 + ((morph - 4.0) / 11.0) * 50.0
        }()
        let dnaScore = max(100.0 - (((Double(latestTest.dnaFragmentationRisk ?? 0)) / 15.0) * 50.0), 0.0)
        let analysisScore = calculateAnalysisScore(latestTest)
        
        let currentOverall = (0.35 * motilityScore) + (0.30 * concentrationScore) + (0.15 * morphologyScore) +
                             (0.10 * dnaScore) + (0.10 * analysisScore)

        let previousTests = Array(testStore.tests.dropFirst())
        let prevCount = Double(previousTests.count)

        let totalMotility = previousTests.reduce(0.0) { $0 + min(($1.totalMobility ?? 0.0) * 2.5, 100.0) }
        let totalConcentration = previousTests.reduce(0.0) {
            let conc = $1.spermConcentration ?? 0.0
            let score = conc <= 15.0 ? (conc / 15.0) * 50.0 : 50.0 + ((conc - 15.0) / 85.0) * 50.0
            return $0 + min(score, 100.0)
        }
        let totalMorphology = previousTests.reduce(0.0) {
            let morph = $1.morphologyRate ?? 0.0
            let score = morph <= 4.0 ? (morph / 4.0) * 50.0 : 50.0 + ((morph - 4.0) / 11.0) * 50.0
            return $0 + min(score, 100.0)
        }
        let totalDna = previousTests.reduce(0.0) {
            let dna = Double($1.dnaFragmentationRisk ?? 0)
            let score = max(100.0 - ((dna / 15.0) * 50.0), 0.0)
            return $0 + score
        }
        let totalAnalysis = previousTests.reduce(0.0) { $0 + calculateAnalysisScore($1) }

        let previousOverall = (
            (0.35 * (totalMotility / prevCount)) +
            (0.30 * (totalConcentration / prevCount)) +
            (0.15 * (totalMorphology / prevCount)) +
            (0.10 * (totalDna / prevCount)) +
            (0.10 * (totalAnalysis / prevCount))
        )

        if currentOverall > previousOverall { return .up }
        if currentOverall < previousOverall { return .down }
        return .none
    }
}

struct CoreMetricsOverviewView: View {
    @EnvironmentObject var testStore: TestStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How You're Doing")
                .font(.title2)
                .fontDesign(.rounded)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            if let latestTest = testStore.tests.first {
                ProgressBarView(
                    label: "Analysis",
                    value: min(calculateAnalysisScore(latestTest), 100),
                    maxValue: 100
                )
                
                ProgressBarView(
                    label: "Motility",
                    value: min(latestTest.totalMobility ?? 0, 100),
                    maxValue: 100
                )
                
                ProgressBarView(
                    label: "Concentration",
                    value: min(latestTest.spermConcentration ?? 0, 100),
                    maxValue: 100
                )
                
                ProgressBarView(
                    label: "Morphology",
                    value: min(latestTest.morphologyRate ?? 0, 100),
                    maxValue: 100
                )
                
                Text("Scores are based on WHO standards and your most recent test.")
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                Text("No test data available.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
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
                // Full bar (unfilled portion) in lighter shade
                Rectangle()
                    .fill(barColor.opacity(0.3))
                    .frame(height: 18)
                // Filled portion
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
                    Text("Tap the + button above to add your first test.")
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
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    print("RecentTestsSection: \(testStore.tests.count) tests")
                    for test in testStore.tests {
                        print("Test: ID: \(test.id ?? "nil"), analysisStatus: \(test.analysisStatus), overallStatus: \(test.overallStatus), Date: \(test.date), Concentration: \(test.spermConcentration ?? 0), Motility: \(test.totalMobility ?? 0)")
                    }
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

        let seed = currentDate.hashValue
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

struct DisclaimerView: View {
    var body: some View {
        Text("Visualizations are based on WHO 6th Edition standards for informational purposes only. Fathr is not a medical device. Consult a doctor for fertility concerns.")
            .font(.caption)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .padding(.top)
    }
}

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
        "Don’t microwave food in plastic containers.",
        "Focus on chewing your food slowly today.",
        "Avoid screen time 30 minutes before bed.",
        "Switch from soda to sparkling water.",
        "Take your multivitamin with CoQ10 today.",
        "Eat fatty fish (like salmon) at least once this week.",
        "Add L-carnitine supplement to your routine — boosts sperm movement.",
        "Do 20 squats today — improves blood flow to the pelvic region.",
        "Avoid trans fats — they’re lethal to motility.",
        "Try antioxidant-rich berries today (blueberries, strawberries).",
        "Avoid bike rides longer than 30 minutes today.",
        "Eat Brazil nuts for selenium to support sperm count.",
        "Add a boiled egg to your breakfast — full of nutrients for sperm production.",
        "Avoid soy products today — may affect hormone balance.",
        "Reduce screen time after dinner — supports hormonal recovery.",
        "Try a short cold shower (30s–1min) to stimulate testosterone.",
        "Eat foods rich in folate: spinach, lentils, avocado.",
        "Avoid processed meats today.",
        "Don’t skip meals — your body needs fuel to build quality sperm.",
        "Take a Vitamin C supplement today.",
        "Cook dinner using garlic or turmeric — both have fertility benefits.",
        "Avoid stress triggers today — even brief stress spikes affect sperm DNA.",
        "Take an Omega-3 capsule or eat sardines today.",
        "Stay off your phone for the first hour after waking.",
        "Sleep with blackout curtains or eye mask.",
        "Eat dark chocolate with high cocoa content — supports antioxidants.",
        "Today’s goal: no sugar at all. Focus on clean eating.",
        "Journal for 5 minutes before bed — lower cortisol = better sperm.",
        "No alcohol, no screens after 8pm — discipline wins.",
        "Do deep breathing: 4 seconds in, 4 out. Repeat 10 times.",
        "Text your partner something loving — connection supports health, too."
    ]
}

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
    }
}
