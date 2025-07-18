import Foundation

// MARK: - API Service
class APIService {
    static let shared = APIService()
    private let baseURL = "https://focusflow-449l.onrender.com"
    
    private init() {}
    
    // MARK: - Authentication
    func login(username: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(username: username, password: password)
        return try await performRequest(endpoint: "/login", method: "POST", body: request)
    }
    
    func register(username: String, email: String, password: String) async throws -> AuthResponse {
        let request = RegisterRequest(username: username, email: email, password: password)
        return try await performRequest(endpoint: "/register", method: "POST", body: request)
    }
    
    func logout() async throws {
        let _: EmptyResponse = try await performRequest(endpoint: "/logout", method: "GET")
    }
    
    // MARK: - Sessions
    func createSession(type: String, duration: Int, tag: String = "General") async throws -> SessionResponse {
        let request = SessionRequest(type: type, duration: duration, tag: tag)
        return try await performRequest(endpoint: "/api/session", method: "POST", body: request)
    }
    
    func completeSession(sessionId: Int, comment: String? = nil) async throws {
        let request = CompleteSessionRequest(comment: comment)
        let _: EmptyResponse = try await performRequest(endpoint: "/api/session/\(sessionId)/complete", method: "POST", body: request)
    }
    
    // MARK: - Analytics
    func getAnalytics() async throws -> AnalyticsResponse {
        return try await performRequest(endpoint: "/api/analytics", method: "GET")
    }
    
    // MARK: - Premium
    func upgradePremium() async throws -> PremiumResponse {
        return try await performRequest(endpoint: "/api/premium/upgrade", method: "POST")
    }
    
    // MARK: - Generic Request Helper
    private func performRequest<T: Codable, U: Codable>(endpoint: String, method: String, body: T? = nil) async throws -> U {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(U.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

// MARK: - Supporting Types
struct EmptyResponse: Codable {}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
} 