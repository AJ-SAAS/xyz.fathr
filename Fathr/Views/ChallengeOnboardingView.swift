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
    
    // NEW: Callback when user completes onboarding
    var onComplete: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.top, 20)
                
                TabView(selection: $currentPage) {
                    // Screen 1
                    VStack(spacing: 30) {
                        Image(systemName: "figure.2.and.child.holdinghands")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.green)
                            .padding(.top, 40)
                        
                        Text("Rebuild Your Vitality")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                        Text("The 74-Day Fertility Challenge helps you build healthy daily habits to support reproductive wellness, energy, and vitality.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                        Button("Next") {
                            currentPage = 1
                        }
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .tag(0)
                    .padding(.bottom, 40)
                    
                    // Screen 2
                    VStack(spacing: 30) {
                        Image(systemName: "clock")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.green)
                            .padding(.top, 40)
                        
                        Text("Why 74 Days?")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                        Text("It takes about 74 days for your body to create new sperm. Daily habits like nutrition, exercise, sleep, and stress management may support reproductive health and overall wellness.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                        Button("Next") {
                            currentPage = 2
                        }
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .tag(1)
                    .padding(.bottom, 40)
                    
                    // Screen 3
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
                                Text("Follow these rules closely:").bold()
                                Group {
                                    Text("1. Nutrition: Focus on whole foods, stay hydrated (≥3L daily), include fertility-supporting foods like leafy greens and berries.")
                                    Text("2. Supplements: Consider zinc, D3+K2, CoQ10, and Omega-3. Consult a professional if unsure.")
                                    Text("3. Heat Avoidance: Avoid saunas, hot tubs, laptops on lap; wear loose underwear.")
                                    Text("4. Exercise: Move 45+ minutes daily; mix resistance, cardio, and stretching.")
                                    Text("5. Sleep & Recovery: Aim for ≥7 hours nightly; reduce blue light before bed.")
                                    Text("6. Mental & Sexual Discipline: Avoid pornography, keep a journal, and build focus.")
                                    Text("7. Daily Check-in: Complete tasks and rate energy/mood.")
                                }
                                .font(.body)
                                
                                Text("\nThis challenge is educational and for wellness purposes only. Consult a healthcare professional before major lifestyle changes.")
                                    .foregroundColor(.red.opacity(0.9))
                                    .font(.footnote)
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            Button {
                                startChallenge()
                            } label: {
                                Text(isSavingProgress ? "Starting..." : "Start Challenge")
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
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .navigationTitle("Fertility Challenge")
                .navigationBarTitleDisplayMode(.inline)
                
                // FIXED: Only pass startDate
                .navigationDestination(isPresented: $navigateToChallenge) {
                    if let startDate = testStore.challengeProgress?.startDate {
                        ChallengeView(startDate: startDate)
                            .environmentObject(testStore)
                            .environmentObject(authManager)
                    } else {
                        Text("Preparing your challenge...")
                            .font(.headline)
                    }
                }
                
                .alert(isPresented: $showErrorAlert) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
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
        
        var days: [Int: TestStore.ChallengeDayProgress] = [:]
        for day in 1...74 {
            let dayTasks = ChallengeTasks.allDays
                .first(where: { $0.dayNumber == day })?
                .tasks ?? []
            let taskProgress = dayTasks.map { _ in TestStore.ChallengeTaskProgress(completed: false) }
            days[day] = TestStore.ChallengeDayProgress(
                tasks: taskProgress,
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
        
        testStore.challengeProgress = progress
        
        testStore.saveChallengeProgress(userId: userId) { success in
            DispatchQueue.main.async {
                isSavingProgress = false
                if success {
                    onComplete()
                    navigateToChallenge = true
                } else {
                    errorMessage = "Failed to save challenge progress. Check internet and try again."
                    showErrorAlert = true
                }
            }
        }
    }
}
