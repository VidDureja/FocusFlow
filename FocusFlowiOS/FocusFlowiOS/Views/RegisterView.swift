import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
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
                            Text("Create your account")
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13)) // Gray-900
                            
                            // Subtitle
                            Text("Start your productivity journey with FocusFlow")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45)) // Gray-600
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        
                        // Form
                        VStack(spacing: 20) {
                            // Username Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38)) // Gray-700
                                
                                TextField("Choose a unique username", text: $username)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38)) // Gray-700
                                
                                TextField("your@email.com", text: $email)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .keyboardType(.emailAddress)
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38)) // Gray-700
                                
                                SecureField("At least 6 characters", text: $password)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Confirm Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38)) // Gray-700
                                
                                SecureField("Repeat your password", text: $confirmPassword)
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
                        
                        // Create Account Button
                        Button(action: {
                            Task {
                                await performRegister()
                            }
                        }) {
                            HStack(spacing: 8) {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "person.badge.plus")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text("Create Account")
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
                        
                        // Sign In Link
                        HStack {
                            Text("Already have an account?")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45)) // Gray-600
                            
                            Button("Sign in here") {
                                dismiss()
                            }
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(Color(red: 0.58, green: 0.2, blue: 0.92)) // Purple-600
                        }
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
    }
    
    private var isFormValid: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty && 
        password == confirmPassword && password.count >= 6
    }
    
    private func performRegister() async {
        do {
            try await authManager.register(username: username, email: email, password: password)
            dismiss()
        } catch {
            await MainActor.run {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
}

// Custom TextField Style to match PWA design
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(red: 0.8, green: 0.8, blue: 0.8), lineWidth: 1) // Gray-300
            )
            .cornerRadius(8)
            .font(.system(size: 14, weight: .regular, design: .default))
            .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13)) // Gray-900
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthManager())
} 