import SwiftUI
import Foundation

class OnboardingDataManager: ObservableObject {
    static let shared = OnboardingDataManager()
    
    @AppStorage("onboarding_journeyStage") var journeyStage: String = ""
    @AppStorage("onboarding_mainGoal") var mainGoal: String = ""
    @AppStorage("hasCompletedOnboardingTemp") var hasCompletedOnboardingTemp: Bool = false
    
    func saveOnboardingData(journeyStage: String, mainGoal: String) {
        self.journeyStage = journeyStage
        self.mainGoal = mainGoal
        self.hasCompletedOnboardingTemp = true
    }
    
    func clearTempData() {
        journeyStage = ""
        mainGoal = ""
        hasCompletedOnboardingTemp = false
    }
}
