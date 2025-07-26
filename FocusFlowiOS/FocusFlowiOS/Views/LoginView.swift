import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isRegistering = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            // Logo
                            Image(systemName: "clock.fill")
                                .font(.system(size: 48))
                                .foregroundColor(Color(red: 0.58, green: 0.2, blue: 0.92)) // Purple-600
                            
                            // Title
                            Text("FocusFlow")
                                .font(.system(size: 32, weight: .bold, design: .default))
                                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13)) // Gray-900
                            
                            // Subtitle
                            Text("Boost your productivity")
                                .font(.system(size: 16, weight: .regular, design: .default))
                                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45)) // Gray-600
                        }
                        .padding(.top, 40)
                        
                        // Form
                        VStack(spacing: 20) {
                            // Username Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38)) // Gray-700
                                
                                TextField("Enter username", text: $username)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38)) // Gray-700
                                
                                SecureField("Enter password", text: $password)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Error Message
                        if !alertMessage.isEmpty {
                            Text(alertMessage)
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(Color(red: 0.86, green: 0.2, blue: 0.2)) // Red-600
                                .padding(.horizontal, 24)
                        }
                        
                        // Login Button
                        Button(action: {
                            Task {
                                await performLogin()
                            }
                        }) {
                            HStack(spacing: 8) {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text("Login")
                                        .font(.system(size: 14, weight: .medium, design: .default))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                isFormValid ? 
                                Color(red: 0.58, green: 0.2, blue: 0.92) : // Purple-600
                                Color(red: 0.8, green: 0.8, blue: 0.8) // Gray-300
                            )
                            .cornerRadius(8)
                        }
                        .disabled(authManager.isLoading || !isFormValid)
                        .padding(.horizontal, 24)
                        
                        // Create Account Button
                        Button("Create Account") {
                            isRegistering = true
                        }
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundColor(Color(red: 0.58, green: 0.2, blue: 0.92)) // Purple-600
                        .padding(.top, 8)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $isRegistering) {
            RegisterView()
                .environmentObject(authManager)
        }
    }
    
    private var isFormValid: Bool {
        !username.isEmpty && !password.isEmpty
    }
    
    private func performLogin() async {
        do {
            try await authManager.login(username: username, password: password)
        } catch {
            await MainActor.run {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
} 