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
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

struct PurchaseView: View {
    @Binding var isPresented: Bool
    @ObservedObject var purchaseModel: PurchaseModel
    @State private var isPurchasing: Bool = false
    @State private var selectedPackage: Package?
    @State private var errorMessage: String?
    @State private var showCloseButton: Bool = false

    private let fathrGreen = Color("#2ECC71")

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("fathr-blue-bg-2")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {

                    // MARK: - TOP
                    VStack(spacing: 14) {
                        Image("fathr-plus-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: min(geometry.size.width * 0.45, 230))
                            .padding(.top, 60)

                        Text("PREMIUM ACCESS")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 10) {
                            FeatureRow(text: "Understand sperm health instantly")
                            FeatureRow(text: "Track all tests with clear insights")
                            FeatureRow(text: "Ask AI any fertility question")
                            FeatureRow(text: "Remove all paywalls instantly")
                        }
                        .padding(.top, 6)
                        .padding(.horizontal, 40)
                    }
                    .frame(height: geometry.size.height * 0.45)

                    // MARK: - BOTTOM
                    VStack(spacing: 14) {

                        if let offering = purchaseModel.currentOffering {

                            VStack(spacing: 12) {

                                // MARK: - LIFETIME
                                PackageButton(
                                    title: "Lifetime Plan",
                                    leftPrice: "$17.99",
                                    rightPrice: "BEST VALUE",
                                    rightBackground: .red,
                                    isSelected: selectedPackage?.identifier == "lifetime_pro",
                                    highlightColor: fathrGreen
                                ) {
                                    Haptics.selection()
                                    selectedPackage = offering.package(identifier: "lifetime_pro")
                                }
                                .frame(maxWidth: min(geometry.size.width * 0.85, 400))

                                // MARK: - WEEKLY
                                PackageButton(
                                    title: "3-Day Trial",
                                    leftPrice: "then $5.99 per week",
                                    rightPrice: "SHORT TERM",
                                    rightBackground: .clear,
                                    isSelected: selectedPackage?.identifier == "weekly_pro_trial",
                                    highlightColor: fathrGreen
                                ) {
                                    Haptics.selection()
                                    selectedPackage = offering.package(identifier: "weekly_pro_trial")
                                }
                                .frame(maxWidth: min(geometry.size.width * 0.85, 400))
                            }

                            Text("NO PAYMENT REQUIRED TODAY")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.top, 6)
                        }

                        // MARK: - CTA
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
                            HStack {
                                Text(isPurchasing ? "Processing..." : "Subscribe & Continue >")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: min(geometry.size.width * 0.85, 400))
                            .padding(.vertical, 20)
                            .background(selectedPackage == nil || isPurchasing ? Color.gray : fathrGreen)
                            .cornerRadius(12)
                            .shadow(color: fathrGreen.opacity(0.4), radius: 10, x: 0, y: 4)
                        }
                        .disabled(selectedPackage == nil || isPurchasing)
                        .padding(.top, 10)

                        // MARK: - FOOTER
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
                            .foregroundColor(.white.opacity(0.7))

                            Link("Terms of Use",
                                 destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))

                            Link("Privacy Policy",
                                 destination: URL(string: "https://www.fathr.xyz/r/privacy")!)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.bottom, 22)
                    }
                    .frame(height: geometry.size.height * 0.55)
                }

                // MARK: - CLOSE BUTTON
                if showCloseButton {
                    Button { isPresented = false } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.5))
                            )
                    }
                    .position(x: 28, y: 44)
                }
            }
            .onAppear {
                Task {
                    await purchaseModel.fetchOfferings()
                    selectedPackage = purchaseModel.currentOffering?.package(identifier: "lifetime_pro")
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

// MARK: - Feature Row
struct FeatureRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white)
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
                        .foregroundColor(.white)

                    Text(leftPrice)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                HStack(spacing: 6) {
                    Text(rightPrice)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(rightBackground)
                        .cornerRadius(6)

                    Circle()
                        .fill(isSelected ? Color.green : Color.clear)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.4), lineWidth: isSelected ? 0 : 1.2)
                        )
                        .frame(width: 22, height: 22)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? highlightColor : Color.white.opacity(0.3),
                            lineWidth: isSelected ? 3 : 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

