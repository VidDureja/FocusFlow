import SwiftUI

@main
struct FocusFlowiOSApp: App {
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isLoggedIn {
                DashboardView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            // Check if user is already logged in
            // This is handled by AuthManager init
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
} 