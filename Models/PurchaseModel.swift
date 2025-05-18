import Foundation
import RevenueCat

class PurchaseModel: ObservableObject {
    @Published var isSubscribed: Bool = false
    @Published var currentOffering: Offering?
    @Published var errorMessage: String?

    init() {
        checkSubscriptionStatus()
        fetchOfferings()
    }

    func fetchOfferings() {
        Purchases.shared.getOfferings { [weak self] offerings, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.currentOffering = nil
                    print("PurchaseModel: Error fetching offerings - \(error)")
                } else if let offerings = offerings {
                    self?.currentOffering = offerings.current
                    self?.errorMessage = nil
                    print("PurchaseModel: Fetched offerings successfully")
                }
            }
        }
    }

    func purchase(package: Package) {
        Purchases.shared.purchase(package: package) { [weak self] transaction, customerInfo, error, userCancelled in
            DispatchQueue.main.async {
                if userCancelled {
                    self?.errorMessage = "Purchase cancelled"
                } else if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("PurchaseModel: Purchase error - \(error)")
                } else if let customerInfo = customerInfo, customerInfo.entitlements["fathr_pro"]?.isActive == true {
                    self?.isSubscribed = true
                    self?.errorMessage = nil
                    print("PurchaseModel: Purchase successful")
                }
            }
        }
    }

    func restorePurchases() {
        Purchases.shared.restorePurchases { [weak self] customerInfo, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("PurchaseModel: Restore error - \(error)")
                } else if let customerInfo = customerInfo {
                    self?.isSubscribed = customerInfo.entitlements["fathr_pro"]?.isActive == true
                    self?.errorMessage = nil
                    print("PurchaseModel: Restored purchases successfully")
                }
            }
        }
    }

    private func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("PurchaseModel: Customer info error - \(error)")
                } else if let customerInfo = customerInfo {
                    self?.isSubscribed = customerInfo.entitlements["fathr_pro"]?.isActive == true
                    self?.errorMessage = nil
                }
            }
        }
    }
}
