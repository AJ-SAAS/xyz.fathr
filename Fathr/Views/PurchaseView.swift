import SwiftUI
import RevenueCat
import UIKit

// MARK: - Apple-style Haptics
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

// MARK: - Color Hex Extension
extension Color {
    init(_ hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a,r,g,b: UInt64
        switch hex.count {
        case 3:
            (a,r,g,b) = (255,(int>>8)*17,(int>>4 & 0xF)*17,(int & 0xF)*17)
        case 6:
            (a,r,g,b) = (255,int>>16,int>>8 & 0xFF,int & 0xFF)
        case 8:
            (a,r,g,b) = (int>>24,int>>16 & 0xFF,int>>8 & 0xFF,int & 0xFF)
        default:
            (a,r,g,b) = (255,0,0,0)
        }

        self.init(.sRGB,
                  red: Double(r)/255,
                  green: Double(g)/255,
                  blue: Double(b)/255,
                  opacity: Double(a)/255)
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

                    // TOP SECTION
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

                    // BOTTOM SECTION
                    VStack(spacing: 14) {

                        if let offering = purchaseModel.currentOffering {

                            let weeklyPackage = offering.weekly
                                ?? offering.availablePackages.first(where: { $0.storeProduct.productIdentifier == "fathr_weekly" })

                            let yearlyPackage = offering.annual
                                ?? offering.availablePackages.first(where: { $0.storeProduct.productIdentifier == "fathr_yearly" })

                            VStack(spacing: 12) {

                                if let weekly = weeklyPackage {
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
                                    .frame(maxWidth: min(geometry.size.width * 0.85, 400))
                                }

                                if let yearly = yearlyPackage {
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
                                    .frame(maxWidth: min(geometry.size.width * 0.85, 400))
                                }
                            }

                            Text("No commitment, cancel anytime.")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.top, 6)
                        }

                        // CTA BUTTON
                        Button {
                            guard let package = selectedPackage else { return }
                            Haptics.impact(.medium)
                            isPurchasing = true
                            Task {
                                await purchaseModel.purchase(package: package) { _ in
                                    isPurchasing = false
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

                        // FOOTER
                        HStack(spacing: 18) {
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

                            Link("Terms of Use",
                                 destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                                .font(.caption)
                                .foregroundColor(.gray)

                            Link("Privacy Policy",
                                 destination: URL(string: "https://www.fathr.xyz/r/privacy")!)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 22)
                    }
                    .frame(height: geometry.size.height * 0.55)
                }

                // CLOSE BUTTON
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
                        selectedPackage = offering.weekly
                            ?? offering.availablePackages.first(where: { $0.storeProduct.productIdentifier == "fathr_weekly" })
                    }

                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    withAnimation { showCloseButton = true }
                }
            }

            .onChange(of: purchaseModel.isSubscribed) { _, newValue in
                if newValue { isPresented = false }
            }
        }
    }
}

// MARK: - Feature Row (UNCHANGED)
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

                    // Only show badge if there's a real background colour
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
                        .fill(isSelected ? Color.blue : Color.clear)
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
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3),
                            lineWidth: isSelected ? 2 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
