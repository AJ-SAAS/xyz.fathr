import Foundation
import RevenueCat

@MainActor
class PurchaseModel: ObservableObject, Sendable {
    @Published var isSubscribed: Bool = false
    @Published var currentOffering: Offering?
    @Published var errorMessage: String?
    
    private var subscriptionExpiry: Date? {
        didSet {
            isSubscribed = subscriptionExpiry.map { $0 > Date() } ?? false
        }
    }
    
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_rhIxpzSZfMAgajJHLURLcNHmThg")
        Task { await checkSubscriptionStatus() }
        Task { await fetchOfferings() }
    }
    
    // MARK: - Offerings
    func fetchOfferings() async {
        do {
            let offerings = try await withTimeout(seconds: 10) {
                try await Purchases.shared.offerings()
            }
            await MainActor.run {
                self.currentOffering = offerings.current
                self.errorMessage = nil
                print("PurchaseModel: Fetched offerings successfully")
            }
        } catch {
            await MainActor.run {
                self.handleError(error, context: "fetching offerings")
            }
        }
    }
    
    // MARK: - Purchase
    func purchase(package: Package, completion: @escaping (Bool) -> Void = { _ in }) async {
        do {
            print("PurchaseModel: Starting purchase for package: \(package.identifier)")
            let result = try await Purchases.shared.purchase(package: package)
            await MainActor.run {
                if result.userCancelled {
                    self.errorMessage = "Purchase cancelled by user"
                    print("PurchaseModel: Purchase cancelled by user")
                    completion(false)
                } else if let entitlement = result.customerInfo.entitlements["fathr_pro"], entitlement.isActive {
                    self.subscriptionExpiry = self.calculateExpiry(for: package)
                    self.errorMessage = nil
                    print("PurchaseModel: Purchase successful, entitlement active")
                    completion(true)
                } else {
                    self.errorMessage = "Purchase completed but entitlement not active"
                    print("PurchaseModel: Purchase completed but entitlement not active")
                    completion(false)
                }
            }
        } catch {
            await MainActor.run {
                self.handleError(error, context: "purchase")
                completion(false)
            }
        }
    }
    
    // MARK: - Restore
    func restorePurchases(completion: @escaping (Bool) -> Void = { _ in }) async {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            await MainActor.run {
                if let entitlement = customerInfo.entitlements["fathr_pro"], entitlement.isActive {
                    self.subscriptionExpiry = Date.distantFuture // Use actual expiry if RevenueCat provides it
                } else {
                    self.subscriptionExpiry = nil
                }
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
    
    // MARK: - Check Status
    private func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            if let entitlement = customerInfo.entitlements["fathr_pro"], entitlement.isActive {
                // Optionally, you can retrieve expiration date from RevenueCat if available
                self.subscriptionExpiry = Date.distantFuture
            } else {
                self.subscriptionExpiry = nil
            }
            self.errorMessage = nil
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                print("PurchaseModel: Customer info error - \(error)")
            }
        }
    }
    
    // MARK: - Helper: Calculate Expiry
    private func calculateExpiry(for package: Package) -> Date {
        let now = Date()
        guard let period = package.storeProduct.subscriptionPeriod else { return now }
        
        switch period.unit {
        case .week:
            return Calendar.current.date(byAdding: .weekOfYear, value: period.value, to: now) ?? now
        case .year:
            return Calendar.current.date(byAdding: .year, value: period.value, to: now) ?? now
        default:
            return now
        }
    }
    
    // MARK: - Helper: Timeout
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        guard seconds > 0 else {
            throw NSError(domain: "InvalidTimeout", code: -1, userInfo: [NSLocalizedDescriptionKey: "Timeout must be positive"])
        }
        return try await withCheckedThrowingContinuation { continuation in
            var hasResumed = false
            Task {
                do {
                    let result = try await operation()
                    if !hasResumed {
                        hasResumed = true
                        continuation.resume(returning: result)
                        print("PurchaseModel: Operation completed successfully")
                    }
                } catch {
                    if !hasResumed {
                        hasResumed = true
                        continuation.resume(throwing: error)
                        print("PurchaseModel: Operation failed with error - \(error)")
                    }
                }
            }
            Task {
                try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                if !hasResumed {
                    hasResumed = true
                    continuation.resume(throwing: CancellationError())
                    print("PurchaseModel: Timeout triggered after \(seconds) seconds")
                }
            }
        }
    }
    
    // MARK: - Helper: Error Handling
    private func handleError(_ error: Error, context: String) {
        let nsError = error as NSError
        let errorCode = ErrorCode(rawValue: nsError.code) ?? .unknownError
        let errorMessage: String
        
        switch errorCode {
        case .productNotAvailableForPurchaseError:
            errorMessage = "This product is not available for purchase."
        case .networkError:
            errorMessage = "Network error. Please check your connection."
        case .invalidCredentialsError:
            errorMessage = "Invalid App Store credentials."
        case .storeProblemError:
            errorMessage = "App Store issue. Please try again later."
        default:
            if nsError.domain == "ASDErrorDomain" && nsError.code == 509 {
                errorMessage = "Please sign in to a sandbox account to make purchases."
            } else if nsError.domain == "AMSErrorDomain" && nsError.code == 100 {
                errorMessage = "App Store authentication failed. Please sign in to a sandbox account."
            } else {
                errorMessage = "Operation failed: \(error.localizedDescription)"
            }
        }
        
        self.errorMessage = errorMessage
        print("PurchaseModel: \(context) error - \(error) (Code: \(errorCode), Domain: \(nsError.domain))")
    }
}
