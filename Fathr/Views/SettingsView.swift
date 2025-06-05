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
                    // Account Section
                    Section(header: Text("Account")
                                .font(.system(.headline, design: .default, weight: .bold))) { // Dynamic type
                        if let user = Auth.auth().currentUser {
                            Text("Email: \(user.email ?? "N/A")")
                                .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                                .padding(.vertical, 4)
                                .accessibilityLabel("Email: \(user.email ?? "Not available")")
                        }
                        NavigationLink("Manage Account") {
                            ManageAccountView()
                        }
                        .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                        .padding(.vertical, 4)
                        .accessibilityLabel("Manage Account")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad

                    // Premium Section
                    Section(header: Text("Upgrade")
                                .font(.system(.headline, design: .default, weight: .bold))) { // Dynamic type
                        if purchaseModel.isSubscribed {
                            Text("You’re a Premium Member 🎉")
                                .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                                .foregroundColor(.green)
                                .padding(.vertical, 4)
                                .accessibilityLabel("You are a Premium Member")
                        } else {
                            Button("Go Premium 🚀") {
                                showingPaywall = true
                            }
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                            .foregroundColor(.blue)
                            .padding(.vertical, 4)
                            .accessibilityLabel("Go Premium")
                        }
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad

                    // Support Section
                    Section(header: Text("Support")
                                .font(.system(.headline, design: .default, weight: .bold))) { // Dynamic type
                        Link("Contact Support", destination: URL(string: "mailto:fathrapp@gmail.com")!)
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                            .padding(.vertical, 4)
                            .accessibilityLabel("Contact Support via Email")
                        Link("Visit Our Website", destination: URL(string: "https://www.fathr.xyz")!)
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                            .padding(.vertical, 4)
                            .accessibilityLabel("Visit Website")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad

                    // Legal Section
                    Section(header: Text("Legal")
                                .font(.system(.headline, design: .default, weight: .bold))) { // Dynamic type
                        Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                            .padding(.vertical, 4)
                            .accessibilityLabel("Apple Terms of Use")
                        Link("Privacy Policy", destination: URL(string: "https://www.fathr.xyz/r/privacy")!)
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                            .padding(.vertical, 4)
                            .accessibilityLabel("Privacy Policy")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad

                    // In-App Purchases Section
                    Section(header: Text("In-App Purchases")
                                .font(.system(.headline, design: .default, weight: .bold))) { // Dynamic type
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
                                    .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
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
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }) {
                            Text("Manage Subscription")
                                .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                        }
                        .padding(.vertical, 4)
                        .accessibilityLabel("Manage Subscription")

                        if let error = purchaseModel.errorMessage {
                            Text("Error: \(error)")
                                .font(.system(.subheadline, design: .default, weight: .regular)) // Dynamic type
                                .foregroundColor(.red)
                                .padding(.vertical, 4)
                                .accessibilityLabel("Error: \(error)")
                            Button("Retry Restore") {
                                isRestoring = true
                                Task {
                                    await purchaseModel.restorePurchases { _ in
                                        isRestoring = false
                                    }
                                }
                            }
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                            .foregroundColor(.blue)
                            .padding(.vertical, 4)
                            .accessibilityLabel("Retry Restore Purchases")
                        }

                        if purchaseModel.isSubscribed {
                            Text("Premium Unlocked ✅")
                                .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                                .foregroundColor(.green)
                                .padding(.vertical, 4)
                                .accessibilityLabel("Premium Unlocked")
                        }
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad

                    // Account Actions
                    Section(header: Text("Account Actions")
                                .font(.system(.headline, design: .default, weight: .bold))) { // Dynamic type
                        Button("Log Out") {
                            showingLogoutAlert = true
                        }
                        .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                        .foregroundColor(.red)
                        .padding(.vertical, 4)
                        .accessibilityLabel("Log Out")
                        .alert("Log Out", isPresented: $showingLogoutAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Log Out", role: .destructive) {
                                authManager.signOut()
                            }
                        } message: {
                            Text("Are you sure you want to log out?")
                                .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                        }

                        Button("Delete Account") {
                            showingDeleteAccountAlert = true
                        }
                        .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                        .foregroundColor(.red)
                        .padding(.vertical, 4)
                        .accessibilityLabel("Delete Account")
                        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Delete", role: .destructive) {
                                deleteAccount()
                            }
                        } message: {
                            Text("This will permanently delete your account and all associated data. Are you sure?")
                                .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                        }
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad

                    // App Info
                    Section(header: Text("App Info")
                                .font(.system(.headline, design: .default, weight: .bold))) { // Dynamic type
                        Text("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.5")")
                            .font(.system(.body, design: .default, weight: .regular)) // Dynamic type
                            .padding(.vertical, 4)
                            .accessibilityLabel("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.5")")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16) // Adjust for iPad
                }
                .navigationTitle("Settings")
                .padding(.vertical, geometry.size.width > 600 ? 40 : 24) // Adjust vertical padding
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
