import Foundation
import RevenueCat

@MainActor
class PurchaseModel: ObservableObject, Sendable {
    @Published var isSubscribed: Bool = false
    @Published var currentOffering: Offering?
    @Published var errorMessage: String?

    init() {
        Purchases.logLevel = .debug
        Task { await checkSubscriptionStatus() }
        Task { await fetchOfferings() }
    }

    func fetchOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            await MainActor.run {
                self.currentOffering = offerings.current
                self.errorMessage = nil
                print("PurchaseModel: Fetched offerings successfully")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.currentOffering = nil
                print("PurchaseModel: Error fetching offerings - \(error)")
            }
        }
    }

    func purchase(package: Package, completion: @escaping (Bool) -> Void = { _ in }) async {
        do {
            let result = try await Purchases.shared.purchase(package: package)
            await MainActor.run {
                if result.userCancelled {
                    self.errorMessage = "Purchase cancelled"
                    completion(false)
                } else if result.customerInfo.entitlements["fathr_pro"]?.isActive == true {
                    self.isSubscribed = true
                    self.errorMessage = nil
                    print("PurchaseModel: Purchase successful")
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                print("PurchaseModel: Purchase error - \(error)")
                completion(false)
            }
        }
    }

    func restorePurchases(completion: @escaping (Bool) -> Void = { _ in }) async {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            await MainActor.run {
                self.isSubscribed = customerInfo.entitlements["fathr_pro"]?.isActive == true
                self.errorMessage = nil
                print("PurchaseModel: Restored purchases successfully")
                completion(self.isSubscribed)
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                print("PurchaseModel: Restore error - \(error)")
                completion(false)
            }
        }
    }

    private func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            await MainActor.run {
                self.isSubscribed = customerInfo.entitlements["fathr_pro"]?.isActive == true
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                print("PurchaseModel: Customer info error - \(error)")
            }
        }
    }
}
