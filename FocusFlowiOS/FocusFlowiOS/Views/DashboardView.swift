import SwiftUI

struct DashboardView: View {
    @StateObject private var timerManager = TimerManager()
    @EnvironmentObject var authManager: AuthManager
    @State private var showingSessionReview = false
    @State private var sessionComment = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.98, green: 0.98, blue: 0.98).ignoresSafeArea() // Gray-50
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Timer Display Card
                        VStack(spacing: 24) {
                            // Timer Title
                            Text("Focus Timer")
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13)) // Gray-900
                            
                            // Timer Display
                            Text(timerManager.timeString)
                                .font(.system(size: 64, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.58, green: 0.2, blue: 0.92)) // Purple-600
                                .padding(.vertical, 8)
                            
                            // Progress Bar
                            ProgressView(value: timerManager.progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.58, green: 0.2, blue: 0.92)))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                                .padding(.horizontal, 24)
                            
                            // Timer Controls
                            HStack(spacing: 16) {
                                Button(action: {
                                    if timerManager.isRunning {
                                        timerManager.pauseTimer()
                                    } else {
                                        Task {
                                            await timerManager.startTimer()
                                        }
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                                            .font(.system(size: 16, weight: .medium))
                                        Text(timerManager.isRunning ? "Pause" : "Start")
                                            .font(.system(size: 14, weight: .medium, design: .default))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(
                                        timerManager.isRunning ? 
                                        Color(red: 0.96, green: 0.58, blue: 0.2) : // Orange-500
                                        Color(red: 0.2, green: 0.78, blue: 0.35) // Green-500
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    timerManager.stopTimer()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "stop.fill")
                                            .font(.system(size: 16, weight: .medium))
                                        Text("Reset")
                                            .font(.system(size: 14, weight: .medium, design: .default))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color(red: 0.86, green: 0.2, blue: 0.2)) // Red-600
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        
                        // Session Type Selection
                        VStack(spacing: 20) {
                            Text("Choose Your Focus Method")
                                .font(.system(size: 20, weight: .semibold, design: .default))
                                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13)) // Gray-900
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach([SessionType.pomodoro, SessionType.deepWork], id: \.self) { sessionType in
                                    SessionTypeCard(
                                        sessionType: sessionType,
                                        isSelected: timerManager.selectedSessionType == sessionType,
                                        onTap: {
                                            timerManager.selectSessionType(sessionType)
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Break Options
                        VStack(spacing: 16) {
                            Text("Break Options")
                                .font(.system(size: 20, weight: .semibold, design: .default))
                                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13)) // Gray-900
                            
                            HStack(spacing: 16) {
                                ForEach([SessionType.shortBreak, SessionType.mediumBreak], id: \.self) { breakType in
                                    Button(action: {
                                        timerManager.selectSessionType(breakType)
                                    }) {
                                        Text(breakType.displayName)
                                            .font(.system(size: 14, weight: .medium, design: .default))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 44)
                                            .background(
                                                breakType == .shortBreak ? 
                                                Color(red: 0.2, green: 0.78, blue: 0.35) : // Green-500
                                                Color(red: 0.96, green: 0.78, blue: 0.2) // Yellow-500
                                            )
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.horizontal, 16)
                        
                        // Session Status
                        Text(timerManager.isRunning ? "Session in progress..." : "Ready to start \(timerManager.selectedSessionType.displayName) session")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45)) // Gray-600
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        NavigationLink("Analytics") {
                            AnalyticsView()
                        }
                        NavigationLink("Premium") {
                            PremiumView()
                        }
                        Button("Logout") {
                            Task {
                                await authManager.logout()
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(Color(red: 0.58, green: 0.2, blue: 0.92)) // Purple-600
                    }
                }
            }
            .sheet(isPresented: $showingSessionReview) {
                SessionReviewView(comment: $sessionComment) {
                    Task {
                        await timerManager.completeSession(comment: sessionComment.isEmpty ? nil : sessionComment)
                        sessionComment = ""
                    }
                }
            }
            .onReceive(timerManager.$timeRemaining) { timeRemaining in
                if timeRemaining == 0 && timerManager.isRunning {
                    showingSessionReview = true
                }
            }
        }
    }
}

struct SessionTypeCard: View {
    let sessionType: SessionType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: sessionType == .pomodoro ? "clock.fill" : "brain.head.profile")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                
                Text(sessionType.displayName)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Text("\(sessionType.duration) minutes")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Text(sessionType == .pomodoro ? "Perfect for quick tasks" : "Ideal for complex projects")
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(
                LinearGradient(
                    colors: sessionType == .pomodoro ? 
                    [Color(red: 0.58, green: 0.2, blue: 0.92), Color(red: 0.58, green: 0.2, blue: 0.92).opacity(0.8)] : // Purple gradient
                    [Color(red: 0.2, green: 0.58, blue: 0.92), Color(red: 0.2, green: 0.58, blue: 0.92).opacity(0.8)], // Blue gradient
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthManager())
} 