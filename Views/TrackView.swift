import SwiftUI

struct TrackView: View {
    @EnvironmentObject var testStore: TestStore
    @State private var showInput = false
    
    // Nested Trend enum
    enum Trend {
        case up, down, none
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                TrackContentView(showInput: $showInput)
            }
            .background(Color.white)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Track")
                        .font(.title.bold())
                        .fontDesign(.rounded)
                        .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
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
            }
            .sheet(isPresented: $showInput) {
                TestInputView()
                    .environmentObject(testStore)
            }
        }
    }
}

struct TrackContentView: View {
    @EnvironmentObject var testStore: TestStore
    @Binding var showInput: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if testStore.tests.isEmpty {
                Text("No test results yet.")
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundColor(.gray)
            } else {
                TestResultsView()
            }
            
            Text("Visualizations are based on WHO 6th Edition standards for informational purposes only. Fathr is not a medical device. Consult a doctor for fertility concerns.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top)
        }
        .padding(.horizontal)
        .padding(.top, 0)
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
        
        let scores: [Int] = [
            avgMotility,
            avgConcentration,
            avgMorphology,
            avgDnaFragmentation,
            avgSpermAnalysis
        ]
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
        let currentScores: [Int] = [
            Int(latestTest.totalMobility ?? 0.0),
            Int((latestTest.spermConcentration ?? 0.0) / 100 * 100),
            Int(latestTest.morphologyRate ?? 0.0),
            latestTest.dnaFragmentationRisk.map { Int(100 - Double($0)) } ?? 80,
            mapAnalysisStatusToScore(latestTest.analysisStatus)
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

struct TestResultsView: View {
    @EnvironmentObject var testStore: TestStore
    
    var body: some View {
        let averages = calculateAverages()
        let trend = calculateTrend()
        
        OverallScoreCard(
            overallScore: averages.overallScore,
            trend: trend
        )
        
        FertilityStatusView(
            motility: averages.motility,
            concentration: averages.concentration,
            morphology: averages.morphology,
            dnaFragmentation: averages.dnaFragmentation,
            spermAnalysis: averages.spermAnalysis
        )
        
        if testStore.tests.count > 1 {
            NavigationLink(destination: PastResultsView()) {
                Text("View Past Results")
                    .font(.headline.bold())
                    .fontDesign(.rounded)
                    .foregroundColor(.black)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.teal.opacity(0.1))
                    .cornerRadius(15)
            }
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
        
        let scores: [Int] = [
            avgMotility,
            avgConcentration,
            avgMorphology,
            avgDnaFragmentation,
            avgSpermAnalysis
        ]
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
        let currentScores: [Int] = [
            Int(latestTest.totalMobility ?? 0.0),
            Int((latestTest.spermConcentration ?? 0.0) / 100 * 100),
            Int(latestTest.morphologyRate ?? 0.0),
            latestTest.dnaFragmentationRisk.map { Int(100 - Double($0)) } ?? 80,
            mapAnalysisStatusToScore(latestTest.analysisStatus)
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

// Overall Score Card with 3/4 Circular Gauge
struct OverallScoreCard: View {
    let overallScore: Int
    let trend: TrackView.Trend
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .trim(from: 0.5833, to: 0.4167)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(90))
                
                Circle()
                    .trim(from: 0.5833 - (0.75 * CGFloat(overallScore) / 100), to: 0.5833)
                    .stroke(
                        LinearGradient(
                            colors: scoreGradient(),
                            startPoint: .bottomTrailing,
                            endPoint: .bottomLeading
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(90))
                    .animation(.easeInOut(duration: 0.5), value: overallScore)
                
                VStack(spacing: 4) {
                    Text("\(overallScore)")
                        .font(.system(size: 48, weight: .bold))
                        .fontDesign(.rounded)
                        .foregroundColor(.black)
                    
                    Text(overallScoreReference(score: overallScore))
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Overall score: \(overallScore) out of 100, \(overallScoreReference(score: overallScore))")
        }
        .padding()
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
    
    private func overallScoreReference(score: Int) -> String {
        switch score {
        case 80...100:
            return "Higher Range"
        case 60..<80:
            return "Moderate Range"
        default:
            return "Lower Range"
        }
    }
    
    private func scoreGradient() -> [Color] {
        return [
            Color.green,
            Color.green.opacity(0.8)
        ]
    }
}

// Fertility Status Section (No Dropdown)
struct FertilityStatusView: View {
    let motility: Int
    let concentration: Int
    let morphology: Int
    let dnaFragmentation: Int?
    let spermAnalysis: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fertility Status")
                .font(.title3.bold())
                .fontDesign(.rounded)
                .foregroundColor(.black)
            
            CategoryRow(label: "Sperm Quality", score: spermAnalysis)
            CategoryRow(label: "Motility", score: motility)
            CategoryRow(label: "Concentration", score: concentration)
            CategoryRow(label: "Morphology", score: morphology)
            if let dnaFrag = dnaFragmentation {
                CategoryRow(label: "DNA Fragmentation", score: dnaFrag)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

// Category Row for Fertility Status
struct CategoryRow: View {
    let label: String
    let score: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 12) {
                Text(label)
                    .font(.headline.bold())
                    .fontDesign(.rounded)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(score)")
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundColor(.gray)
            }
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                GeometryReader { geometry in
                    Capsule()
                        .fill(scoreGradient(score: score))
                        .frame(width: max(geometry.size.width * CGFloat(score) / 100, 2), height: 8)
                        .animation(.easeOut(duration: 0.5), value: score)
                }
            }
            .frame(height: 8)
            
            Text(scoreFeedback(score: score))
                .font(.caption)
                .fontDesign(.rounded)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
        .accessibilityLabel("\(label): \(score) out of 100, \(scoreFeedback(score: score))")
    }
    
    func scoreGradient(score: Int) -> LinearGradient {
        if score >= 80 {
            return LinearGradient(colors: [Color.teal, Color.teal.opacity(0.8)],
                                  startPoint: .leading, endPoint: .trailing)
        } else if score >= 60 {
            return LinearGradient(colors: [Color.yellow, Color.orange],
                                  startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [Color.red, Color.orange],
                                  startPoint: .leading, endPoint: .trailing)
        }
    }
    
    func scoreFeedback(score: Int) -> String {
        switch score {
        case 80...100:
            return "Higher Range"
        case 60..<80:
            return "Moderate Range"
        default:
            return "Lower Range"
        }
    }
}

struct PastResultsView: View {
    @EnvironmentObject var testStore: TestStore
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Past Results")
                    .font(.title.bold())
                    .fontDesign(.rounded)
                    .foregroundColor(.black)
                
                ForEach(testStore.tests, id: \.id) { test in
                    TestResultRow(test: test)
                }
                
                Text("Fathr is not a medical device. Visualizations are for informational purposes only. Consult a doctor for fertility concerns.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }
            .padding()
        }
        .background(Color.white)
        .navigationTitle("Past Results")
    }
}

// New view to simplify PastResultsView
struct TestResultRow: View {
    let test: TestData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(test.dateFormatted)
                .font(.headline)
                .fontDesign(.rounded)
                .foregroundColor(.black)
            
            let (score, label) = calculateOverallScore(test: test)
            Text("Overall Score: \(score) – \(label)")
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundColor(.gray)
            
            CategoryRow(label: "Sperm Quality", score: mapAnalysisStatusToScore(test.analysisStatus))
            CategoryRow(label: "Motility", score: Int(test.totalMobility ?? 0.0))
            CategoryRow(label: "Concentration", score: Int((test.spermConcentration ?? 0.0) / 100 * 100))
            CategoryRow(label: "Morphology", score: Int(test.morphologyRate ?? 0.0))
            if let dnaFrag = test.dnaFragmentationRisk {
                CategoryRow(label: "DNA Fragmentation", score: Int(100 - Double(dnaFrag)))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
    
    private func calculateOverallScore(test: TestData) -> (Int, String) {
        let motilityScore = min(Int(test.totalMobility ?? 0.0), 100)
        let concentrationScore = min(Int((test.spermConcentration ?? 0.0) / 100 * 100), 100)
        let morphologyScore = min(Int(test.morphologyRate ?? 0.0), 100)
        let dnaScore = test.dnaFragmentationRisk.map { min(Int(100 - Double($0)), 100) } ?? 80
        let analysisScore = mapAnalysisStatusToScore(test.analysisStatus)
        
        let scores = [motilityScore, concentrationScore, morphologyScore, dnaScore, analysisScore]
        let average = scores.reduce(0, +) / scores.count
        
        let label: String
        switch average {
        case 0..<50: label = "Lower Range"
        case 50..<70: label = "Moderate Range"
        case 70..<85: label = "Higher Range"
        case 85...100: label = "Upper Range"
        default: label = "Moderate Range"
        }
        
        return (average, label)
    }
    
    private func mapAnalysisStatusToScore(_ status: String) -> Int {
        switch status.lowercased() {
        case "typical": return 80
        case "atypical": return 40
        default: return 50
        }
    }
}

private func scoreColor(score: Int) -> Color {
    switch score {
    case 0..<50: return .red
    case 50..<70: return .orange
    case 70..<85: return .yellow
    case 85...100: return .teal
    default: return .black
    }
}

extension TestData {
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct TrackView_Previews: PreviewProvider {
    static var previews: some View {
        TrackView()
            .environmentObject(TestStore())
    }
}
