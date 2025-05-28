import SwiftUI
import FirebaseAuth
import RevenueCat

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var purchaseModel: PurchaseModel
    @State private var showingDeleteAccountAlert = false
    @State private var showingLogoutAlert = false
    @State private var showingPaywall = false
    @State private var isRestoring = false

    var body: some View {
        NavigationStack {
            List {
                // Account Section
                Section(header: Text("Account")) {
                    if let user = Auth.auth().currentUser {
                        Text("Email: \(user.email ?? "N/A")")
                            .accessibilityLabel("Email: \(user.email ?? "Not available")")
                    }
                    NavigationLink("Manage Account") {
                        ManageAccountView()
                    }
                    .accessibilityLabel("Manage Account")
                }

                // Premium Section
                Section(header: Text("Upgrade")) {
                    if purchaseModel.isSubscribed {
                        Text("You’re a Premium Member 🎉")
                            .foregroundColor(.green)
                            .accessibilityLabel("You are a Premium Member")
                    } else {
                        Button("Go Premium 🚀") {
                            showingPaywall = true
                        }
                        .accessibilityLabel("Go Premium")
                    }
                }

                // Support Section
                Section(header: Text("Support")) {
                    Link("Contact Support", destination: URL(string: "mailto:fathrapp@gmail.com")!)
                        .accessibilityLabel("Contact Support via Email")
                    Link("Visit Our Website", destination: URL(string: "https://www.fathr.xyz")!)
                        .accessibilityLabel("Visit Website")
                }

                // Legal Section
                Section(header: Text("Legal")) {
                    Link("Terms of Use", destination: URL(string: "https://www.fathr.xyz/r/terms")!)
                        .accessibilityLabel("Terms of Service")
                    Link("Privacy Policy", destination: URL(string: "https://www.fathr.xyz/r/privacy")!)
                        .accessibilityLabel("Privacy Policy")
                }

                // In-App Purchases Section
                Section {
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
                            if isRestoring {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isRestoring)
                    .accessibilityLabel("Restore Purchases")

                    // New Manage Subscription Button
                    Button(action: {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }) {
                        Text("Manage Subscription")
                    }
                    .accessibilityLabel("Manage Subscription")

                    if let error = purchaseModel.errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                        Button("Retry Restore") {
                            isRestoring = true
                            Task {
                                await purchaseModel.restorePurchases { _ in
                                    isRestoring = false
                                }
                            }
                        }
                        .accessibilityLabel("Retry Restore Purchases")
                    }

                    if purchaseModel.isSubscribed {
                        Text("Premium Unlocked ✅")
                            .foregroundColor(.green)
                    }
                }

                // Account Actions
                Section {
                    Button("Log Out") {
                        showingLogoutAlert = true
                    }
                    .foregroundColor(.red)
                    .accessibilityLabel("Log Out")
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
                    .foregroundColor(.red)
                    .accessibilityLabel("Delete Account")
                    .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Delete", role: .destructive) {
                            deleteAccount()
                        }
                    } message: {
                        Text("This will permanently delete your account and all associated data. Are you sure?")
                    }
                }

                // App Info
                Section {
                    Text("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.5")")
                        .accessibilityLabel("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.5")")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPaywall) {
                PurchaseView(isPresented: $showingPaywall, purchaseModel: purchaseModel)
            }
            .task {
                await purchaseModel.fetchOfferings()
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthManager())
            .environmentObject(TestStore())
            .environmentObject(PurchaseModel())
    }
}
