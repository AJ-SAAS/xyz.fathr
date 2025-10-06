import SwiftUI
import FirebaseAuth

class ChallengeStore: ObservableObject {
    @Published var completionStatus: [Int: String] = [:]
    @Published var fhi: Int = 0
    @Published var tasks: [(task: String, tip: String)] = [
        (task: "Track your baseline sperm test result in the app", tip: "Understanding where you start helps track progress over time."),
        (task: "Drink at least 2.5L water", tip: "Hydration is key for semen volume and sperm motility."),
        (task: "Eat 1 serving leafy greens + 1 serving nuts", tip: "Antioxidants support sperm DNA integrity."),
        (task: "Avoid alcohol and processed foods today", tip: "Alcohol and processed sugar damage sperm quality."),
        (task: "20–30 min moderate exercise (walk, bike, gym)", tip: "Exercise improves circulation, hormone balance, and sperm count."),
        (task: "Sleep 7–8 hours tonight", tip: "Poor sleep lowers testosterone and sperm quality."),
        (task: "10-min guided breathing or meditation", tip: "Stress reduction improves sperm motility and overall health.")
        // Add remaining tasks (Days 8–74) later
    ]
    private let testStore: TestStore
    private let userId: String?

    init(testStore: TestStore, userId: String?) {
        self.testStore = testStore
        self.userId = userId
        loadProgress()
    }

    func currentDay(for startDate: Date) -> Int {
        let daysSinceStart = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return min(max(daysSinceStart + 1, 1), 74)
    }

    func markDayCompleted(day: Int) {
        completionStatus[day] = "completed"
        updateFHI()
        saveProgress()
    }

    func markDayMissed(day: Int) {
        completionStatus[day] = "missed"
        updateFHI()
        saveProgress()
    }

    func isDayCompleted(day: Int) -> Bool {
        return completionStatus[day] == "completed"
    }

    private func updateFHI() {
        let completedDays = completionStatus.values.filter { $0 == "completed" }.count
        fhi = min(Int(Double(completedDays) / 74.0 * 100), 100)
    }

    private func saveProgress() {
        guard let userId = userId else {
            print("ChallengeStore: No user ID, cannot save progress")
            return
        }
        testStore.saveChallengeProgress(
            userId: userId,
            startDate: nil, // Only set on first save
            completionStatus: completionStatus,
            fhi: fhi
        ) { success in
            print("ChallengeStore: Save progress \(success ? "succeeded" : "failed")")
        }
    }

    func loadProgress() {
        guard let userId = userId else {
            print("ChallengeStore: No user ID, cannot load progress")
            return
        }
        testStore.fetchChallengeProgress(userId: userId) { progress in
            if let progress = progress {
                DispatchQueue.main.async {
                    self.completionStatus = progress.completionStatus
                    self.fhi = progress.fhi
                    print("ChallengeStore: Loaded progress - completionStatus: \(self.completionStatus), fhi: \(self.fhi)")
                }
            } else {
                print("ChallengeStore: No progress found")
            }
        }
    }
}

struct ChallengeView: View {
    let startDate: Date
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var challengeStore: ChallengeStore
    @State private var currentDay: Int
    @Environment(\.dismiss) private var dismiss

    init(startDate: Date, testStore: TestStore) {
        self.startDate = startDate
        let daysSinceStart = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        self._currentDay = State(initialValue: min(max(daysSinceStart + 1, 1), 74))
        self._challengeStore = StateObject(wrappedValue: ChallengeStore(testStore: testStore, userId: Auth.auth().currentUser?.uid))
    }

