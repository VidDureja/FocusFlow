//
//  ContentView.swift
//  FocusFlowiOS
//
//  Created by Vidhit Dureja on 7/24/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    
    var body: some View {
        Group {
            if isLoggedIn {
                Text("Dashboard - Logged In!")
                    .font(.title)
                    .foregroundColor(.green)
            } else {
                VStack(spacing: 20) {
                    Text("FocusFlow Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Button("Login") {
                        isLoggedIn = true
                    }
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
} 