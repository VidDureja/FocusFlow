import SwiftUI

struct DashboardView: View {
    @StateObject private var timerManager = TimerManager()
    @EnvironmentObject var authManager: AuthManager
    @State private var showingSessionReview = false
    @State private var sessionComment = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Timer Display
                    VStack(spacing: 20) {
                        Text("Focus Timer")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(timerManager.timeString)
                            .font(.system(size: 72, weight: .bold, design: .monospaced))
                            .foregroundColor(.purple)
                        
                        // Progress Bar
                        ProgressView(value: timerManager.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                            .padding(.horizontal)
                        
                        // Timer Controls
                        HStack(spacing: 20) {
                            Button(action: {
                                if timerManager.isRunning {
                                    timerManager.pauseTimer()
                                } else {
                                    Task {
                                        await timerManager.startTimer()
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                                    Text(timerManager.isRunning ? "Pause" : "Start")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(timerManager.isRunning ? Color.orange : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                timerManager.stopTimer()
                            }) {
                                HStack {
                                    Image(systemName: "stop.fill")
                                    Text("Reset")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    // Session Type Selection
                    VStack(spacing: 20) {
                        Text("Choose Your Focus Method")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
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
                    
                    // Break Options
                    VStack(spacing: 15) {
                        Text("Break Options")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 20) {
                            ForEach([SessionType.shortBreak, SessionType.mediumBreak], id: \.self) { breakType in
                                Button(action: {
                                    timerManager.selectSessionType(breakType)
                                }) {
                                    Text(breakType.displayName)
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(breakType == .shortBreak ? Color.green : Color.yellow)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Session Status
                    Text(timerManager.isRunning ? "Session in progress..." : "Ready to start \(timerManager.selectedSessionType.displayName) session")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
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
                Image(systemName: sessionType == .pomodoro ? "clock" : "brain")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                
                Text(sessionType.displayName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(sessionType.duration) minutes")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(sessionType == .pomodoro ? "Perfect for quick tasks" : "Ideal for complex projects")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: sessionType == .pomodoro ? [.purple, .purple.opacity(0.8)] : [.blue, .blue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DashboardView()
} 