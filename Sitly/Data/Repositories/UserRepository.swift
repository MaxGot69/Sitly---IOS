import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

// MARK: - User Repository Implementation

final class UserRepository: UserRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let storageService: StorageServiceProtocol
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init(networkService: NetworkServiceProtocol, storageService: StorageServiceProtocol) {
        self.networkService = networkService
        self.storageService = storageService
    }
    
    // MARK: - Public Methods
    
    func createUser(_ user: User) async throws -> User {
        do {
            // Создаем пользователя в Firestore
            print("📝 Кодируем данные пользователя...")
            let userData = try JSONEncoder().encode(user)
            let userDict = try JSONSerialization.jsonObject(with: userData) as? [String: Any] ?? [:]
            
            var firestoreData = userDict
            firestoreData.removeValue(forKey: "id")
            
            print("📝 Сохраняем в Firestore: users/\(user.id)")
            print("📝 Данные: \(firestoreData)")
            
            // Используем существующий ID пользователя
            try await db.collection("users").document(user.id).setData(firestoreData)
            
            print("📝 Документ сохранен в Firestore!")
            return user
        } catch {
            print("❌ Ошибка создания документа Firestore: \(error)")
            throw error
        }
    }
    
    func fetchUser(by id: UUID) async throws -> User {
        let document = try await db.collection("users").document(id.uuidString).getDocument()
        guard let data = document.data() else {
            throw RepositoryError.notFound
        }
        
        var userData = data
        userData["id"] = document.documentID
        
        let jsonData = try JSONSerialization.data(withJSONObject: userData)
        return try JSONDecoder().decode(User.self, from: jsonData)
    }
    
    func updateUser(_ user: User) async throws -> User {
        let userData = try JSONEncoder().encode(user)
        let userDict = try JSONSerialization.jsonObject(with: userData) as? [String: Any] ?? [:]
        
        var firestoreData = userDict
        firestoreData.removeValue(forKey: "id")
        
        try await db.collection("users").document(user.id).setData(firestoreData, merge: true)
        
        return user
    }
    
    func deleteUser(id: UUID) async throws {
        try await db.collection("users").document(id.uuidString).delete()
    }
    
    func authenticateUser(email: String, password: String) async throws -> User {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            let firebaseUser = result.user
            
            // Получаем данные пользователя из Firestore
            let document = try await db.collection("users").document(firebaseUser.uid).getDocument()
            
            if let data = document.data() {
                var userData = data
                userData["id"] = document.documentID
                userData["lastLoginAt"] = Date()
                
                // Обновляем последний вход
                try await db.collection("users").document(firebaseUser.uid).updateData([
                    "lastLoginAt": Timestamp(date: Date())
                ])
                
                let jsonData = try JSONSerialization.data(withJSONObject: userData)
                let user = try JSONDecoder().decode(User.self, from: jsonData)
                
                // Сохраняем в локальное хранилище
                try storageService.save(user, forKey: "currentUser")
                
                return user
            } else {
                // Создаем базовый профиль если его нет
                // Определяем роль на основе email
                let userRole: UserRole = email.contains("admin") ? .restaurant : .client
                let user = User(
                    id: firebaseUser.uid,
                    email: email,
                    name: firebaseUser.displayName ?? (userRole == .restaurant ? "Ресторан" : "Пользователь"),
                    role: userRole,
                    phoneNumber: firebaseUser.phoneNumber,
                    profileImageURL: firebaseUser.photoURL?.absoluteString,
                    createdAt: Date(),
                    lastLoginAt: Date(),
                    restaurantId: nil,
                    isVerified: firebaseUser.isEmailVerified,
                    subscriptionPlan: nil,
                    preferences: UserPreferences(),
                    favoriteRestaurants: []
                )
                
                let createdUser = try await createUser(user)
                try storageService.save(createdUser, forKey: "currentUser")
                return createdUser
            }
        } catch let error as NSError {
            // Красивая обработка ошибок Firebase Auth
            switch error.code {
            case AuthErrorCode.userNotFound.rawValue:
                throw RepositoryError.authenticationError("Пользователь не найден. Проверьте email.")
            case AuthErrorCode.wrongPassword.rawValue:
                throw RepositoryError.authenticationError("Неверный пароль. Попробуйте еще раз.")
            case AuthErrorCode.invalidEmail.rawValue:
                throw RepositoryError.authenticationError("Неверный формат email адреса.")
            case AuthErrorCode.userDisabled.rawValue:
                throw RepositoryError.authenticationError("Аккаунт заблокирован. Обратитесь в поддержку.")
            case AuthErrorCode.tooManyRequests.rawValue:
                throw RepositoryError.authenticationError("Слишком много попыток входа. Попробуйте позже.")
            case AuthErrorCode.networkError.rawValue:
                throw RepositoryError.networkError(error)
            default:
                throw RepositoryError.authenticationError("Ошибка входа: \(error.localizedDescription)")
            }
        }
    }
    
    func registerUser(email: String, password: String, name: String) async throws -> User {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let firebaseUser = result.user
            
            // Обновляем профиль Firebase пользователя
            let changeRequest = firebaseUser.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            
            // Создаем полный профиль пользователя
            let user = User(
                id: firebaseUser.uid,
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
                preferences: UserPreferences(),
                favoriteRestaurants: []
            )
            
            let createdUser = try await createUser(user)
            try storageService.save(createdUser, forKey: "currentUser")
            
            // Отправляем email верификации
            try await firebaseUser.sendEmailVerification()
            
            return createdUser
        } catch let error as NSError {
            // Обработка ошибок регистрации
            switch error.code {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                throw RepositoryError.authenticationError("Этот email уже используется. Попробуйте войти.")
            case AuthErrorCode.weakPassword.rawValue:
                throw RepositoryError.authenticationError("Пароль слишком простой. Используйте минимум 6 символов.")
            case AuthErrorCode.invalidEmail.rawValue:
                throw RepositoryError.authenticationError("Неверный формат email адреса.")
            case AuthErrorCode.networkError.rawValue:
                throw RepositoryError.networkError(error)
            default:
                throw RepositoryError.authenticationError("Ошибка регистрации: \(error.localizedDescription)")
            }
        }
    }
    
    func registerUserWithRole(email: String, password: String, name: String, role: UserRole) async throws -> User {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let firebaseUser = result.user
            
            // Обновляем профиль Firebase пользователя
            let changeRequest = firebaseUser.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            
            // Создаем полный профиль пользователя с указанной ролью
            let user = User(
                id: firebaseUser.uid,
                email: email,
                name: name,
                role: role, // Используем переданную роль
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
            
            print("✅ Firebase пользователь создан: \(firebaseUser.uid)")
            print("✅ Создаем Firestore документ...")
            
            // Пытаемся создать документ в Firestore, но не блокируем регистрацию при ошибке
            do {
                let createdUser = try await createUser(user)
                print("✅ Firestore документ создан")
                
                print("✅ Сохраняем в локальное хранилище...")
                try storageService.save(createdUser, forKey: "currentUser")
                
                print("✅ Регистрация завершена успешно!")
                return createdUser
            } catch {
                print("⚠️ Ошибка Firestore (пропускаем): \(error)")
                print("✅ Сохраняем пользователя только локально...")
                
                // Сохраняем локально даже если Firestore не работает
                try storageService.save(user, forKey: "currentUser")
                
                print("✅ Регистрация завершена (без Firestore)!")
                return user
            }
        } catch let error as NSError {
            // Красивая обработка ошибок Firebase Auth
            switch error.code {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                throw RepositoryError.authenticationError("Этот email уже используется другим аккаунтом.")
            case AuthErrorCode.invalidEmail.rawValue:
                throw RepositoryError.authenticationError("Неверный формат email адреса.")
            case AuthErrorCode.weakPassword.rawValue:
                throw RepositoryError.authenticationError("Пароль слишком простой. Используйте не менее 6 символов.")
            case AuthErrorCode.networkError.rawValue:
                throw RepositoryError.networkError(error)
            default:
                throw RepositoryError.authenticationError("Ошибка регистрации: \(error.localizedDescription)")
            }
        }
    }
}


