import SwiftUI
import FirebaseAuth
import RevenueCat

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel
    @State private var showingDeleteAccountAlert: Bool = false
    @State private var showingLogoutAlert: Bool = false
    @State private var showingPaywall: Bool = false
    @State private var isRestoring: Bool = false

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                List {
                    // MARK: - Account Section
                    Section(header: Text("Account")
                        .font(.system(.headline, design: .default, weight: .bold))) {
                        if let user = Auth.auth().currentUser {
                            Text("Email: \(user.email ?? "N/A")")
                                .font(.system(.body))
                                .padding(.vertical, 4)
                                .accessibilityLabel("Email: \(user.email ?? "Not available")")
                        }
                        NavigationLink("Manage Account") {
                            ManageAccountView()
                        }
                        .font(.system(.body))
                        .padding(.vertical, 4)
                        .accessibilityLabel("Manage Account")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)

                    // MARK: - Premium Section
                    Section(header: Text("Upgrade")
                        .font(.system(.headline, design: .default, weight: .bold))) {
                        if purchaseModel.isSubscribed {
                            Text("You’re a Premium Member 🎉")
                                .font(.system(.body))
                                .foregroundColor(.green)
                                .padding(.vertical, 4)
                                .accessibilityLabel("You are a Premium Member")
                        } else {
                            Button("Go Premium 🚀") {
                                showingPaywall = true
                            }
                            .font(.system(.body))
                            .foregroundColor(.blue)
                            .padding(.vertical, 4)
                            .accessibilityLabel("Go Premium")
                        }
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)

                    // MARK: - Support Section
                    Section(header: Text("Support")
                        .font(.system(.headline, design: .default, weight: .bold))) {
                        Link("Contact Support", destination: URL(string: "mailto:fathrapp@gmail.com")!)
                            .font(.system(.body))
                            .padding(.vertical, 4)
                            .accessibilityLabel("Contact Support via Email")

                        Link("Visit Our Website", destination: URL(string: "https://www.fathr.xyz")!)
                            .font(.system(.body))
                            .padding(.vertical, 4)
                            .accessibilityLabel("Visit Website")

                        // 🆕 Share Feedback button
                        Button(action: {
                            if let url = URL(string: "mailto:fathrapp@gmail.com?subject=Feedback%20on%20Fathr%20App") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Share Your Feedback 💬")
                                .font(.system(.body))
                                .foregroundColor(.blue)
                                .padding(.vertical, 4)
                        }
                        .accessibilityLabel("Share Your Feedback via Email")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)

                    // MARK: - Legal Section
                    Section(header: Text("Legal")
                        .font(.system(.headline, design: .default, weight: .bold))) {
                        Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            .font(.system(.body))
                            .padding(.vertical, 4)
                            .accessibilityLabel("Apple Terms of Use")

                        Link("Privacy Policy", destination: URL(string: "https://www.fathr.xyz/r/privacy")!)
                            .font(.system(.body))
                            .padding(.vertical, 4)
                            .accessibilityLabel("Privacy Policy")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)

                    // MARK: - In-App Purchases Section
                    Section(header: Text("In-App Purchases")
                        .font(.system(.headline, design: .default, weight: .bold))) {
                        Button(action: {
                            isRestoring = true
                            Task {
                                await purchaseModel.restorePurchases { _ in
                                    isRestoring = false
                                }
                            }
                        }) {
                            HStack {
                                Text("Restore Purchases")
                                    .font(.system(.body))
                                if isRestoring {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isRestoring)
                        .padding(.vertical, 4)
                        .accessibilityLabel("Restore Purchases")

                        Button(action: {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Manage Subscription")
                                .font(.system(.body))
                        }
                        .padding(.vertical, 4)
                        .accessibilityLabel("Manage Subscription")

                        if let error = purchaseModel.errorMessage {
                            Text("Error: \(error)")
                                .font(.system(.subheadline))
                                .foregroundColor(.red)
                                .padding(.vertical, 4)
                            Button("Retry Restore") {
                                isRestoring = true
                                Task {
                                    await purchaseModel.restorePurchases { _ in
                                        isRestoring = false
                                    }
                                }
                            }
                            .font(.system(.body))
                            .foregroundColor(.blue)
                            .padding(.vertical, 4)
                        }

                        if purchaseModel.isSubscribed {
                            Text("Premium Unlocked ✅")
                                .font(.system(.body))
                                .foregroundColor(.green)
                                .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)

                    // MARK: - Account Actions
                    Section(header: Text("Account Actions")
                        .font(.system(.headline, design: .default, weight: .bold))) {
                        Button("Log Out") {
                            showingLogoutAlert = true
                        }
                        .font(.system(.body))
                        .foregroundColor(.red)
                        .padding(.vertical, 4)
                        .alert("Log Out", isPresented: $showingLogoutAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Log Out", role: .destructive) {
                                authManager.signOut()
                            }
                        } message: {
                            Text("Are you sure you want to log out?")
                        }

                        Button("Delete Account") {
                            showingDeleteAccountAlert = true
                        }
                        .font(.system(.body))
                        .foregroundColor(.red)
                        .padding(.vertical, 4)
                        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Delete", role: .destructive) {
                                deleteAccount()
                            }
                        } message: {
                            Text("This will permanently delete your account and all associated data. Are you sure?")
                        }
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)

                    // MARK: - App Info
                    Section(header: Text("App Info")
                        .font(.system(.headline, design: .default, weight: .bold))) {
                        Text("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.5")")
                            .font(.system(.body))
                            .padding(.vertical, 4)
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                }
                .navigationTitle("Settings")
                .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
                .sheet(isPresented: $showingPaywall) {
                    PurchaseView(isPresented: $showingPaywall, purchaseModel: purchaseModel)
                }
                .task {
                    await purchaseModel.fetchOfferings()
                }
                .background(Color.white.ignoresSafeArea())
            }
        }
    }

    // MARK: - Delete Account
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            authManager.errorMessage = "No user logged in"
            return
        }

        testStore.deleteAllTestsForUser(userId: user.uid) { success in
            if success {
                authManager.deleteAccount { error in
                    if let error = error {
                        DispatchQueue.main.async {
                            authManager.errorMessage = "Failed to delete account: \(error.localizedDescription)"
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    authManager.errorMessage = "Failed to delete user data"
                }
            }
        }
    }
}

#Preview("iPhone 14") {
    SettingsView()
        .environmentObject(AuthManager())
        .environmentObject(TestStore())
        .environmentObject(PurchaseModel())
}

#Preview("iPad Pro") {
    SettingsView()
        .environmentObject(AuthManager())
        .environmentObject(TestStore())
        .environmentObject(PurchaseModel())
}

