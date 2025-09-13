import Foundation
import FirebaseAuth

final class UserUseCase: UserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    private let storageService: StorageServiceProtocol
    
    init(repository: UserRepositoryProtocol, storageService: StorageServiceProtocol) {
        self.repository = repository
        self.storageService = storageService
    }
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String, rememberMe: Bool) async throws -> Bool {
        do {
            let user = try await repository.authenticateUser(email: email, password: password)
            
            // Сохраняем данные пользователя локально
            try storageService.save(user, forKey: "currentUser")
            try storageService.save(rememberMe, forKey: "rememberMe")
            
            return true
        } catch {
            throw error
        }
    }
    
    func loginWithApple() async throws -> Bool {
        // Для MVP пока не реализуем Apple Sign In
        throw UseCaseError.businessLogicError("Apple Sign In не реализован в MVP версии")
    }
    
    func loginWithGoogle() async throws -> Bool {
        // Для MVP пока не реализуем Google Sign In
        throw UseCaseError.businessLogicError("Google Sign In не реализован в MVP версии")
    }
    
    func register(email: String, password: String, name: String) async throws -> Bool {
        do {
            let user = try await repository.registerUser(email: email, password: password, name: name)
            
            // Сохраняем пользователя локально
            try storageService.save(user, forKey: "currentUser")
            
            // Автоматически входим после регистрации
            return true
        } catch {
            throw error
        }
    }
    
    func registerWithRole(email: String, password: String, name: String, role: UserRole) async throws -> User {
        do {
            let user = try await repository.registerUserWithRole(email: email, password: password, name: name, role: role)
            
            // Сохраняем пользователя локально
            try storageService.save(user, forKey: "currentUser")
            
            return user
        } catch {
            throw error
        }
    }
    
    func sendPasswordResetEmail(email: String) async throws -> Bool {
        // Для MVP пока не реализуем
        throw UseCaseError.businessLogicError("Восстановление пароля не реализовано в MVP версии")
    }
    
    func logout() async throws {
        // Очищаем локальные данные
        storageService.remove(forKey: "currentUser")
        storageService.remove(forKey: "rememberMe")
    }
    
    func validateSession() async throws -> Bool {
        // Проверяем локальные данные
        guard let _: User = try? storageService.load(forKey: "currentUser") else {
            return false
        }
        return true
    }
    
    func authenticateWithBiometrics() async throws -> Bool {
        // Для MVP пока не реализуем биометрию
        throw UseCaseError.businessLogicError("Биометрическая аутентификация не реализована в MVP версии")
    }
    
    func getUserProfile() async throws -> User {
        // Сначала пытаемся получить из локального хранилища
        if let user: User = try? storageService.load(forKey: "currentUser") {
            return user
        }
        
        // Если локально нет, создаем демо-пользователя для MVP
        // В будущем здесь будет интеграция с Firebase Auth
        let demoUser = User(
            id: "demo-user-id",
            email: "demo@example.com",
            name: "Демо Пользователь",
            role: .client,
            phoneNumber: nil,
            profileImageURL: nil,
            createdAt: Date(),
            lastLoginAt: Date(),
            restaurantId: nil,
            isVerified: false,
            subscriptionPlan: nil,
            preferences: nil,
            favoriteRestaurants: nil
        )
        
        // Сохраняем локально для будущего использования
        try? storageService.save(demoUser, forKey: "currentUser")
        
        return demoUser
    }
    
    func updateUserProfile(_ user: User) async throws -> User {
        do {
            return try await repository.updateUser(user)
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    func updateUserPreferences(_ preferences: UserPreferences) async throws -> User {
        var currentUser = try await getUserProfile()
        currentUser = User(
            id: currentUser.id,
            email: currentUser.email,
            name: currentUser.name,
            role: currentUser.role,
            phoneNumber: currentUser.phoneNumber,
            profileImageURL: currentUser.profileImageURL,
            createdAt: currentUser.createdAt,
            preferences: preferences
        )
        
        return try await repository.updateUser(currentUser)
    }
    
    func setRememberMe(_ enabled: Bool) async throws {
        try storageService.save(enabled, forKey: "rememberMe")
    }
    
    // MARK: - Repository Methods (для совместимости)
    
    func authenticateUser(email: String, password: String) async throws -> User {
        return try await repository.authenticateUser(email: email, password: password)
    }
    
    func getUser(id: UUID) async throws -> User {
        return try await repository.fetchUser(by: id)
    }
    
    func updateUser(_ user: User) async throws -> User {
        return try await repository.updateUser(user)
    }
    
    func deleteUser(id: UUID) async throws {
        try await repository.deleteUser(id: id)
    }
}
