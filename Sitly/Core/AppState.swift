import Foundation
import SwiftUI
import Firebase
import FirebaseAuth

final class AppState: ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var showOnboarding = false
    
    // MARK: - Private Properties
    private let userUseCase: UserUseCaseProtocol
    private let storageService: StorageServiceProtocol
    private let auth = Auth.auth()
    
    // MARK: - Computed Properties
    var hasCompletedOnboarding: Bool {
        get {
            (try? storageService.load(forKey: "hasCompletedOnboarding")) ?? false
        }
        set {
            try? storageService.save(newValue, forKey: "hasCompletedOnboarding")
        }
    }
    
    var authToken: String? {
        get {
            try? storageService.load(forKey: "authToken")
        }
        set {
            if let token = newValue {
                try? storageService.save(token, forKey: "authToken")
            } else {
                storageService.remove(forKey: "authToken")
            }
        }
    }
    
    var refreshToken: String? {
        get {
            try? storageService.load(forKey: "refreshToken")
        }
        set {
            if let token = newValue {
                try? storageService.save(token, forKey: "refreshToken")
            } else {
                storageService.remove(forKey: "refreshToken")
            }
        }
    }
    
    // MARK: - Initialization
    init(userUseCase: UserUseCaseProtocol, storageService: StorageServiceProtocol) {
        self.userUseCase = userUseCase
        self.storageService = storageService
        
        // Настраиваем слушатель состояния аутентификации
        setupAuthStateListener()
        
        // Проверяем состояние при запуске
        checkAuthenticationStatus()
    }
    
    // MARK: - Public Methods
    
    func checkAuthenticationStatus() {
        Task { @MainActor in
            self.isLoading = true
        }
        
        Task {
            do {
                // Проверяем есть ли активная сессия Firebase Auth
                if Auth.auth().currentUser != nil {
                    // Есть активная сессия, загружаем профиль
                    let user = try await userUseCase.getUserProfile()
                    await MainActor.run {
                        self.currentUser = user
                        self.isAuthenticated = true
                    }
                } else {
                    // Нет активной сессии
                    await MainActor.run {
                        self.isAuthenticated = false
                        self.currentUser = nil
                    }
                }
            } catch {
                print("❌ Ошибка проверки авторизации: \(error)")
                await MainActor.run {
                    clearAuthData()
                    self.isAuthenticated = false
                }
            }
            
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    func login(email: String, password: String, rememberMe: Bool) async throws -> Bool {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let success = try await userUseCase.login(
                email: email,
                password: password,
                rememberMe: rememberMe
            )
            
            if success {
                // Загружаем профиль пользователя
                let user = try await userUseCase.getUserProfile()
                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = true
                }
                
                // Устанавливаем контекст пользователя для умного выбора сервисов
                DependencyContainer.shared.setCurrentUser(
                    id: currentUser?.id,
                    email: email
                )
                
                return true
            } else {
                return false
            }
        } catch {
            isLoading = false
            throw error
        }
    }
    
    func register(email: String, password: String, name: String) async throws -> Bool {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let success = try await userUseCase.register(
                email: email,
                password: password,
                name: name
            )
            
            if success {
                // Автоматически входим после регистрации
                return try await login(email: email, password: password, rememberMe: false)
            } else {
                await MainActor.run {
                    self.isLoading = false
                }
                return false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Registration with Role
    func register(email: String, password: String, name: String, role: UserRole) async throws {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let user = try await userUseCase.registerWithRole(
                email: email,
                password: password,
                name: name,
                role: role
            )
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            throw error
        }
    }
    
    func logout() {
        Task {
            do {
                // Выходим из Firebase Auth
                try Auth.auth().signOut()
                try await userUseCase.logout()
            } catch {
                print("❌ Ошибка выхода: \(error)")
            }
            
            await MainActor.run {
                clearAuthData()
                self.isAuthenticated = false
                self.currentUser = nil
            }
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        showOnboarding = false
    }
    
    // MARK: - Private Methods
    
    private func setupAuthStateListener() {
        // Для MVP пока отключаем Firebase Auth listener
        // В будущем здесь будет настройка слушателя состояния аутентификации
        print("🔐 Firebase Auth listener отключен для MVP версии")
    }
    
    private func loadUserProfile(userId: String) {
        Task {
            do {
                let user = try await userUseCase.getUserProfile()
                await MainActor.run {
                    self.currentUser = user
                }
            } catch {
                print("❌ Ошибка загрузки профиля: \(error)")
            }
        }
    }
    
    private func clearAuthData() {
        authToken = nil
        refreshToken = nil
        currentUser = nil
    }
    
    // MARK: - Refresh Methods
    func refreshUser() {
        if let userId = currentUser?.id {
            loadUserProfile(userId: userId)
        }
    }
}

// MARK: - App State Environment Key

struct AppStateKey: EnvironmentKey {
    static let defaultValue: AppState = {
        let container = DependencyContainer.shared
        return AppState(
            userUseCase: container.userUseCase,
            storageService: container.storageService
        )
    }()
}

extension EnvironmentValues {
    var appState: AppState {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}

// MARK: - Mock User Use Case

private class MockUserUseCase: UserUseCaseProtocol {
    func login(email: String, password: String, rememberMe: Bool) async throws -> Bool { return true }
    func loginWithApple() async throws -> Bool { return true }
    func loginWithGoogle() async throws -> Bool { return true }
    func register(email: String, password: String, name: String) async throws -> Bool { return true }
    func registerWithRole(email: String, password: String, name: String, role: UserRole) async throws -> User {
        return User(
            id: "demo-user-id",
            email: email,
            name: name,
            role: role,
            phoneNumber: nil,
            profileImageURL: nil,
            createdAt: Date(),
            lastLoginAt: Date(),
            restaurantId: nil,
            isVerified: false,
            subscriptionPlan: nil,
            preferences: UserPreferences(),
            favoriteRestaurants: []
        )
    }
    func sendPasswordResetEmail(email: String) async throws -> Bool { return true }
    func logout() async throws { }
    func validateSession() async throws -> Bool { return false }
    func authenticateWithBiometrics() async throws -> Bool { return false }
    func getUserProfile() async throws -> User { 
        User(
            id: "demo-user-id", 
            email: "demo@example.com", 
            name: "Demo User",
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
    }
    func updateUserProfile(_ user: User) async throws -> User { return user }
    func updateUserPreferences(_ preferences: UserPreferences) async throws -> User { 
        User(
            id: "demo-user-id", 
            email: "demo@example.com", 
            name: "Demo User",
            role: .client,
            phoneNumber: nil,
            profileImageURL: nil,
            createdAt: Date(),
            lastLoginAt: Date(),
            restaurantId: nil,
            isVerified: false,
            subscriptionPlan: nil,
            preferences: preferences,
            favoriteRestaurants: nil
        )
    }
    func setRememberMe(_ enabled: Bool) async throws { }
    
    // MARK: - Repository Methods (для совместимости)
    func registerUser(email: String, password: String, name: String) async throws -> User {
        return User(
            id: "new-user-id", 
            email: email, 
            name: name,
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
    }
    
    func authenticateUser(email: String, password: String) async throws -> User {
        return User(
            id: "auth-user-id", 
            email: email, 
            name: "Demo User",
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
    }
    
    func getUser(id: UUID) async throws -> User {
        return User(
            id: id.uuidString, 
            email: "demo@example.com", 
            name: "Demo User",
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
    }
    
    func updateUser(_ user: User) async throws -> User {
        return user
    }
    
    func deleteUser(id: UUID) async throws { }
}
