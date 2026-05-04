import SwiftUI

struct ChallengeView: View {

    // MARK: - Init
    let startDate: Date

    init(startDate: Date) {
        self.startDate = startDate
        let elapsed = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        self._selectedDay = State(initialValue: min(max(elapsed + 1, 1), 74))
    }

    // MARK: - State
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var authManager: AuthManager
    @State private var completedTasks: Set<UUID> = []
    @State private var selectedDay: Int
    @State private var showCompleteAlert = false

    // MARK: - Current Day (safe lookup)
    private var currentDay: ChallengeDay {
        ChallengeTasks.allDays.first(where: { $0.dayNumber == selectedDay }) ?? ChallengeTasks.allDays[0]
    }

    // MARK: - XP
    private var totalXP: Int {
        ChallengeTasks.allDays.reduce(0) { result, day in
            result + day.tasks.reduce(0) { sum, task in
                completedTasks.contains(task.id)
                    ? sum + task.xp(forDay: day.dayNumber)
                    : sum
            }
        }
    }

    // MARK: - Level
    private var level: TransformationLevel {
        TransformationLevel.forXP(totalXP)
    }

    // MARK: - Progress to next level
    private var progressToNext: Double {
        guard let next = level.xpToNext else { return 1.0 }
        let prevXP = level.xpThreshold
        let range = next - prevXP
        guard range > 0 else { return 1.0 }
        return min(Double(totalXP - prevXP) / Double(range), 1.0)
    }

    // MARK: - All tasks for today done?
    private var allTasksDone: Bool {
        currentDay.tasks.allSatisfy { completedTasks.contains($0.id) }
    }

    var body: some View {
        ZStack {
            Color.fathrSurface.ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
                VStack(spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(greetingText())
                                .font(.system(size: 12))
                                .foregroundColor(.fathrMuted)
                            Text("Day \(selectedDay) · \(currentDay.phase.name)")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.fathrDark)
                        }
                        Spacer()
                        // XP pill
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(red: 0.165, green: 0.290, blue: 0.000))
                            Text("\(totalXP) XP")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(red: 0.165, green: 0.290, blue: 0.000))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.fathrLime)
                        .cornerRadius(20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // MARK: Mountain view
                // ✅ Uses actual MountainIllustrationView(day:) signature
                MountainIllustrationView(day: selectedDay)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                // MARK: Level card
                HStack(spacing: 12) {
                    Text("LV \(level.rawValue + 1)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.165, green: 0.290, blue: 0.000))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.fathrLime)
                        .cornerRadius(6)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(level.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(height: 4)
                                Capsule()
                                    .fill(Color.fathrLime)
                                    .frame(width: geo.size.width * progressToNext, height: 4)
                            }
                        }
                        .frame(height: 4)
                    }

                    Spacer()

                    if let next = level.xpToNext {
                        Text("\(next - totalXP) to next")
                            .font(.system(size: 11))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.fathrDark)
                .cornerRadius(14)
                .padding(.horizontal, 20)
                .padding(.bottom, 14)

                // MARK: Quests header
                HStack {
                    Text("Daily quests")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.fathrDark)
                    Spacer()
                    let done = currentDay.tasks.filter { completedTasks.contains($0.id) }.count
                    Text("\(done)/\(currentDay.tasks.count)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(red: 0.165, green: 0.290, blue: 0.000))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.fathrLime)
                        .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)

                // MARK: Task list
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(currentDay.tasks) { task in
                            TaskRow(
                                task: task,
                                day: selectedDay,
                                isCompleted: completedTasks.contains(task.id),
                                toggle: {
                                    if completedTasks.contains(task.id) {
                                        completedTasks.remove(task.id)
                                    } else {
                                        completedTasks.insert(task.id)
                                    }
                                }
                            )
                        }

                        // Complete day button
                        if allTasksDone {
                            Button(action: completeDay) {
                                HStack(spacing: 8) {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 13))
                                    Text("Complete Day \(selectedDay)")
                                        .font(.system(size: 15, weight: .semibold))
                                    let xp = currentDay.tasks.reduce(0) { $0 + $1.xp(forDay: selectedDay) }
                                    Text("· +\(xp) XP")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(Color(red: 0.165, green: 0.290, blue: 0.000))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.fathrLime)
                                .cornerRadius(14)
                            }
                            .padding(.top, 4)
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                }

                // MARK: Day Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(1...74, id: \.self) { day in
                            Button {
                                selectedDay = day
                            } label: {
                                Text("\(day)")
                                    .font(.system(size: 11, weight: selectedDay == day ? .semibold : .regular))
                                    .frame(width: 32, height: 32)
                                    .background(selectedDay == day ? Color.fathrGreen : Color.white)
                                    .foregroundColor(selectedDay == day ? .white : .fathrMuted)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.fathrBorder, lineWidth: 0.5)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                .background(Color.white)
                .overlay(Divider(), alignment: .top)
            }
        }
        .navigationBarHidden(true)
        .alert("Day \(selectedDay) complete! ⚡", isPresented: $showCompleteAlert) {
            Button("Let's go!") { }
        } message: {
            let xp = currentDay.tasks.reduce(0) { $0 + $1.xp(forDay: selectedDay) }
            Text("You earned \(xp) XP. Keep building.")
        }
    }

    // MARK: - Actions
    private func completeDay() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        showCompleteAlert = true
        saveProgress()
    }

    private func saveProgress() {
        guard let userId = authManager.currentUserID else { return }
        testStore.saveChallengeProgress(userId: userId) { _ in }
    }

    private func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default:     return "Good evening"
        }
    }
}

