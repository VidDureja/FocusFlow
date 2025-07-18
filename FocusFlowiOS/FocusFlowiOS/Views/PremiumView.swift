import SwiftUI

struct PremiumView: View {
    @StateObject private var authManager = AuthManager()
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 15) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("Upgrade to Premium")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Unlock advanced features and boost your productivity")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Current Status
                    if let user = authManager.currentUser, user.isPremium {
                        VStack(spacing: 15) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            
                            Text("Premium Active")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Text("You have access to all premium features!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    } else {
                        // Premium Features
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Premium Features")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 15) {
                                FeatureRow(
                                    icon: "chart.bar.fill",
                                    title: "Advanced Analytics",
                                    description: "Detailed insights and progress tracking"
                                )
                                
                                FeatureRow(
                                    icon: "paintbrush.fill",
                                    title: "Custom Themes",
                                    description: "Personalize your app appearance"
                                )
                                
                                FeatureRow(
                                    icon: "bell.fill",
                                    title: "Smart Notifications",
                                    description: "Intelligent reminders and alerts"
                                )
                                
                                FeatureRow(
                                    icon: "icloud.fill",
                                    title: "Cloud Sync",
                                    description: "Sync data across all your devices"
                                )
                                
                                FeatureRow(
                                    icon: "doc.text.fill",
                                    title: "Export Reports",
                                    description: "Download detailed progress reports"
                                )
                            }
                        }
                        
                        // Pricing
                        VStack(spacing: 20) {
                            VStack(spacing: 10) {
                                Text("$9.99")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.purple)
                                
                                Text("per month")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                            
                            Button(action: {
                                Task {
                                    await upgradePremium()
                                }
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Upgrade Now")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(15)
                            }
                            .disabled(isLoading)
                            
                            Text("Cancel anytime • No commitment")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    }
                    
                    // Terms
                    VStack(spacing: 10) {
                        Text("Terms & Conditions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("By upgrading, you agree to our terms of service and privacy policy. Subscription will automatically renew unless cancelled.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.large)
            .alert("Upgrade", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func upgradePremium() async {
        isLoading = true
        
        do {
            try await authManager.upgradePremium()
            await MainActor.run {
                alertMessage = "Successfully upgraded to Premium!"
                showingAlert = true
            }
        } catch {
            await MainActor.run {
                alertMessage = "Upgrade failed: \(error.localizedDescription)"
                showingAlert = true
            }
        }
        
        isLoading = false
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.purple)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    PremiumView()
} 