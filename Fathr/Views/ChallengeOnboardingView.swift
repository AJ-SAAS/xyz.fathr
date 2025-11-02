import SwiftUI
import FirebaseAuth

struct ChallengeOnboardingView: View {
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var authManager: AuthManager
    @State private var currentPage = 0
    @State private var isSavingProgress = false
    @State private var navigateToChallenge = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @AppStorage("hasCompletedChallengeOnboarding") private var hasCompletedChallengeOnboarding = false

    var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                // MARK: Screen 1
                VStack(spacing: 30) {
                    Image(systemName: "figure.2.and.child.holdinghands")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.green)
                        .padding(.top, 40)

                    VStack(spacing: 10) {
                        Text("Rebuild Your Vitality")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)

                        Text("The 74-Day Fertility Challenge helps you boost sperm health with daily science-backed habits.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }

                    Spacer()

                    Button {
                        currentPage = 1
                    } label: {
                        Text("Next")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .tag(0)
                .padding(.bottom, 40)

                // MARK: Screen 2
                VStack(spacing: 30) {
                    Image(systemName: "clock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.green)
                        .padding(.top, 40)

                    VStack(spacing: 15) {
                        Text("Why 74 Days?")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)

                        Text("It takes about 74 days for your body to create new sperm. Daily habits like nutrition, exercise, and sleep can improve sperm count, motility, and overall quality.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }

                    Spacer()

                    Button {
                        currentPage = 2
                    } label: {
                        Text("Next")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .tag(1)
                .padding(.bottom, 40)

                // MARK: Screen 3
                ScrollView {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.green)
                            .padding(.top, 40)

                        Text("Core Rules")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("🔥 No substitutions, no shortcuts:").bold()
                            Text("1. Nutrition: Whole foods, hydration ≥3L, fertility supermeals daily")
                            Text("2. Supplements: Zinc, D3+K2, CoQ10, Omega-3, testosterone boosters")
                            Text("3. Heat avoidance: No saunas, hot tubs, laptops on lap, loose underwear, cold showers")
                            Text("4. Exercise: 45+ min daily, 3x/week resistance, 2x/week cardio, 2x/week yoga/stretch")
                            Text("5. Sleep & recovery: ≥7 hours, no blue light before bed")
                            Text("6. Mental & sexual discipline: No porn, 7–10 day retention streaks, daily journal starting with 'Today I invested in my future family by…'")
                            Text("7. Daily check-in: Complete all tasks, optional photo, log energy/mood")
                        }
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                        Spacer()

                        // MARK: Start Challenge Button
                        Button {
                            startChallenge()
                        } label: {
                            Text(isSavingProgress ? "Saving..." : "Start Challenge")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isSavingProgress ? Color.gray : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(isSavingProgress)
                        .padding(.horizontal)
                    }
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle())
            // Removed .indexViewStyle to hide page indicator dots
            .navigationTitle("Fertility Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToChallenge) {
                ChallengeView(
                    startDate: Date(),
                    testStore: testStore
                )
                .environmentObject(authManager)
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func startChallenge() {
        guard !isSavingProgress, let userId = authManager.currentUserID else {
            errorMessage = "Unable to start challenge: No user signed in."
            showErrorAlert = true
            return
        }

        isSavingProgress = true
        hasCompletedChallengeOnboarding = true

        var days: [Int: TestStore.ChallengeDayProgress] = [:]
        for day in 1...74 {
            days[day] = TestStore.ChallengeDayProgress(
                tasks: Array(repeating: TestStore.ChallengeTaskProgress(completed: false), count: 7),
                mood: nil,
                energy: nil,
                journalEntry: nil
            )
        }

        let progress = TestStore.ChallengeProgress(
            startDate: Date(),
            days: days,
            fhi: 0,
            hardcoreMode: true
        )

        // Set the challengeProgress property before saving
        testStore.challengeProgress = progress

        testStore.saveChallengeProgress(userId: userId) { success in
            DispatchQueue.main.async {
                isSavingProgress = false
                if success {
                    print("ChallengeOnboardingView: Progress saved successfully")
                    navigateToChallenge = true
                } else {
                    errorMessage = "Failed to save challenge progress. Please try again."
                    showErrorAlert = true
                    navigateToChallenge = true // Proceed to avoid getting stuck
                }
            }
        }
    }
}
