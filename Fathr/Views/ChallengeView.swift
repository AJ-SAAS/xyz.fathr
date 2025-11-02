import SwiftUI
import FirebaseAuth

struct ChallengeView: View {
    let startDate: Date
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var authManager: AuthManager
    @State private var currentDay: Int
    @Environment(\.dismiss) private var dismiss
    @State private var journalText: String = "" // Temporary state for journal input
    @State private var isJournalSubmitted: Bool = false // Tracks if journal is submitted

    // Define daily tasks aligned with Core Rules
    private let dailyTasks: [(category: String, task: String, tip: String)] = [
        // Nutrition
        (category: "Nutrition", task: "Drink 3L of water", tip: "Hydration supports semen volume and optimal testicular function, key for sperm production."),
        (category: "Nutrition", task: "Eat 1 cup of spinach or kale", tip: "Leafy greens provide folate, supporting healthy sperm DNA and reducing abnormalities."),
        // Supplements
        (category: "Supplements", task: "Take a zinc supplement (15–30mg)", tip: "Zinc is critical for sperm motility and testosterone production."),
        // Heat Avoidance
        (category: "Heat Avoidance", task: "Wear loose underwear today", tip: "Loose clothing keeps testes cooler, optimizing sperm production."),
        // Exercise
        (category: "Exercise", task: "Do 45 min of exercise (e.g., walk, gym)", tip: "Moderate exercise boosts testosterone and blood flow, enhancing sperm quality."),
        // Sleep & Recovery
        (category: "Sleep", task: "Sleep 7–8 hours tonight", tip: "Quality sleep regulates testosterone, crucial for the 74-day sperm renewal cycle."),
        // Mental & Sexual Discipline
        (category: "Mental Discipline", task: "Write a journal entry (below)", tip: "Journaling reduces stress, lowering cortisol that can harm sperm health.")
    ]

    init(startDate: Date, testStore: TestStore) {
        self.startDate = startDate
        let daysSinceStart = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        self._currentDay = State(initialValue: min(max(daysSinceStart + 1, 1), 74))
    }

