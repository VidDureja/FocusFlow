import Foundation

// MARK: - Authentication Manager
class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    
    @AppStorage("username") private var savedUsername: String = ""
    @AppStorage("isLoggedIn") private var savedLoginState: Bool = false
    
    init() {
        isLoggedIn = savedLoginState
        if isLoggedIn {
            // Restore user session
            currentUser = User(username: savedUsername, email: "")
        }
    }
    
    func login(username: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await APIService.shared.login(username: username, password: password)
            
            if response.success {
                await MainActor.run {
                    self.isLoggedIn = true
                    self.currentUser = User(username: username, email: "")
                    self.savedUsername = username
                    self.savedLoginState = true
                }
            } else {
                throw APIError.httpError(401)
            }
        } catch {
            throw error
        }
    }
    
    func register(username: String, email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await APIService.shared.register(username: username, email: email, password: password)
            
            if response.success {
                await MainActor.run {
                    self.isLoggedIn = true
                    self.currentUser = User(username: username, email: email)
                    self.savedUsername = username
                    self.savedLoginState = true
                }
            } else {
                throw APIError.httpError(400)
            }
        } catch {
            throw error
        }
    }
    
    func logout() async {
        do {
            try await APIService.shared.logout()
        } catch {
            print("Error during logout: \(error)")
        }
        
        await MainActor.run {
            self.isLoggedIn = false
            self.currentUser = nil
            self.savedUsername = ""
            self.savedLoginState = false
        }
    }
    
    func upgradePremium() async throws {
        do {
            let response = try await APIService.shared.upgradePremium()
            
            if response.success {
                await MainActor.run {
                    self.currentUser?.isPremium = true
                }
            }
        } catch {
            throw error
        }
    }
} 