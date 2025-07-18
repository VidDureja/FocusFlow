import Foundation
import Combine

// MARK: - Timer Manager
class TimerManager: ObservableObject {
    @Published var timeRemaining: Int = 25 * 60 // Default 25 minutes
    @Published var isRunning: Bool = false
    @Published var currentSession: TimerSession?
    @Published var selectedSessionType: SessionType = .pomodoro
    
    private var timer: Timer?
    private var sessionId: Int?
    
    init() {
        timeRemaining = selectedSessionType.duration * 60
    }
    
    func selectSessionType(_ type: SessionType) {
        selectedSessionType = type
        timeRemaining = type.duration * 60
        stopTimer()
    }
    
    func startTimer() async {
        guard !isRunning else { return }
        
        do {
            let response = try await APIService.shared.createSession(
                type: selectedSessionType.rawValue,
                duration: selectedSessionType.duration
            )
            
            sessionId = response.session_id
            currentSession = TimerSession(
                id: response.session_id,
                type: selectedSessionType,
                duration: selectedSessionType.duration,
                startTime: Date()
            )
            
            isRunning = true
            startCountdown()
        } catch {
            print("Error starting session: \(error)")
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        timeRemaining = selectedSessionType.duration * 60
        sessionId = nil
        currentSession = nil
    }
    
    func completeSession(comment: String? = nil) async {
        guard let sessionId = sessionId else { return }
        
        do {
            try await APIService.shared.completeSession(sessionId: sessionId, comment: comment)
            stopTimer()
        } catch {
            print("Error completing session: \(error)")
        }
    }
    
    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timerCompleted()
            }
        }
    }
    
    private func timerCompleted() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // Auto-complete the session
        Task {
            await completeSession()
        }
    }
    
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var progress: Double {
        let totalTime = selectedSessionType.duration * 60
        return Double(totalTime - timeRemaining) / Double(totalTime)
    }
} 