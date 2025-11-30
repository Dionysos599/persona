import Foundation

struct LocalUser: Codable, Equatable {
    let username: String
    let passwordHash: String
    let createdAt: Date
}

@Observable
final class AuthService {
    static let shared = AuthService()
    
    private let usersKey = "registeredUsers"
    private let currentUserKey = "currentUser"
    
    private(set) var currentUser: LocalUser?
    
    var isLoggedIn: Bool {
        currentUser != nil
    }
    
    private init() {
        loadCurrentUser()
    }
    
    func register(username: String, password: String) -> Result<LocalUser, AuthError> {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedUsername.count >= 3 else {
            return .failure(.usernameTooShort)
        }
        
        guard password.count >= 6 else {
            return .failure(.passwordTooShort)
        }
        
        var users = loadUsers()
        
        if users.contains(where: { $0.username.lowercased() == trimmedUsername.lowercased() }) {
            return .failure(.usernameExists)
        }
        
        let newUser = LocalUser(
            username: trimmedUsername,
            passwordHash: hashPassword(password),
            createdAt: Date()
        )
        
        users.append(newUser)
        saveUsers(users)
        
        currentUser = newUser
        saveCurrentUser(newUser)
        
        return .success(newUser)
    }
    
    func login(username: String, password: String) -> Result<LocalUser, AuthError> {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let users = loadUsers()
        
        guard let user = users.first(where: { $0.username.lowercased() == trimmedUsername.lowercased() }) else {
            return .failure(.userNotFound)
        }
        
        guard user.passwordHash == hashPassword(password) else {
            return .failure(.wrongPassword)
        }
        
        currentUser = user
        saveCurrentUser(user)
        
        return .success(user)
    }
    
    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }
    
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        return data.base64EncodedString()
    }
    
    private func loadUsers() -> [LocalUser] {
        guard let data = UserDefaults.standard.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([LocalUser].self, from: data) else {
            return []
        }
        return users
    }
    
    private func saveUsers(_ users: [LocalUser]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }
    
    private func loadCurrentUser() {
        guard let data = UserDefaults.standard.data(forKey: currentUserKey),
              let user = try? JSONDecoder().decode(LocalUser.self, from: data) else {
            return
        }
        currentUser = user
    }
    
    private func saveCurrentUser(_ user: LocalUser) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: currentUserKey)
        }
    }
}

enum AuthError: LocalizedError {
    case usernameTooShort
    case passwordTooShort
    case usernameExists
    case userNotFound
    case wrongPassword
    
    var errorDescription: String? {
        switch self {
        case .usernameTooShort:
            return "用户名至少需要 3 个字符"
        case .passwordTooShort:
            return "密码至少需要 6 个字符"
        case .usernameExists:
            return "用户名已存在"
        case .userNotFound:
            return "用户不存在"
        case .wrongPassword:
            return "密码错误"
        }
    }
}

