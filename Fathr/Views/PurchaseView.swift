import SwiftUI
import RevenueCat

struct PurchaseView: View {
    @Binding var isPresented: Bool
    @ObservedObject var purchaseModel: PurchaseModel
    @State private var isPurchasing: Bool = false
    @State private var selectedPackage: Package?
    @State private var freeTrialEnabled: Bool = true
    @State private var errorMessage: String?
    @State private var showCloseButton: Bool = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                HStack {
                    if showCloseButton {
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(.title3, design: .default, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(geometry.size.width > 600 ? 16 : 12)
                        }
                        .accessibilityLabel("Close")
                    } else {
                        ProgressView()
                            .scaleEffect(1.0)
                            .padding(geometry.size.width > 600 ? 16 : 12)
                            .accessibilityLabel("Loading, please wait")
                    }
                    Spacer()
                }

                // Logo
                Image("fathrpro")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .frame(width: min(geometry.size.width * 0.3, 200))
                    .padding(.vertical, 20)
                    .accessibilityLabel("FathrPro Logo")

                // Headline
                Text("Unlock Premium Access")
                    .font(.custom("SFProDisplay-Black", size: 32))
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .padding(.bottom, 12)

                // Features
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(text: "Add Unlimited Tests")
                    FeatureRow(text: "Get personalized fertility roadmap")
                    FeatureRow(text: "Reach your family goals faster")
                    FeatureRow(text: "Remove annoying paywalls")
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                .padding(.bottom, 24)

                // Error or Packages
                if let error = errorMessage ?? purchaseModel.errorMessage {
                    VStack(spacing: 8) {
                        Text("Error: \(error)")
                            .font(.system(.subheadline))
                            .foregroundColor(.red)
                        Button("Retry") {
                            errorMessage = nil
                            Task {
                                await purchaseModel.fetchOfferings()
                            }
                        }
                        .font(.system(.headline))
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(.black)
                        .cornerRadius(8)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                } else if let offering = purchaseModel.currentOffering {
                    VStack(spacing: 8) {
                        PackageButton(
                            title: "Yearly Plan",
                            price: offering.package(identifier: "yearly_pro")?.storeProduct.localizedPriceString ?? "$29.99 per year",
                            crossedOutPrice: "$149.99",
                            badgeText: "BEST VALUE",
                            isSelected: selectedPackage?.identifier == "yearly_pro",
                            isWeeklyPlan: false,
                            action: {
                                if let yearly = offering.package(identifier: "yearly_pro") {
                                    selectedPackage = yearly
                                }
                            }
                        )
                        .frame(maxWidth: min(geometry.size.width * 0.9, 600))

                        PackageButton(
                            title: "3-Day Trial",
                            price: "then \(offering.package(identifier: "weekly_pro_trial")?.storeProduct.localizedPriceString ?? "$5.99") per week",
                            badgeText: "SHORT TERM",
                            isSelected: selectedPackage?.identifier == "weekly_pro_trial",
                            isWeeklyPlan: true,
                            action: {
                                if let weekly = offering.package(identifier: "weekly_pro_trial") {
                                    selectedPackage = weekly
                                }
                            }
                        )
                        .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                } else {
                    ProgressView()
                        .padding()
                        .accessibilityLabel("Loading purchase options")
                }

                // Free Trial Card with Toggle + No Commitment
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Free Trial Enabled")
                            .font(.system(.headline, design: .default, weight: .bold))
                            .foregroundColor(.black)
                        HStack(spacing: 4) {
                            Text("No payment required today")
                                .font(.system(.subheadline))
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    Toggle("", isOn: $freeTrialEnabled)
                        .labelsHidden()
                        .tint(.green)
                        .accessibilityLabel("Toggle free trial")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                .padding(.top, 6)
                .padding(.bottom, 16)

                // Purchase Button
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
                        Text(isPurchasing ? "Processing..." : "Try 3 days free")
                        if !isPurchasing {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .font(.system(.headline))
                    .foregroundColor(.white)
                    .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                    .padding()
                    .background(selectedPackage == nil || isPurchasing ? Color.gray : Color.blue)
                    .cornerRadius(10)
                }
                .disabled(selectedPackage == nil || isPurchasing)
                .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)

                if isPurchasing {
                    ProgressView()
                        .padding(.top, 4)
                        .accessibilityLabel("Purchase in progress")
                }

                // Footer Links
                HStack(spacing: 16) {
                    Button("Restore Purchases") {
                        isPurchasing = true
                        Task {
                            await purchaseModel.restorePurchases { _ in
                                isPurchasing = false
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.gray)

                    Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        .font(.caption)
                        .foregroundColor(.gray)

                    Link("Privacy Policy", destination: URL(string: "https://www.fathr.xyz/r/privacy")!)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 8)
                .padding(.bottom, geometry.size.width > 600 ? 16 : 8)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(.container, edges: .top)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 8)
            }
            .onAppear {
                Task {
                    await purchaseModel.fetchOfferings()
                    if let offering = purchaseModel.currentOffering {
                        selectedPackage = freeTrialEnabled ? offering.package(identifier: "weekly_pro_trial") : offering.package(identifier: "yearly_pro")
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation {
                        showCloseButton = true
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
}

// MARK: - Feature Row
struct FeatureRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.custom("SFProDisplay-Regular", size: 16))
                .foregroundColor(.blue)
            Text(text)
                .font(.custom("SFProDisplay-Regular", size: 16))
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Package Button
struct PackageButton: View {
    let title: String
    let price: String
    var crossedOutPrice: String?
    let badgeText: String?
    let isSelected: Bool
    let isWeeklyPlan: Bool
    let action: () -> Void

    private var pricingView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom("SFProDisplay-Bold", size: 16))
            if let crossedOutPrice = crossedOutPrice {
                HStack(spacing: 4) {
                    Text(crossedOutPrice)
                        .strikethrough()
                        .foregroundColor(.gray)
                    Text(price)
                        .fontWeight(.medium)
                }
                .font(.custom("SFProDisplay-Regular", size: 17))
                .foregroundColor(Color(.darkGray))
            } else {
                Text(price)
                    .font(.custom("SFProDisplay-Regular", size: 17))
                    .foregroundColor(Color(.darkGray))
            }
        }
    }

    private var badgeAndSelectionView: some View {
        HStack(alignment: .center, spacing: 8) {
            if let badge = badgeText {
                Text(badge)
                    .font(isWeeklyPlan ? .system(size: 13, weight: .bold) : .system(.caption2, weight: .bold))
                    .foregroundColor(isWeeklyPlan ? .black : .white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(isWeeklyPlan ? Color.clear : Color.red)
                    .cornerRadius(4)
            }
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(.title3))
                .foregroundColor(isSelected ? .blue : .gray)
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center) {
                    pricingView
                    Spacer()
                    badgeAndSelectionView
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.4), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

