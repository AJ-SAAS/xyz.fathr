import Foundation
import RevenueCat

@MainActor
class PurchaseModel: ObservableObject {
    
    @Published var isSubscribed: Bool = false
    @Published var currentOffering: Offering?
    @Published var errorMessage: String?

    init() {
        Task {
            await fetchOfferings()
            await checkSubscriptionStatus()
        }
    }

    // MARK: - Fetch Offerings
    func fetchOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            await MainActor.run {
                self.currentOffering = offerings.current
                self.errorMessage = nil
                print("✅ RevenueCat: Offerings fetched successfully - Current: \(offerings.current?.identifier ?? "none")")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load subscription plans. Please try again."
                print("❌ RevenueCat: Failed to fetch offerings - \(error)")
            }
        }
    }

    // MARK: - Purchase
    func purchase(package: Package) async -> Bool {
        do {
            print("💰 Starting purchase for: \(package.identifier)")
            let result = try await Purchases.shared.purchase(package: package)
            
            if result.userCancelled {
                print("Purchase cancelled by user")
                return false
            }
            
            let isActive = result.customerInfo.entitlements["fathr_pro"]?.isActive ?? false
            
            await MainActor.run {
                self.isSubscribed = isActive
                if isActive {
                    self.errorMessage = nil
                }
            }
            
            print(isActive ? "✅ Purchase successful - Pro unlocked" : "⚠️ Purchase completed but entitlement not active")
            return isActive
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            print("❌ Purchase error: \(error)")
            return false
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            let isActive = customerInfo.entitlements["fathr_pro"]?.isActive ?? false
            
            await MainActor.run {
                self.isSubscribed = isActive
                self.errorMessage = nil
            }
            
            print(isActive ? "✅ Restore successful - Pro unlocked" : "⚠️ Restore completed but no active entitlement")
            return isActive
        } catch {
            await MainActor.run {
                self.errorMessage = "Restore failed: \(error.localizedDescription)"
            }
            print("❌ Restore error: \(error)")
            return false
        }
    }

    // MARK: - Check Subscription Status
    private func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            let isActive = customerInfo.entitlements["fathr_pro"]?.isActive ?? false
            
            await MainActor.run {
                self.isSubscribed = isActive
            }
            print("✅ Subscription status checked: \(isActive ? "Pro Active" : "Free tier")")
        } catch {
            print("❌ Error checking subscription status: \(error)")
        }
    }
}
