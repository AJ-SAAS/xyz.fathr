import SwiftUI
import RevenueCat

struct PurchaseView: View {
    @Binding var isPresented: Bool
    @ObservedObject var purchaseModel: PurchaseModel
    @State private var isPurchasing: Bool = false
    @State private var selectedPackage: Package?
    @State private var freeTrialEnabled: Bool = true
    @State private var errorMessage: String?
    @State private var showCloseButton: Bool = false // State for close button visibility

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header with close button or loading circle
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
                            .scaleEffect(1.0) // Match size to title3 font
                            .padding(geometry.size.width > 600 ? 16 : 12)
                            .accessibilityLabel("Loading, please wait")
                    }
                    Spacer()
                }
                
                // FathrPro logo with rounded corners
                Image("fathrpro")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .frame(width: min(geometry.size.width * 0.3, 200))
                    .padding(.vertical, 20)
                    .accessibilityLabel("FathrPro Logo")
                
                // Headline
                Text("Premium Access")
                    .font(.custom("SFProDisplay-Black", size: 32))
                    .bold() // Extra emphasis for boldness
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .padding(.bottom, 12)
                    .accessibilityLabel("Premium Access")
                
                // Features list
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(text: "Add Unlimited Tests")
                    FeatureRow(text: "Get personalized suggestions")
                    FeatureRow(text: "Reach your family goals faster")
                    FeatureRow(text: "Remove annoying paywalls")
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                .padding(.bottom, 24)
                
                // Payment options or error state
                if let error = errorMessage ?? purchaseModel.errorMessage {
                    VStack(spacing: 8) {
                        Text("Error: \(error)")
                            .font(.system(.subheadline, design: .default, weight: .regular))
                            .foregroundColor(.red)
                            .accessibilityLabel("Error: \(error)")
                        Button("Retry") {
                            errorMessage = nil
                            Task {
                                await purchaseModel.fetchOfferings()
                            }
                        }
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(.black)
                        .cornerRadius(8)
                        .accessibilityLabel("Retry fetching offerings")
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                } else if let offering = purchaseModel.currentOffering {
                    VStack(spacing: 8) {
                        // Yearly Plan
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
                        
                        // Weekly Plan with Trial
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
                
                // Free trial toggle, cancel anytime text, and purchase button
                VStack(spacing: 4) {
                    // Free Trial Enabled Card
                    HStack {
                        Text("Free Trial Enabled")
                            .font(.system(.headline, design: .default, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                        Toggle("", isOn: $freeTrialEnabled)
                            .labelsHidden()
                            .tint(.green)
                            .accessibilityLabel("Toggle free trial")
                    }
                    .padding(.horizontal)
                    .padding(.top, 11)
                    .padding(.bottom, 11)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                    .padding(.top, 6)
                    
                    // No Commitment - Cancel Anytime
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(.subheadline, design: .default, weight: .regular))
                            .foregroundColor(.blue)
                        Text("No Commitment - Cancel Anytime")
                            .font(.system(.subheadline, design: .default, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
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
                            Text(isPurchasing ? "Processing..." : "Try 3 days free")
                            if !isPurchasing {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(selectedPackage == nil || isPurchasing ? Color.gray : Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(selectedPackage == nil || isPurchasing)
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                    .accessibilityLabel(isPurchasing ? "Processing purchase" : "Try 3 days free")
                    
                    if isPurchasing {
                        ProgressView()
                            .padding(.top, 4)
                            .accessibilityLabel("Purchase in progress")
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
                    .font(.system(.caption, design: .default, weight: .regular))
                    .foregroundColor(.gray)
                    .accessibilityLabel("Restore Purchases")
                    
                    Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        .font(.system(.caption, design: .default, weight: .regular))
                        .foregroundColor(.gray)
                        .accessibilityLabel("Terms of Use")
                    
                    Link("Privacy Policy", destination: URL(string: "https://www.fathr.xyz/r/privacy")!)
                        .font(.system(.caption, design: .default, weight: .regular))
                        .foregroundColor(.gray)
                        .accessibilityLabel("Privacy Policy")
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
                // Start 5-second timer for close button
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
                .font(.system(size: 16, weight: .bold))
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
                    .font(isWeeklyPlan ? .system(size: 13, weight: .bold) : .system(.caption2, design: .default, weight: .bold)) // 13pt for SHORT TERM, caption2 for BEST VALUE
                    .foregroundColor(isWeeklyPlan ? .black : .white) // Black for SHORT TERM, white for BEST VALUE
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(isWeeklyPlan ? Color.clear : Color.red) // Clear for SHORT TERM, red for BEST VALUE
                    .cornerRadius(4)
            }
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(.title3, design: .default, weight: .regular))
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
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(title), \(price)\(badgeText != nil ? ", \(badgeText!)" : "")\(isSelected ? ", selected" : "")")
    }
}

#Preview("iPhone 14") {
    PurchaseView(isPresented: .constant(true), purchaseModel: PurchaseModel())
}

#Preview("iPad Pro") {
    PurchaseView(isPresented: .constant(true), purchaseModel: PurchaseModel())
}
