import SwiftUI

struct ChallengeView: View {
    let startDate: Date
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var authManager: AuthManager
    @State private var currentDay: Int
    @State private var showCompletionAlert = false
    @Environment(\.dismiss) private var dismiss

    init(startDate: Date) {
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
            testStore.initializeDayIfNeeded(day: currentDay)
            print("ChallengeView loaded with currentDay: \(currentDay)")
        }
        .alert("Day \(currentDay) Complete!", isPresented: $showCompletionAlert) {
            Button("Awesome!") { }
        } message: {
            Text("You're building momentum. Keep going!")
        }
    }

    // MARK: - Daily Dashboard
    @ViewBuilder
    private func dailyDashboard() -> some View {
        if let dayProgress = testStore.challengeProgress?.days[currentDay] {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 16)

                    // MARK: - Streak Header
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        Text("Streak: \(testStore.challengeProgress?.currentStreak ?? 0)")
                            .font(.title2.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // MARK: - Day Title
                    Text("Day \(currentDay)/74")
                        .font(.title.bold())
                        .frame(maxWidth: .infinity, alignment: .center)

                    // MARK: - FHI Progress
                    ProgressView(value: Double(testStore.challengeProgress?.fhi ?? 0), total: 100)
                        .progressViewStyle(.linear)
                        .tint(.green)
                        .padding(.horizontal)

                    // MARK: - Tasks
                    ForEach(currentDayTasks(), id: \.id) { task in
                        if let index = ChallengeTasks.allDays
                            .first(where: { $0.dayNumber == currentDay })?
                            .tasks.firstIndex(where: { $0.id == task.id }) {
                            
                            let isCompleted = dayProgress.tasks[index].completed
                            let isDayCompleted = testStore.challengeProgress?.days[currentDay]?.completed == true

                            HStack(alignment: .top, spacing: 12) {
                                Button(action: {
                                    guard !isDayCompleted else { return }
                                    toggleTask(index: index)
                                }) {
                                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(isCompleted ? .green : .gray)
                                        .font(.title2)
                                }
                                .disabled(isDayCompleted)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(task.category)
                                        .font(.caption.bold())
                                        .foregroundColor(categoryColor(task.category))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(categoryColor(task.category).opacity(0.2))
                                        .cornerRadius(6)

                                    Text(task.task)
                                        .font(.body)
                                        .strikethrough(isCompleted)
                                        .foregroundColor(isCompleted ? .secondary : .primary)

                                    Text(task.tip)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .opacity(isDayCompleted ? 0.7 : 1.0)
                        }
                    }

                    // MARK: - Mood & Energy
                    VStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Mood: \(dayProgress.mood ?? 5)/10")
                                .font(.body)
                            Slider(value: Binding(
                                get: { Double(dayProgress.mood ?? 5) },
                                set: { testStore.challengeProgress?.days[currentDay]?.mood = Int($0) }
                            ), in: 0...10, step: 1)
                            .tint(.green)
                        }

                        VStack(alignment: .leading) {
                            Text("Energy: \(dayProgress.energy ?? 5)/10")
                                .font(.body)
                            Slider(value: Binding(
                                get: { Double(dayProgress.energy ?? 5) },
                                set: { testStore.challengeProgress?.days[currentDay]?.energy = Int($0) }
                            ), in: 0...10, step: 1)
                            .tint(.green)
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - Complete Day Button
                    if allTasksCompleted() && !(testStore.challengeProgress?.days[currentDay]?.completed == true) {
                        Button(action: completeCurrentDay) {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.title2)
                                Text("Complete Day \(currentDay)")
                                    .font(.title3.bold())
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - Day Complete Badge
                    if testStore.challengeProgress?.days[currentDay]?.completed == true {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                            Text("Day \(currentDay) Complete!")
                                .font(.title3.bold())
                                .foregroundColor(.green)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 32)
                }
                .padding()
            }
            .ignoresSafeArea(edges: .bottom)
        } else {
            Text("Loading day \(currentDay)...")
        }
    }

    // MARK: - Helpers
    private func currentDayTasks() -> [DailyTask] {
        ChallengeTasks.allDays.first { $0.dayNumber == currentDay }?.tasks ?? []
    }

    private func allTasksCompleted() -> Bool {
        guard let progress = testStore.challengeProgress?.days[currentDay] else { return false }
        return progress.tasks.allSatisfy { $0.completed }
    }

    private func toggleTask(index: Int) {
        guard var progress = testStore.challengeProgress else { return }
        progress.days[currentDay]?.tasks[index].completed.toggle()
        testStore.challengeProgress = progress
        testStore.updateFHI()
        saveProgress()
    }

    private func completeCurrentDay() {
        guard var progress = testStore.challengeProgress else { return }

        // Mark day as completed
        progress.days[currentDay]?.completed = true
        progress.currentStreak += 1
        if progress.currentStreak > progress.bestStreak {
            progress.bestStreak = progress.currentStreak
        }

        testStore.challengeProgress = progress
        testStore.updateFHI()
        saveProgress()

        // Haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        showCompletionAlert = true
    }

    private func saveProgress() {
        if let userId = authManager.currentUserID {
            testStore.saveChallengeProgress(userId: userId) { success in
                if !success {
                    print("ChallengeView: Failed to save progress")
                }
            }
        }
    }

    private func ensureDayExists() {
        guard testStore.challengeProgress != nil else { return }
        if testStore.challengeProgress?.days[currentDay] == nil {
            let tasks = currentDayTasks().map { _ in TestStore.ChallengeTaskProgress(completed: false) }
            testStore.challengeProgress?.days[currentDay] = TestStore.ChallengeDayProgress(
                tasks: tasks,
                mood: 5,
                energy: 5,
                journalEntry: nil,
                completed: false
            )
            saveProgress()
        }
    }

    private func isChallengeCompleted() -> Bool {
        currentDay == 74 && (testStore.challengeProgress?.days[74]?.completed == true)
    }

    private func isWeeklyDashboardDay() -> Bool {
        [7, 14, 21, 28, 35, 42, 49, 56, 63, 70].contains(currentDay)
            && (testStore.challengeProgress?.days[currentDay]?.completed == true)
    }

    private func categoryColor(_ category: String) -> Color {
        switch category {
        case "Nutrition": return .blue
        case "Exercise": return .orange
        case "Sleep": return .purple
        case "Mental Wellness": return .pink
        case "Lifestyle": return .green
        default: return .gray
        }
    }
}

// MARK: - Challenge Completion View
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

// MARK: - Weekly Dashboard View
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
            Button("Continue to Day \(day + 1)") { }
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
