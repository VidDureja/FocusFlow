import Foundation

// MARK: - Session Models
enum SessionType: String, CaseIterable {
    case pomodoro = "pomodoro"
    case deepWork = "deep_work"
    case shortBreak = "break"
    case mediumBreak = "break"
    
    var displayName: String {
        switch self {
        case .pomodoro: return "Pomodoro"
        case .deepWork: return "Deep Work"
        case .shortBreak: return "Short Break"
        case .mediumBreak: return "Medium Break"
        }
    }
    
    var duration: Int {
        switch self {
        case .pomodoro: return 25
        case .deepWork: return 90
        case .shortBreak: return 5
        case .mediumBreak: return 10
        }
    }
    
    var color: String {
        switch self {
        case .pomodoro: return "purple"
        case .deepWork: return "blue"
        case .shortBreak: return "green"
        case .mediumBreak: return "yellow"
        }
    }
}

struct TimerSession {
    let id: Int
    let type: SessionType
    let duration: Int
    let startTime: Date
    var endTime: Date?
    var isCompleted: Bool = false
    var comment: String?
}

struct User {
    let username: String
    let email: String
    var isPremium: Bool = false
} 