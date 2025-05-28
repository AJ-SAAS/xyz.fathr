import Foundation
import RevenueCat

@MainActor
class PurchaseModel: ObservableObject, Sendable {
    @Published var isSubscribed: Bool = false
    @Published var currentOffering: Offering?
    @Published var errorMessage: String?

    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_rhIxpzSZfMAgajJHLURLcNHmThg") // Your public iOS API key
        Task { await checkSubscriptionStatus() }
        Task { await fetchOfferings() }
    }

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
                let errorMessage: String
                if let rcError = error as? RevenueCat.ErrorCode {
                    switch rcError {
                    case .invalidCredentialsError:
                        errorMessage = "Invalid API key. Please contact support."
                    case .networkError:
                        errorMessage = "Network error. Please check your connection and try again."
                    case .configurationError:
                        errorMessage = "Subscription options not configured. Please try again later."
                    default:
                        errorMessage = "Failed to load purchase options: \(error.localizedDescription)"
                    }
                } else if error is CancellationError {
                    errorMessage = "Loading purchase options timed out. Please try again."
                } else {
                    errorMessage = "Failed to load purchase options: \(error.localizedDescription)"
                }
                self.errorMessage = errorMessage
                self.currentOffering = nil
                print("PurchaseModel: Error fetching offerings - \(error)")
            }
        }
    }

    func purchase(package: Package, completion: @escaping (Bool) -> Void = { _ in }) async {
        do {
            print("PurchaseModel: Starting purchase for package: \(package.identifier)")
            let result = try await Purchases.shared.purchase(package: package)
            await MainActor.run {
                if result.userCancelled {
                    self.errorMessage = "Purchase cancelled by user"
                    print("PurchaseModel: Purchase cancelled by user")
                    completion(false)
                } else if result.customerInfo.entitlements["fathr_pro"]?.isActive == true {
                    self.isSubscribed = true
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
                        errorMessage = "Purchase failed: \(error.localizedDescription)"
                    }
                }
                self.errorMessage = errorMessage
                print("PurchaseModel: Purchase error - \(error) (Code: \(errorCode), Domain: \(nsError.domain))")
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

    // Fixed timeout helper
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        guard seconds > 0 else {
            throw NSError(domain: "InvalidTimeout", code: -1, userInfo: [NSLocalizedDescriptionKey: "Timeout must be positive"])
        }
        return try await withCheckedThrowingContinuation { continuation in
            var hasResumed = false
            // Task 1: Run the operation
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
            // Task 2: Timeout
            Task {
                do {
                    try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                    if !hasResumed {
                        hasResumed = true
                        continuation.resume(throwing: CancellationError())
                        print("PurchaseModel: Timeout triggered after \(seconds) seconds")
                    }
                } catch {
                    print("PurchaseModel: Timeout task cancelled or failed - \(error)")
                    // Ignore cancellation error from sleep
                }
            }
        }
    }
}
