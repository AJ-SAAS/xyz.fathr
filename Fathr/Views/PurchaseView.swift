import SwiftUI
import RevenueCat

struct PurchaseView: View {
    @Binding var isPresented: Bool
    @ObservedObject var purchaseModel: PurchaseModel
    @State private var isPurchasing = false
    @State private var selectedPackage: Package?
    @State private var freeTrialEnabled = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.gray)
                        .padding()
                }
            }

            // App icon or family image
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 20)
                .padding(.bottom, 16)

            // Headline
            Text("Unlock Your Fertility Insights with Fathr")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 8)

            // Subtext
            Text("Get full access to your test results, personalized insights, and progress tracking.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)

            // Features list
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(text: "Detailed Test Analysis", subtext: "Understand your sperm health with in-depth metrics")
                FeatureRow(text: "Track Progress Over Time", subtext: "Monitor trends to stay on top of your fertility goals")
                FeatureRow(text: "Personalized Recommendations", subtext: "Daily tips tailored to improve your results")
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)

            // Payment options or error state
            if let error = errorMessage ?? purchaseModel.errorMessage {
                VStack {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                    Button("Retry") {
                        errorMessage = nil
                        Task {
                            await purchaseModel.fetchOfferings()
                        }
                    }
                }
                .padding()
            } else if let offering = purchaseModel.currentOffering {
                VStack(spacing: 12) {
                    // Yearly Plan
                    PackageButton(
                        title: "Yearly Plan",
                        price: offering.package(identifier: "yearly_pro")?.storeProduct.localizedPriceString ?? "$59.99 per year",
                        crossedOutPrice: "$311.48",
                        badgeText: "BEST VALUE",
                        isSelected: selectedPackage?.identifier == "yearly_pro",
                        isWeeklyPlan: false,
                        action: {
                            if let yearly = offering.package(identifier: "yearly_pro") {
                                selectedPackage = yearly
                            }
                        }
                    )

                    // Weekly Plan with Trial
                    PackageButton(
                        title: "3-Day Free Trial",
                        price: "then \(offering.package(identifier: "weekly_pro_trial")?.storeProduct.localizedPriceString ?? "$5.99") per week",
                        badgeText: "TRY FREE",
                        isSelected: selectedPackage?.identifier == "weekly_pro_trial",
                        isWeeklyPlan: true,
                        action: {
                            if let weekly = offering.package(identifier: "weekly_pro_trial") {
                                selectedPackage = weekly
                            }
                        }
                    )
                }
                .padding(.horizontal, 16)
            } else {
                ProgressView()
                    .padding()
            }

            // Free trial toggle, cancel anytime text, and purchase button
            VStack(spacing: 8) {
                // Free Trial Enabled Card
                HStack {
                    Text("Free Trial Enabled")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Spacer()
                    Toggle("", isOn: $freeTrialEnabled)
                        .labelsHidden()
                        .tint(.green)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // No Commitment - Cancel Anytime
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    Text("No Commitment - Cancel Anytime")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Purchase button
                Button(action: {
                    if let package = selectedPackage {
                        isPurchasing = true
                        Task {
                            await purchaseModel.purchase(package: package) { _ in
                                isPurchasing = false
                            }
                        }
                    }
                }) {
                    HStack {
                        Text(isPurchasing ? "Processing..." : "Unlock Fathr Now")
                        if !isPurchasing {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedPackage == nil || isPurchasing ? Color.gray : Color.blue)
                    .cornerRadius(10)
                }
                .disabled(selectedPackage == nil || isPurchasing)
                .padding(.horizontal, 16)

                if isPurchasing {
                    ProgressView()
                        .padding(.top, 8)
                }
            }

            // Footer links
            HStack(spacing: 16) {
                Button("Restore Purchases") {
                    isPurchasing = true
                    Task {
                        await purchaseModel.restorePurchases { _ in
                            isPurchasing = false
                        }
                    }
                }
                Link("Terms of Use", destination: URL(string: "https://www.fathr.xyz/r/terms")!)
                Link("Privacy Policy", destination: URL(string: "https://www.fathr.xyz/r/privacy")!)
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.top, 16)
            .padding(.bottom, 8)

            Spacer()
        }
        .onAppear {
            Task {
                await purchaseModel.fetchOfferings()
                if let offering = purchaseModel.currentOffering {
                    selectedPackage = freeTrialEnabled ? offering.package(identifier: "weekly_pro_trial") : offering.package(identifier: "yearly_pro")
                }
            }
        }
        .onChange(of: purchaseModel.isSubscribed) { _, newValue in
            if newValue {
                isPresented = false
            }
        }
        .onChange(of: purchaseModel.errorMessage) { _, newValue in
            errorMessage = newValue
        }
        .onChange(of: freeTrialEnabled) { _, newValue in
            if let offering = purchaseModel.currentOffering {
                selectedPackage = newValue ? offering.package(identifier: "weekly_pro_trial") : offering.package(identifier: "yearly_pro")
            }
        }
    }
}

struct FeatureRow: View {
    let text: String
    let subtext: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(subtext)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct PackageButton: View {
    let title: String
    let price: String
    var crossedOutPrice: String?
    let badgeText: String?
    let isSelected: Bool
    let isWeeklyPlan: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                        if let crossedOutPrice = crossedOutPrice {
                            HStack(spacing: 4) {
                                Text(crossedOutPrice)
                                    .strikethrough()
                                    .foregroundColor(.gray)
                                Text(price)
                                    .fontWeight(.medium)
                            }
                            .font(.subheadline)
                        } else {
                            Text(price)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        if let badge = badgeText {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(isWeeklyPlan ? Color.green : Color.blue)
                                .cornerRadius(4)
                        }

                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .blue : .gray)
                            .font(.system(size: 20))
                    }
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
