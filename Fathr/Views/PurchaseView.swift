import SwiftUI
import RevenueCat

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
    @State private var showCloseButton: Bool = false // ✅ added

    private let fathrGreen = Color("#2ECC71")

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Image("fathr-blue-bg-2")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    // TOP HALF
                    VStack(spacing: 10) {
                        Image("fathr-plus-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: min(geometry.size.width * 0.45, 230))
                            .padding(.top, 60)

                        Text("Unlock the full experience and boost your chances of growing your family.")
                            .font(.custom("SFProDisplay-Black", size: 17))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(height: geometry.size.height * 0.45)

                    // BOTTOM HALF
                    VStack(spacing: 14) {
                        if let error = errorMessage ?? purchaseModel.errorMessage {
                            VStack(spacing: 8) {
                                Text("Error: \(error)")
                                    .font(.system(.subheadline))
                                    .foregroundColor(.red)
                                Button("Retry") {
                                    errorMessage = nil
                                    Task { await purchaseModel.fetchOfferings() }
                                }
                                .font(.system(.headline))
                                .foregroundColor(.white)
                                .padding()
                                .background(.black)
                                .cornerRadius(8)
                            }
                        } else if let offering = purchaseModel.currentOffering {
                            VStack(spacing: 12) {
                                // Yearly Plan
                                PackageButton(
                                    title: "Yearly",
                                    leftPrice: "$29.99",
                                    rightPrice: "$2.49 / month",
                                    isSelected: selectedPackage?.identifier == "yearly_pro",
                                    highlightColor: fathrGreen
                                ) {
                                    if let yearly = offering.package(identifier: "yearly_pro") {
                                        selectedPackage = yearly
                                    }
                                }
                                .frame(maxWidth: min(geometry.size.width * 0.85, 400))

                                // Weekly Plan
                                PackageButton(
                                    title: "Weekly",
                                    leftPrice: "$5.99",
                                    rightPrice: "$5.99 / week",
                                    isSelected: selectedPackage?.identifier == "weekly_pro_trial",
                                    highlightColor: fathrGreen
                                ) {
                                    if let weekly = offering.package(identifier: "weekly_pro_trial") {
                                        selectedPackage = weekly
                                    }
                                }
                                .frame(maxWidth: min(geometry.size.width * 0.85, 400))
                            }
                        } else {
                            ProgressView().padding()
                        }

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
                                Text(isPurchasing ? "Processing..." : "Start my free trial")
                                    .font(.system(size: 18, weight: .semibold))
                                if !isPurchasing {
                                    Image(systemName: "chevron.right")
                                }
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

                        Text("3-day trial, cancel anytime.")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .padding(.top, 8)

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
                            .foregroundColor(Color.white.opacity(0.7))

                            Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                                .font(.caption)
                                .foregroundColor(Color.white.opacity(0.7))

                            Link("Privacy Policy", destination: URL(string: "https://www.fathr.xyz/r/privacy")!)
                                .font(.caption)
                                .foregroundColor(Color.white.opacity(0.7))
                        }
                        .padding(.bottom, 22)
                    }
                    .frame(height: geometry.size.height * 0.55)
                }

                // ✅ X Close Button (appears after 2s, top-left)
                if showCloseButton {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white) // <-- changed to white
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(Color(white: 0.85).opacity(0.5)) // 50% transparent light grey background
                            )
                    }
                    .padding(.top, 30) // closer to top
                    .padding(.leading, 16) // closer to left
                    .transition(.scale.combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.35), value: showCloseButton)
                }
            }
            .onAppear {
                Task {
                    await purchaseModel.fetchOfferings()
                    if let offering = purchaseModel.currentOffering {
                        selectedPackage = offering.package(identifier: "weekly_pro_trial")
                    }
                    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2s delay
                    withAnimation { showCloseButton = true }
                }
            }
            .onChange(of: purchaseModel.isSubscribed) { _, newValue in
                if newValue { isPresented = false }
            }
        }
    }
}

// MARK: - Package Button
struct PackageButton: View {
    var title: String
    var leftPrice: String
    var rightPrice: String
    var isSelected: Bool
    var highlightColor: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                // ✅ Checkmark
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .bold))
                    }
                } else {
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 1.2)
                        .frame(width: 22, height: 22)
                }

                Text("\(title) - \(leftPrice)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Text(rightPrice)
                    .font(.system(size: 14))
                    .foregroundColor(Color.white.opacity(0.6))
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? highlightColor : Color.white.opacity(0.3),
                            lineWidth: isSelected ? 3.0 : 1.5)
            )
            .shadow(color: isSelected ? highlightColor.opacity(0.25) : Color.clear,
                    radius: isSelected ? 8 : 0, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