    var body: some View {
        NavigationStack {
            VStack {
                if currentDay == 74 && challengeStore.isDayCompleted(day: 74) {
                    ChallengeCompletionView(challengeStore: challengeStore)
                        .environmentObject(testStore)
                } else if [7, 14, 21, 28, 35, 42, 49, 56, 63, 70].contains(currentDay) && challengeStore.isDayCompleted(day: currentDay) {
                    WeeklyDashboardView(day: currentDay, challengeStore: challengeStore)
                } else {
                    TabView(selection: $currentDay) {
                        ForEach(1...min(currentDay, 74), id: \.self) { day in
                            DailyChallengeCardView(
                                day: day,
                                task: challengeStore.tasks[safe: day - 1] ?? (task: "No task available", tip: "Check back later"),
                                completionStatus: challengeStore.completionStatus[day] ?? "none",
                                onComplete: { challengeStore.markDayCompleted(day: day) },
                                onMissed: { challengeStore.markDayMissed(day: day) },
                                fhi: challengeStore.fhi
                            )
                            .tag(day)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    .onChange(of: currentDay) { newValue, _ in
                        if newValue > challengeStore.currentDay(for: startDate) {
                            currentDay = challengeStore.currentDay(for: startDate)
                        }
                    }
                }
            }
            .navigationTitle("74-Day Fertility Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                }
            }
        }
        .onAppear {
            challengeStore.loadProgress()
            print("ChallengeView: Loaded with startDate: \(startDate), currentDay: \(currentDay)")
        }
    }
}

// Array extension to safely access elements
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct DailyChallengeCardView: View {
    let day: Int
    let task: (task: String, tip: String)
    let completionStatus: String
    let onComplete: () -> Void
    let onMissed: () -> Void
    let fhi: Int

    var body: some View {
        VStack(spacing: 20) {
            Text("Day \(day)/74")
                .font(.title)
                .fontDesign(.rounded)
                .fontWeight(.bold)
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                    .frame(width: 100, height: 100)
                Circle()
                    .trim(from: 0, to: CGFloat(day) / 74.0)
                    .stroke(Color.blue, lineWidth: 10)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
            }
            Text(task.task)
                .font(.headline)
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
            Text("Why it Matters: \(task.tip)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            if completionStatus == "none" {
                HStack(spacing: 16) {
                    Button("Completed") {
                        onComplete()
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    Button("Missed") {
                        onMissed()
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
            } else {
                Text(completionStatus == "completed" ? "Completed ✅" : "Missed ❌")
                    .font(.subheadline.bold())
                    .foregroundColor(completionStatus == "completed" ? .green : .red)
            }
            Text("Fertility Habits Index: \(fhi)/100")
                .font(.subheadline)
                .fontDesign(.rounded)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

struct WeeklyDashboardView: View {
    let day: Int
    @ObservedObject var challengeStore: ChallengeStore

    var body: some View {
        VStack(spacing: 20) {
            Text("Week \(day/7) Complete!")
                .font(.title)
                .fontDesign(.rounded)
                .fontWeight(.bold)
            Text("Fertility Habits Index: \(challengeStore.fhi)/100")
                .font(.headline)
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 100)
                .overlay(Text("FHI Trend Graph Placeholder"))
            Text("Top Wins: \(challengeStore.completionStatus.filter { $0.value == "completed" }.count) tasks completed")
                .font(.subheadline)
            Text("Prediction: Your habits could improve sperm motility by ~10–20%. Keep it up!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Button("Continue to Day \(day + 1)") {
                // Handled by parent view
            }
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

struct ChallengeCompletionView: View {
    @ObservedObject var challengeStore: ChallengeStore
    @EnvironmentObject var testStore: TestStore

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .foregroundColor(.yellow)
            Text("Congratulations!")
                .font(.title)
                .fontDesign(.rounded)
                .fontWeight(.bold)
            Text("You completed the 74-Day Fertility Upgrade Challenge!")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("Fertility Habits Index: \(challengeStore.fhi)/100")
                .font(.subheadline)
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 100)
                .overlay(Text("FHI Trend Graph Placeholder"))
            Text("Next Steps:\n1. Upload a new sperm test to compare with your baseline.\n2. Start a Maintenance Challenge!\n3. Track conception with Partner Mode.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
            HStack(spacing: 16) {
                NavigationLink(destination: TestInputView().environmentObject(testStore)) {
                    Text("Upload Test")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                Button("Share Achievement") {
                    // Implement sharing logic
                }
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}