    var body: some View {
        NavigationStack {
            VStack {
                if isChallengeCompleted() {
                    ChallengeCompletionView()
                        .environmentObject(testStore)
                } else if isWeeklyDashboardDay() {
                    WeeklyDashboardView(day: currentDay)
                        .environmentObject(testStore)
                } else {
                    dailyDashboard()
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
            print("ChallengeView loaded with currentDay: \(currentDay)")
            // Load existing journal entry for the current day
            if let dayProgress = testStore.challengeProgress?.days[currentDay] {
                journalText = dayProgress.journalEntry ?? ""
                isJournalSubmitted = dayProgress.journalEntry != nil
            }
        }
    }

    // MARK: - Daily Dashboard
    @ViewBuilder
    private func dailyDashboard() -> some View {
        if let dayProgress = testStore.challengeProgress?.days[currentDay] {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Day \(currentDay)/74")
                        .font(.title.bold())

                    ProgressView(value: Double(testStore.challengeProgress?.fhi ?? 0), total: 100)
                        .progressViewStyle(.linear)
                        .tint(.green)
                        .padding(.horizontal)

                    ForEach(dailyTasks.indices, id: \.self) { index in
                        HStack(alignment: .top, spacing: 12) {
                            Button(action: {
                                toggleTask(index: index)
                            }) {
                                Image(systemName: dayProgress.tasks[index].completed ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(dayProgress.tasks[index].completed ? .green : .gray)
                                    .font(.title2)
                            }
                            .accessibilityLabel(dayProgress.tasks[index].completed ? "Unmark task" : "Mark task as completed")

                            VStack(alignment: .leading, spacing: 4) {
                                Text(dailyTasks[index].category)
                                    .font(.caption.bold())
                                    .foregroundColor(.secondary)
                                Text(dailyTasks[index].task)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text(dailyTasks[index].tip)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }

                    VStack(spacing: 10) {
                        VStack {
                            Text("Mood: \(dayProgress.mood ?? 5)/10")
                                .font(.body)
                            Slider(value: Binding(
                                get: { Double(dayProgress.mood ?? 5) },
                                set: { testStore.challengeProgress?.days[currentDay]?.mood = Int($0) }
                            ), in: 0...10, step: 1)
                            .tint(.green)
                        }

                        VStack {
                            Text("Energy: \(dayProgress.energy ?? 5)/10")
                                .font(.body)
                            Slider(value: Binding(
                                get: { Double(dayProgress.energy ?? 5) },
                                set: { testStore.challengeProgress?.days[currentDay]?.energy = Int($0) }
                            ), in: 0...10, step: 1)
                            .tint(.green)
                        }

                        VStack(spacing: 8) {
                            Text("Journal Entry")
                                .font(.body.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            ZStack(alignment: .topLeading) {
                                if journalText.isEmpty && !isJournalSubmitted {
                                    Text("Today I invested in my future family by…")
                                        .font(.body)
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 5)
                                }
                                TextEditor(text: $journalText)
                                    .frame(height: 100)
                                    .padding(4)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal)

                            Button(action: {
                                submitJournal()
                            }) {
                                Text(isJournalSubmitted ? "Journal Submitted" : "Submit Journal")
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isJournalSubmitted ? Color.gray : Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .disabled(isJournalSubmitted)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .padding()
            }
        } else {
            Text("Loading day \(currentDay)...")
        }
    }

    private func toggleTask(index: Int) {
        guard var dayProgress = testStore.challengeProgress?.days[currentDay] else { return }
        dayProgress.tasks[index].completed.toggle()
        testStore.challengeProgress?.days[currentDay] = dayProgress
        testStore.updateFHI()
        if let userId = authManager.currentUserID {
            testStore.saveChallengeProgress(userId: userId) { success in
                if !success {
                    print("ChallengeView: Failed to save progress")
                }
            }
        }
    }

    private func submitJournal() {
        guard var dayProgress = testStore.challengeProgress?.days[currentDay] else { return }
        dayProgress.journalEntry = journalText.isEmpty ? nil : journalText
        testStore.challengeProgress?.days[currentDay] = dayProgress
        if let userId = authManager.currentUserID {
            testStore.saveChallengeProgress(userId: userId) { success in
                DispatchQueue.main.async {
                    if success {
                        print("ChallengeView: Journal saved successfully")
                        isJournalSubmitted = true
                    } else {
                        print("ChallengeView: Failed to save journal")
                    }
                }
            }
        }
    }

    private func isChallengeCompleted() -> Bool {
        return currentDay == 74 && (testStore.challengeProgress?.days[74]?.tasks.allSatisfy { $0.completed } ?? false)
    }

    private func isWeeklyDashboardDay() -> Bool {
        return [7, 14, 21, 28, 35, 42, 49, 56, 63, 70].contains(currentDay)
            && (testStore.challengeProgress?.days[currentDay]?.tasks.allSatisfy { $0.completed } ?? false)
    }
}

// MARK: - Placeholder Views

struct ChallengeCompletionView: View {
    @EnvironmentObject var testStore: TestStore
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .foregroundColor(.yellow)
            Text("Challenge Completed!")
                .font(.title.bold())
            Text("Congratulations on completing the 74-Day Fertility Challenge!")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("Fertility Habits Index: \(testStore.challengeProgress?.fhi ?? 0)/100")
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
                        .background(Color.green)
                        .cornerRadius(10)
                }
                Button("Share Achievement") {
                    // TODO: Implement sharing logic
                }
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
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

struct WeeklyDashboardView: View {
    @EnvironmentObject var testStore: TestStore
    let day: Int
    var body: some View {
        VStack(spacing: 20) {
            Text("Week \(day/7) Complete!")
                .font(.title.bold())
            Text("Fertility Habits Index: \(testStore.challengeProgress?.fhi ?? 0)/100")
                .font(.headline)
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 100)
                .overlay(Text("FHI Trend Graph Placeholder"))
            Text("Top Wins: \(testStore.challengeProgress?.days.values.flatMap { $0.tasks }.filter { $0.completed }.count ?? 0) tasks completed")
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
            .background(Color.green)
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}
