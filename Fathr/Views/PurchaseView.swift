import SwiftUI
import RevenueCat

// MARK: - Haptics
enum Haptics {
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - Purchase View
struct PurchaseView: View {

    @Binding var isPresented: Bool
    @ObservedObject var purchaseModel: PurchaseModel

    @State private var isPurchasing = false
    @State private var selectedPackage: Package?
    @State private var showCloseButton = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top Section
                    VStack(spacing: 14) {
                        Image("fathr-white-blue")
                            .resizable()
                            .scaledToFit()
                            .frame(width: min(geometry.size.width * 0.45, 230))
                            .padding(.top, 60)

                        Text("PREMIUM ACCESS")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(.black)

                        VStack(alignment: .leading, spacing: 10) {
                            FeatureRow(text: "Instant health insights")
                            FeatureRow(text: "Track all tests easily")
                            FeatureRow(text: "AI answers your questions")
                            FeatureRow(text: "Unlock the 74-day challenge")
                            FeatureRow(text: "Remove all paywalls")
                        }
                        .padding(.top, 6)
                        .padding(.horizontal, 40)
                    }
                    .frame(height: geometry.size.height * 0.45)

                    // Bottom Section
                    VStack(spacing: 14) {
                        if let offering = purchaseModel.currentOffering {
                            let weekly = offering.weekly ?? offering.availablePackages.first
                            let yearly = offering.annual

                            VStack(spacing: 12) {
                                if let weekly = weekly {
                                    PackageButton(
                                        title: "Weekly Plan",
                                        leftPrice: weekly.storeProduct.localizedPriceString + " per week",
                                        rightPrice: "FLEXIBLE",
                                        rightBackground: .clear,
                                        isSelected: selectedPackage?.identifier == weekly.identifier,
                                        highlightColor: .blue
                                    ) {
                                        Haptics.selection()
                                        selectedPackage = weekly
                                    }
                                }

                                if let yearly = yearly {
                                    PackageButton(
                                        title: "Yearly Plan",
                                        leftPrice: yearly.storeProduct.localizedPriceString + " per year",
                                        rightPrice: "BEST VALUE",
                                        rightBackground: .red,
                                        isSelected: selectedPackage?.identifier == yearly.identifier,
                                        highlightColor: .blue
                                    ) {
                                        Haptics.selection()
                                        selectedPackage = yearly
                                    }
                                }
                            }
                            .frame(maxWidth: min(geometry.size.width * 0.85, 400))

                            Text("No commitment, cancel anytime.")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.top, 6)
                        }

                        // CTA Button
                        Button {
                            guard let package = selectedPackage else { return }
                            Haptics.impact(.medium)
                            isPurchasing = true
                            
                            Task {
                                let success = await purchaseModel.purchase(package: package)
                                await MainActor.run {
                                    isPurchasing = false
                                    if success {
                                        isPresented = false   // This will dismiss paywall
                                    }
                                }
                            }
                        } label: {
                            Text(isPurchasing ? "Processing..." : "Continue")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: min(geometry.size.width * 0.85, 400))
                                .padding(.vertical, 20)
                                .background(selectedPackage == nil || isPurchasing ? Color.gray : Color.black)
                                .cornerRadius(12)
                        }
                        .disabled(selectedPackage == nil || isPurchasing)
                        .padding(.top, 10)

                        // Footer
                        HStack(spacing: 18) {
                            Button("Restore Purchases") {
                                isPurchasing = true
                                Task {
                                    let success = await purchaseModel.restorePurchases()
                                    await MainActor.run {
                                        isPurchasing = false
                                        if success {
                                            isPresented = false   // Dismiss after restore
                                        }
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
                        .padding(.bottom, 22)
                    }
                    .frame(height: geometry.size.height * 0.55)
                }

                // Close Button
                if showCloseButton {
                    Button { isPresented = false } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(Color.black.opacity(0.08)))
                    }
                    .position(x: 28, y: 44)
                }
            }
            .onAppear {
                Task {
                    await purchaseModel.fetchOfferings()

                    if let offering = purchaseModel.currentOffering {
                        selectedPackage = offering.weekly ?? offering.availablePackages.first
                    }

                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    withAnimation { showCloseButton = true }
                }
            }
            .onChange(of: purchaseModel.isSubscribed) { _, newValue in
                if newValue {
                    isPresented = false
                }
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.blue)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.black)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Package Button
struct PackageButton: View {
    var title: String
    var leftPrice: String
    var rightPrice: String
    var rightBackground: Color
    var isSelected: Bool
    var highlightColor: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    Text(leftPrice)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                }

                Spacer()

                HStack(spacing: 6) {
                    if rightBackground != .clear {
                        Text(rightPrice)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(rightBackground)
                            .cornerRadius(6)
                    }

                    Circle()
                        .fill(isSelected ? highlightColor : Color.clear)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.4), lineWidth: isSelected ? 0 : 1.2)
                        )
                        .frame(width: 22, height: 22)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .opacity(isSelected ? 1 : 0)
                        )
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.06) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? highlightColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
