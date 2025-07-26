//
//  ContentView.swift
//  FocusFlowiOS
//
//  Created by Vidhit Dureja on 7/24/25.
//

import SwiftUI

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