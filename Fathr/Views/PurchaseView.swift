import SwiftUI
import RevenueCat

struct PurchaseView: View {
    @Binding var isPresented: Bool
    @ObservedObject var purchaseModel: PurchaseModel
    @State private var isPurchasing: Bool = false
    @State private var selectedPackage: Package?
    @State private var freeTrialEnabled: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) { // Remove default spacing for precise control
                    // Header with close button
                    HStack {
                        Spacer()
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(.title3, design: .default, weight: .bold)) // Dynamic type
                                .foregroundColor(.gray)
                                .padding(geometry.size.width > 600 ? 24 : 16) // Adjust for iPad
                        }
                        .accessibilityLabel("Close")
                    }
                    
                    // App icon or family image
                    Image(systemName: "heart.fill")
                        .font(.system(size: geometry.size.width > 600 ? 80 : 60)) // Adjust for iPad
                        .foregroundColor(.blue)
                        .padding(.top, geometry.size.width > 600 ? 32 : 20) // Adjust for iPad
                        .padding(.bottom, 16)
                        .accessibilityLabel("Fathr Icon")
                    
                    // Headline
                    Text("Unlock Your Fertility Insights with Fathr")
                        .font(.system(.title2, design: .default, weight: .bold)) // Dynamic type
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                        .padding(.bottom, 8)
                        .accessibilityLabel("Unlock Your Fertility Insights with Fathr")
                    
                    // Subtext
                    Text("Get full access Know more. Track better. Grow your family.")
                        .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                        .padding(.bottom, 24)
                    
                    // Features list
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(text: "Detailed Test Analysis", subtext: "Understand your sperm health with in-depth metrics")
                        FeatureRow(text: "Track Progress Over Time", subtext: "Monitor trends to stay on top of your fertility goals")
                        FeatureRow(text: "Personalized Recommendations", subtext: "Daily tips tailored to improve your results")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
                    .padding(.bottom, 32)
                    
                    // Payment options or error state
                    if let error = errorMessage ?? purchaseModel.errorMessage {
                        VStack(spacing: 12) {
                            Text("Error: \(error)")
                                .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                                .foregroundColor(.red)
                                .accessibilityLabel("Error: \(error)")
                            Button("Retry") {
                                errorMessage = nil
                                Task {
                                    await purchaseModel.fetchOfferings()
                                }
                            }
                            .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                            .foregroundColor(.white)
                            .frame(maxWidth: min(geometry.size.width * 0.8, 400)) // Cap button width
                            .padding()
                            .background(.black)
                            .cornerRadius(8)
                            .accessibilityLabel("Retry fetching offerings")
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32) // Adjust for iPad
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
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600)) // Cap button width
                            
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
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600)) // Cap button width
                        }
                        .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad
                    } else {
                        ProgressView()
                            .padding()
                            .accessibilityLabel("Loading purchase options")
                    }
                    
                    // Free trial toggle, cancel anytime text, and purchase button
                    VStack(spacing: 8) {
                        // Free Trial Enabled Card
                        HStack {
                            Text("Free Trial Enabled")
                                .font(.system(.headline, design: .default, weight: .bold)) // Dynamic type
                                .foregroundColor(.black)
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
                        .frame(maxWidth: min(geometry.size.width * 0.9, 600)) // Cap width
                        .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad
                        .padding(.top, 16)
                        
                        // No Commitment - Cancel Anytime
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                                .foregroundColor(.blue)
                            Text("No Commitment - Cancel Anytime")
                                .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad
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
                            .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                            .foregroundColor(.white)
                            .frame(maxWidth: min(geometry.size.width * 0.8, 400)) // Cap button width
                            .padding()
                            .background(selectedPackage == nil || isPurchasing ? Color.gray : Color.blue)
                            .cornerRadius(10)
                        }
                        .disabled(selectedPackage == nil || isPurchasing)
                        .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad
                        .accessibilityLabel(isPurchasing ? "Processing purchase" : "Unlock Fathr Now")
                        
                        if isPurchasing {
                            ProgressView()
                                .padding(.top, 8)
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
                        .font(.system(.caption, design: .default, weight: .regular)) // Dynamic type
                        .foregroundColor(.gray)
                        .accessibilityLabel("Restore Purchases")
                        
                        Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            .font(.system(.caption, design: .default, weight: .regular)) // Dynamic type
                            .foregroundColor(.gray)
                            .accessibilityLabel("Terms of Use")
                        
                        Link("Privacy Policy", destination: URL(string: "https://www.fathr.xyz/r/privacy")!)
                            .font(.system(.caption, design: .default, weight: .regular)) // Dynamic type
                            .foregroundColor(.gray)
                            .accessibilityLabel("Privacy Policy")
                    }
                    .padding(.top, 16)
                    .padding(.bottom, geometry.size.width > 600 ? 24 : 8) // Adjust for iPad
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, geometry.size.width > 600 ? 40 : 24) // Adjust vertical padding
                .background(Color.white.ignoresSafeArea())
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
}

struct FeatureRow: View {
    let text: String
    let subtext: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(text)
                    .font(.system(.subheadline, design: .default, weight: .bold)) // Dynamic type
                Text(subtext)
                    .font(.system(.caption, design: .default, weight: .regular)) // Dynamic type
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
                            .font(.system(.headline, design: .default, weight: .semibold)) // Dynamic type
                        if let crossedOutPrice = crossedOutPrice {
                            HStack(spacing: 4) {
                                Text(crossedOutPrice)
                                    .strikethrough()
                                    .foregroundColor(.gray)
                                Text(price)
                                    .fontWeight(.medium)
                            }
                            .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                        } else {
                            Text(price)
                                .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        if let badge = badgeText {
                            Text(badge)
                                .font(.system(.caption2, design: .default, weight: .bold)) // Dynamic type
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(isWeeklyPlan ? Color.green : Color.blue)
                                .cornerRadius(4)
                        }
                        
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(.title3, design: .default, weight: .regular)) // Dynamic type
                            .foregroundColor(isSelected ? .blue : .gray)
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
        .accessibilityLabel("\(title), \(price)\(badgeText != nil ? ", \(badgeText!)" : "")\(isSelected ? ", selected" : "")")
    }
}

#Preview("iPhone 14") {
    PurchaseView(isPresented: .constant(true), purchaseModel: PurchaseModel())
}

#Preview("iPad Pro") {
    PurchaseView(isPresented: .constant(true), purchaseModel: PurchaseModel())
}
