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
                // Screen 1: Welcome
                VStack(spacing: 20) {
                    Image(systemName: "figure.2.and.child.holdinghands")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .foregroundColor(.blue)
                    Text("Take Charge of Your Fertility!")
                        .font(.title)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                    Text("The 74-Day Fertility Upgrade Challenge helps you boost sperm health with daily, science-backed habits.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Next") {
                        currentPage = 1
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()
                .tag(0)
                
                // Screen 2: Why 74 Days?
                VStack(spacing: 20) {
                    Image(systemName: "clock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .foregroundColor(.blue)
                    Text("Why 74 Days?")
                        .font(.title)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                    Text("It takes ~74 days for your body to create new sperm. Daily habits like nutrition, exercise, and sleep can improve sperm count, motility, and quality during this cycle.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Next") {
                        currentPage = 2
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()
                .tag(1)
                
                // Screen 3: How it Works
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .foregroundColor(.blue)
                    Text("How the Challenge Works")
                        .font(.title)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                    Text("• 1 simple task per day\n• Track progress with your Fertility Habits Index\n• See potential sperm health gains\n• Stay motivated with badges & tips")
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                    NavigationLink(
                        destination: ChallengeView(startDate: Date(), testStore: testStore)
                            .environmentObject(authManager),
                        isActive: $navigateToChallenge
                    ) {
                        Button(action: {
                            guard !isSavingProgress, let userId = authManager.currentUserID else {
                                print("ChallengeOnboardingView: Cannot save progress, isSavingProgress=\(isSavingProgress), userId=\(authManager.currentUserID ?? "nil")")
                                errorMessage = "Unable to start challenge: No user signed in."
                                showErrorAlert = true
                                return
                            }
                            isSavingProgress = true
                            hasCompletedChallengeOnboarding = true // Set onboarding as complete
                            print("ChallengeOnboardingView: Saving challenge progress for user: \(userId)")
                            testStore.saveChallengeProgress(
                                userId: userId,
                                startDate: Date(),
                                completionStatus: [:],
                                fhi: 0
                            ) { success in
                                DispatchQueue.main.async {
                                    isSavingProgress = false
                                    if success {
                                        print("ChallengeOnboardingView: Progress saved successfully")
                                        navigateToChallenge = true
                                    } else {
                                        print("ChallengeOnboardingView: Failed to save progress")
                                        errorMessage = "Failed to save challenge progress. Please try again."
                                        showErrorAlert = true
                                        navigateToChallenge = true // Proceed anyway to avoid getting stuck
                                    }
                                }
                            }
                        }) {
                            Text(isSavingProgress ? "Saving..." : "Start Challenge")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .padding()
                                .background(isSavingProgress ? Color.gray : Color.blue)
                                .cornerRadius(10)
                        }
                        .disabled(isSavingProgress)
                    }
                }
                .padding()
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .navigationTitle("Fertility Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
