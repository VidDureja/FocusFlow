import Foundation

// MARK: - Authentication Models
struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let success: Bool
    let redirect: String?
    let error: String?
}

struct SessionRequest: Codable {
    let type: String
    let duration: Int
    let tag: String?
}

struct SessionResponse: Codable {
    let session_id: Int
}

struct CompleteSessionRequest: Codable {
    let comment: String?
}

struct AnalyticsResponse: Codable {
    let total_sessions: Int
    let completed_sessions: Int
    let total_minutes: Int
    let completion_rate: Double
    let daily_data: [String: DailyData]
    let pomodoro_sessions: Int?
    let deep_work_sessions: Int?
    let pomodoro_minutes: Int?
    let deep_work_minutes: Int?
}

struct DailyData: Codable {
    let sessions: Int
    let minutes: Int
    let pomodoro_sessions: Int?
    let deep_work_sessions: Int?
}

struct PremiumResponse: Codable {
    let success: Bool
} 