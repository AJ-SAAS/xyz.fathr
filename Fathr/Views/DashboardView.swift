import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var testStore: TestStore
    @State private var showInput = false
    @AppStorage("lastTipDate") private var lastTipDate: String = ""
    @State private var checkedTips: [Int: Bool] = [:]
    @Binding var selectedTab: Int // Added for tab navigation

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    WelcomeHeaderView(showInput: $showInput)
                    FertilitySnapshotView(selectedTab: $selectedTab)
                    
                    // New Cards: Winning and Improvement
                    if !testStore.tests.isEmpty, let latestTest = testStore.tests.first {
                        let (winningMetrics, improvementMetrics) = evaluateMetrics(for: latestTest)
                        MetricCardView(
                            title: "Where You Are Winning",
                            metrics: winningMetrics,
                            isWinning: true
                        )
                        MetricCardView(
                            title: "Where You Can Improve",
                            metrics: improvementMetrics,
                            isWinning: false
                        )
                    }
                    
                    RecentTestsView()
                    if testStore.tests.count > 0 {
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
            }
            .onAppear {
                updateDailyTips()
            }
            .onChange(of: lastTipDate) {
                updateDailyTips()
            }
        }
    }

    private func evaluateMetrics(for test: TestData) -> ([String], [String]) {
        var winningMetrics: [String] = []
        var improvementMetrics: [String] = []

        // Motility
        let motility = test.totalMobility ?? 0.0
        if motility >= 40 {
            winningMetrics.append("Motility: \(Int(motility))% (Great movement!)")
        } else {
            improvementMetrics.append("Motility: \(Int(motility))% (Aim for ≥ 40%)")
        }

        // Concentration
        let concentration = test.spermConcentration ?? 0.0
        if concentration >= 15 {
            winningMetrics.append("Concentration: \(Int(concentration)) million/mL (Strong count!)")
        } else {
            improvementMetrics.append("Concentration: \(Int(concentration)) million/mL (Aim for ≥ 15 million/mL)")
        }

        // Morphology
        let morphology = test.morphologyRate ?? 0.0
        if morphology >= 4 {
            winningMetrics.append("Morphology: \(Int(morphology))% normal forms (Solid structure!)")
        } else {
            improvementMetrics.append("Morphology: \(Int(morphology))% normal forms (Aim for ≥ 4%)")
        }

        // Sperm Analysis
        let analysisScore = mapAnalysisStatusToScore(test.analysisStatus)
        if analysisScore >= 80 {
            winningMetrics.append("Sperm Analysis: Typical (Excellent overall health!)")
        } else {
            improvementMetrics.append("Sperm Analysis: \(test.analysisStatus) (Consult a specialist)")
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

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    private struct Averages {
        let overallScore: Int
        let motility: Int
        let concentration: Int
        let morphology: Int
        let dnaFragmentation: Int?
        let spermAnalysis: Int
    }

    private func calculateAverages() -> Averages {
        let count = testStore.tests.count
        guard count > 0 else {
            return Averages(overallScore: 0, motility: 0, concentration: 0, morphology: 0, dnaFragmentation: nil, spermAnalysis: 0)
        }
        
        let totalMotility = testStore.tests.reduce(0) { $0 + Int($1.totalMobility ?? 0.0) }
        let totalConcentration = testStore.tests.reduce(0) { $0 + Int(($1.spermConcentration ?? 0.0) / 100 * 100) }
        let totalMorphology = testStore.tests.reduce(0) { $0 + Int($1.morphologyRate ?? 0.0) }
        
        let dnaScores = testStore.tests.map { test in
            test.dnaFragmentationRisk.map { Int(100 - Double($0)) } ?? 80
        }
        let totalDnaFragmentation = dnaScores.reduce(0, +)
        
        let totalSpermAnalysis = testStore.tests.reduce(0) { $0 + mapAnalysisStatusToScore($1.analysisStatus) }
        
        let avgMotility = totalMotility / count
        let avgConcentration = totalConcentration / count
        let avgMorphology = totalMorphology / count
        let avgDnaFragmentation = totalDnaFragmentation / count
        let avgSpermAnalysis = totalSpermAnalysis / count
        
        let scores = [avgMotility, avgConcentration, avgMorphology, avgDnaFragmentation, avgSpermAnalysis]
        let overallScore = scores.reduce(0, +) / scores.count
        
        return Averages(
            overallScore: overallScore,
            motility: avgMotility,
            concentration: avgConcentration,
            morphology: avgMorphology,
            dnaFragmentation: avgDnaFragmentation,
            spermAnalysis: avgSpermAnalysis
        )
    }

    private func calculateTrend() -> TrackView.Trend {
        guard testStore.tests.count > 1 else { return .none }
        
        let latestTest = testStore.tests[0]
        let motilityScore = Int(latestTest.totalMobility ?? 0.0)
        let concentrationScore = Int((latestTest.spermConcentration ?? 0.0) / 100 * 100)
        let morphologyScore = Int(latestTest.morphologyRate ?? 0.0)
        let dnaScore = latestTest.dnaFragmentationRisk.map { Int(100 - Double($0)) } ?? 80
        let analysisScore = mapAnalysisStatusToScore(latestTest.analysisStatus)
        
        let currentScores = [
            motilityScore,
            concentrationScore,
            morphologyScore,
            dnaScore,
            analysisScore
        ]
        let currentOverall = currentScores.reduce(0, +) / currentScores.count
        
        let previousTests = Array(testStore.tests.dropFirst())
        let prevCount = previousTests.count
        
        let totalMotility = previousTests.reduce(0) { $0 + Int($1.totalMobility ?? 0.0) }
        let totalConcentration = previousTests.reduce(0) { $0 + Int(($1.spermConcentration ?? 0.0) / 100 * 100) }
        let totalMorphology = previousTests.reduce(0) { $0 + Int($1.morphologyRate ?? 0.0) }
        let totalDna = previousTests.reduce(0) { $0 + ($1.dnaFragmentationRisk.map { Int(100 - Double($0)) } ?? 80) }
        let totalAnalysis = previousTests.reduce(0) { $0 + mapAnalysisStatusToScore($1.analysisStatus) }
        
        let previousOverall = (totalMotility + totalConcentration + totalMorphology + totalDna + totalAnalysis) / (prevCount * 5)
        
        if currentOverall > previousOverall { return .up }
        if currentOverall < previousOverall { return .down }
        return .none
    }

    private func mapAnalysisStatusToScore(_ status: String) -> Int {
        switch status.lowercased() {
        case "typical": return 80
        case "atypical": return 40
        default: return 50
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
    @Binding var selectedTab: Int

    var body: some View {
        if !testStore.tests.isEmpty {
            let averages = calculateAverages()
            let trend = calculateTrend()
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Fathr Score")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .foregroundColor(.black)
                    OverallScoreCard(
                        overallScore: averages.overallScore,
                        trend: trend
                    )
                    .frame(maxWidth: .infinity, maxHeight: 160)
                }
                .frame(maxWidth: .infinity)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Fertility Snapshot")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .foregroundColor(.black)
                    Button(action: {
                        selectedTab = 1
                    }) {
                        Text("View Full Report >")
                            .font(.subheadline.bold())
                            .fontDesign(.rounded)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .accessibilityLabel("View Full Report")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: .gray.opacity(0.1), radius: 5)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
        }
    }

    private struct Averages {
        let overallScore: Int
        let motility: Int
        let concentration: Int
        let morphology: Int
        let dnaFragmentation: Int?
        let spermAnalysis: Int
    }

    private func calculateAverages() -> Averages {
        let count = testStore.tests.count
        guard count > 0 else {
            return Averages(overallScore: 0, motility: 0, concentration: 0, morphology: 0, dnaFragmentation: nil, spermAnalysis: 0)
        }

        let totalMotility = testStore.tests.reduce(0) { $0 + Int($1.totalMobility ?? 0.0) }
        let totalConcentration = testStore.tests.reduce(0) { $0 + Int(($1.spermConcentration ?? 0.0) / 100 * 100) }
        let totalMorphology = testStore.tests.reduce(0) { $0 + Int($1.morphologyRate ?? 0.0) }

        let dnaScores = testStore.tests.map { test in
            test.dnaFragmentationRisk.map { Int(100 - Double($0)) } ?? 80
        }
        let totalDnaFragmentation = dnaScores.reduce(0, +)

        let totalSpermAnalysis = testStore.tests.reduce(0) { $0 + mapAnalysisStatusToScore($1.analysisStatus) }

        let avgMotility = totalMotility / count
        let avgConcentration = totalConcentration / count
        let avgMorphology = totalMorphology / count
        let avgDnaFragmentation = totalDnaFragmentation / count
        let avgSpermAnalysis = totalSpermAnalysis / count

        let scores = [avgMotility, avgConcentration, avgMorphology, avgDnaFragmentation, avgSpermAnalysis]
        let overallScore = scores.reduce(0, +) / scores.count

        return Averages(
            overallScore: overallScore,
            motility: avgMotility,
            concentration: avgConcentration,
            morphology: avgMorphology,
            dnaFragmentation: avgDnaFragmentation,
            spermAnalysis: avgSpermAnalysis
        )
    }

    private func calculateTrend() -> TrackView.Trend {
        guard testStore.tests.count > 1 else { return .none }

        let latestTest = testStore.tests[0]
        let motilityScore = Int(latestTest.totalMobility ?? 0.0)
        let concentrationScore = Int((latestTest.spermConcentration ?? 0.0) / 100 * 100)
        let morphologyScore = Int(latestTest.morphologyRate ?? 0.0)
        let dnaScore = latestTest.dnaFragmentationRisk.map { Int(100 - Double($0)) } ?? 80
        let analysisScore = mapAnalysisStatusToScore(latestTest.analysisStatus)
        
        let currentScores = [
            motilityScore,
            concentrationScore,
            morphologyScore,
            dnaScore,
            analysisScore
        ]
        let currentOverall = currentScores.reduce(0, +) / currentScores.count

        let previousTests = Array(testStore.tests.dropFirst())
        let prevCount = previousTests.count

        let totalMotility = previousTests.reduce(0) { $0 + Int($1.totalMobility ?? 0.0) }
        let totalConcentration = previousTests.reduce(0) { $0 + Int(($1.spermConcentration ?? 0.0) / 100 * 100) }
        let totalMorphology = previousTests.reduce(0) { $0 + Int($1.morphologyRate ?? 0.0) }
        let totalDna = previousTests.reduce(0) { $0 + ($1.dnaFragmentationRisk.map { Int(100 - Double($0)) } ?? 80) }
        let totalAnalysis = previousTests.reduce(0) { $0 + mapAnalysisStatusToScore($1.analysisStatus) }

        let previousOverall = (totalMotility + totalConcentration + totalMorphology + totalDna + totalAnalysis) / (prevCount * 5)

        if currentOverall > previousOverall { return .up }
        if currentOverall < previousOverall { return .down }
        return .none
    }

    private func mapAnalysisStatusToScore(_ status: String) -> Int {
        switch status.lowercased() {
        case "typical": return 80
        case "atypical": return 40
        default: return 50
        }
    }
}

struct RecentTestsView: View {
    @EnvironmentObject var testStore: TestStore

    var body: some View {
        Text("Recent Tests")
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
            ForEach(testStore.tests.prefix(3)) { test in
                NavigationLink(destination: ResultsView(test: test)) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(test.dateFormatted)
                                .font(.headline)
                                .fontDesign(.rounded)
                                .foregroundColor(.black)
                            Text("• \(test.overallStatus)")
                                .font(.subheadline)
                                .fontDesign(.rounded)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                .padding(.horizontal)
            }
        }
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
        DashboardView(selectedTab: .constant(0))
            .environmentObject(TestStore())
    }
}