// MARK: - Task Row
struct TaskRow: View {
    let task: DailyTask
    let day: Int
    let isCompleted: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack(spacing: 12) {
                // Category icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(categoryBg)
                        .frame(width: 36, height: 36)
                    Image(systemName: categoryIcon)
                        .font(.system(size: 14))
                        .foregroundColor(categoryColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(task.category.uppercased())
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(categoryColor)
                            .tracking(0.8)
                        Spacer()
                        Text("+\(task.xp(forDay: day)) XP")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(isCompleted ? .fathrGreen : .fathrMuted)
                    }
                    Text(task.task)
                        .font(.system(size: 13))
                        .foregroundColor(isCompleted ? .fathrMuted : .fathrDark)
                        .strikethrough(isCompleted, color: .fathrMuted)
                        .lineSpacing(2)
                    if !isCompleted {
                        Text(task.tip)
                            .font(.system(size: 11))
                            .foregroundColor(.fathrMuted)
                            .lineSpacing(2)
                    }
                }

                // Check circle
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.fathrGreen : Color.clear)
                        .frame(width: 24, height: 24)
                    Circle()
                        .stroke(isCompleted ? Color.fathrGreen : Color.fathrBorder, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCompleted ? Color.fathrGreen.opacity(0.3) : Color.fathrBorder, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var categoryBg: Color {
        switch task.category {
        case "Nutrition":       return Color(red: 0.902, green: 0.945, blue: 0.984)
        case "Exercise":        return Color(red: 0.980, green: 0.929, blue: 0.855)
        case "Sleep":           return Color(red: 0.933, green: 0.929, blue: 0.996)
        case "Mental Wellness": return Color(red: 0.984, green: 0.918, blue: 0.941)
        case "Lifestyle":       return Color(red: 0.918, green: 0.953, blue: 0.871)
        default:                return Color.fathrBorder
        }
    }

    private var categoryColor: Color {
        switch task.category {
        case "Nutrition":       return Color(red: 0.094, green: 0.373, blue: 0.647)
        case "Exercise":        return Color(red: 0.522, green: 0.310, blue: 0.043)
        case "Sleep":           return Color(red: 0.325, green: 0.290, blue: 0.718)
        case "Mental Wellness": return Color(red: 0.600, green: 0.204, blue: 0.345)
        case "Lifestyle":       return Color(red: 0.231, green: 0.427, blue: 0.067)
        default:                return .fathrMuted
        }
    }

    private var categoryIcon: String {
        switch task.category {
        case "Nutrition":       return "drop.fill"
        case "Exercise":        return "figure.run"
        case "Sleep":           return "moon.fill"
        case "Mental Wellness": return "brain.head.profile"
        case "Lifestyle":       return "sun.max.fill"
        default:                return "circle.fill"
        }
    }
}
