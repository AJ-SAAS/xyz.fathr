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
            Image(systemName: "person.2.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 20)
                .padding(.bottom, 16)
            
            // Headline
            Text("Ready to Build Your Family?")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
            
            // Subtext
            Text("Upgrade to unlock everything Fathr has to offer:")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            
            // Features list
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(text: "Track every test — no limits")
                FeatureRow(text: "Unlock your personalized fertility plan")
                FeatureRow(text: "Get full analysis of every sperm metric")
                FeatureRow(text: "Smart reminders and progress check-ins")
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            
            // Payment options or error state
            if let error = errorMessage ?? purchaseModel.errorMessage {
                VStack {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                    Button("Retry") {
                        purchaseModel.fetchOfferings()
                    }
                }
                .padding()
            } else if let offering = purchaseModel.currentOffering {
                VStack(spacing: 12) {
                    // Yearly Plan
                    PackageButton(
                        title: "Yearly Plan",
                        price: "$59.99 per year",
                        crossedOutPrice: "$311.48",
                        badgeText: "SAVE 90%",
                        isSelected: selectedPackage?.identifier == "yearly",
                        isWeeklyPlan: false,
                        action: {
                            if let yearly = offering.annual {
                                selectedPackage = yearly
                            }
                        }
                    )
                    
                    // Weekly Plan with Trial
                    PackageButton(
                        title: "3-Day Trial",
                        price: "then $5.99 per week",
                        badgeText: "FREE",
                        isSelected: selectedPackage?.identifier == "weekly",
                        isWeeklyPlan: true,
                        action: {
                            if let weekly = offering.monthly {
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
            
            // Free trial toggle and continue button
            VStack(spacing: 8) {
                // Free Trial Enabled Card (kept grey)
                HStack {
                    Text("Free Trial Enabled")
                        .font(.headline) // Made same size as plan titles
                        .fontWeight(.bold) // Made bold
                        .foregroundColor(.black) // Changed from gray to black
                    
                    Spacer()
                    
                    Toggle("", isOn: $freeTrialEnabled)
                        .labelsHidden()
                        .tint(.green)
                }
                .padding()
                .background(Color(.systemGray6)) // Kept grey background
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1) // Added light grey outline
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Continue button
                Button(action: {
                    if let package = selectedPackage {
                        isPurchasing = true
                        purchaseModel.purchase(package: package)
                    }
                }) {
                    HStack {
                        Text("Continue")
                        Image(systemName: "chevron.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
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
                    purchaseModel.restorePurchases()
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
            purchaseModel.fetchOfferings()
            if purchaseModel.currentOffering == nil {
                errorMessage = purchaseModel.errorMessage ?? "Failed to load offerings"
            }
        }
    }
}

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.blue)
            Text(text)
                .font(.subheadline)
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
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        if let crossedOutPrice = crossedOutPrice {
                            HStack(spacing: 4) {
                                Text(crossedOutPrice)
                                    .strikethrough()
                                    .foregroundColor(.gray)
                                Text(price)
                            }
                            .font(.subheadline)
                        } else {
                            Text(price)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    if let badgeText = badgeText {
                        if isWeeklyPlan {
                            // Special styling for weekly plan (FREE text)
                            Text(badgeText)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                        } else {
                            // Default badge styling for other plans (SAVE X%)
                            Text(badgeText)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .cornerRadius(4)
                        }
                    }
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    } else {
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .padding()
            .background(isSelected ? Color.white.opacity(0.9) : Color.white) // Changed to white background
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1) // Added light grey outline
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
