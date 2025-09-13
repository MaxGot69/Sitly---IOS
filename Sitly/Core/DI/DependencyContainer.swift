import Foundation
import SwiftUI
import CoreLocation

// MARK: - Dependency Container

final class DependencyContainer: ObservableObject {
    static let shared = DependencyContainer()
    
    // MARK: - Services
    lazy var networkService: NetworkServiceProtocol = NetworkService()
    lazy var storageService: StorageServiceProtocol = StorageService()
    lazy var locationService: LocationServiceProtocol = LocationService()
    lazy var cacheService: CacheServiceProtocol = {
        let service = CacheService(storageService: storageService)
        return service
    }()
    
    // MARK: - Repositories
    lazy var restaurantRepository: RestaurantRepositoryProtocol = RestaurantRepository(
        networkService: networkService,
        storageService: storageService,
        cacheService: cacheService
    )
    
    lazy var bookingRepository: BookingRepositoryProtocol = BookingRepository(
        networkService: networkService,
        storageService: storageService
    )
    
    lazy var userRepository: UserRepositoryProtocol = UserRepository(
        networkService: networkService,
        storageService: storageService
    )
    
    lazy var reviewRepository: ReviewRepositoryProtocol = ReviewRepository(
        networkService: networkService,
        storageService: storageService
    )
    
    // MARK: - Use Cases
    lazy var restaurantUseCase: RestaurantUseCaseProtocol = RestaurantUseCase(
        repository: restaurantRepository,
        locationService: locationService
    )
    
    lazy var locationUseCase: LocationUseCaseProtocol = LocationUseCase(
        locationService: locationService,
        restaurantRepository: restaurantRepository
    )
    
    lazy var bookingUseCase: BookingUseCaseProtocol = BookingUseCase(
        repository: bookingRepository,
        restaurantRepository: restaurantRepository
    )
    
    lazy var userUseCase: UserUseCaseProtocol = UserUseCase(
        repository: userRepository,
        storageService: storageService
    )
    
    lazy var reviewUseCase: ReviewUseCaseProtocol = ReviewUseCase(
        repository: reviewRepository,
        restaurantRepository: restaurantRepository
    )
    
    private init() {}
}

// MARK: - SwiftUI Environment Key

struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue: DependencyContainer = DependencyContainer.shared
}

extension EnvironmentValues {
    var dependencyContainer: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}

// MARK: - View Extensions

extension View {
    func injectDependencies() -> some View {
        self.environment(\.dependencyContainer, DependencyContainer.shared)
    }
}

// MARK: - App Configuration

extension DependencyContainer {
    func configure() {
        // Здесь можно добавить дополнительную конфигурацию
        // Например, настройка логирования, аналитики и т.д.
        
        print("🚀 Sitly App - Dependency Container configured successfully!")
        print("📱 Services: Network, Storage, Location")
        print("🗄️ Repositories: Restaurant, Booking, User, Review")
        print("💼 Use Cases: Restaurant, Booking, User, Review")
    }
}

// MARK: - Mock Data Provider (для тестирования)

final class MockDataProvider {
    static let shared = MockDataProvider()
    
    private init() {}
    
    func getMockRestaurants() -> [Restaurant] {
        return [
            Restaurant(
                id: "pushkin-1",
                name: "Pushkin",
                description: "Это культовое заведение, известное своим роскошным интерьером в стиле дворянской усадьбы XIX века и изысканной русской кухней.",
                cuisineType: .russian,
                address: "Тверской бул., 26А, Москва",
                coordinates: CLLocationCoordinate2D(latitude: 55.7652, longitude: 37.6041),
                phoneNumber: "+7 (495) 123-45-67",
                ownerId: "owner-1"
            ),
            Restaurant(
                id: "tver-1",
                name: "Тверь",
                description: "Современная кухня и уютный интерьер в центре столицы.",
                cuisineType: .european,
                address: "Тверской бул., 26А, Москва",
                coordinates: CLLocationCoordinate2D(latitude: 55.7652, longitude: 37.6041),
                phoneNumber: "+7 (495) 123-45-68",
                ownerId: "owner-2"
            ),
            Restaurant(
                id: "sibir-1",
                name: "СибирьСибирь",
                description: "Атмосферное место с сибирским духом и кухней северных регионов.",
                cuisineType: .russian,
                address: "Садовая-Самотечная, 20, Москва",
                coordinates: CLLocationCoordinate2D(latitude: 55.7756, longitude: 37.6216),
                phoneNumber: "+7 (495) 123-45-69",
                ownerId: "owner-3"
            ),
            Restaurant(
                id: "white-rabbit-1",
                name: "White Rabbit",
                description: "Ресторан с панорамным видом на Москву и современной европейской кухней.",
                cuisineType: .european,
                address: "Смоленская пл., 3, Москва",
                coordinates: CLLocationCoordinate2D(latitude: 55.7488, longitude: 37.5847),
                phoneNumber: "+7 (495) 123-45-70",
                ownerId: "owner-4"
            ),
            Restaurant(
                id: "dr-zhivago-1",
                name: "Dr. Живаго",
                description: "Современная интерпретация русской кухни в историческом здании.",
                cuisineType: .russian,
                address: "Моховая ул., 15/1, Москва",
                coordinates: CLLocationCoordinate2D(latitude: 55.7520, longitude: 37.6175),
                phoneNumber: "+7 (495) 123-45-71",
                ownerId: "owner-5"
            )
        ]
    }
    
    func getMockUser() -> User {
        return User(
            id: "user-1",
            email: "user@example.com",
            name: "Тестовый Пользователь",
            phoneNumber: "+7 (999) 123-45-67"
        )
    }
    
    func getMockBookings() -> [Booking] {
        return [
            Booking(
                restaurantId: "demo-restaurant",
                clientId: "client1",
                tableId: "table1",
                date: Date().addingTimeInterval(86400),
                timeSlot: "19:00-21:00",
                guests: 2,
                status: .pending,
                specialRequests: "Столик у окна",
                totalPrice: 2500.0,
                paymentStatus: .unpaid,
                clientName: "Анна Петрова",
                clientPhone: "+7 (999) 123-45-67",
                clientEmail: "anna@example.com",
                tableName: "Стол 1",
                tableCapacity: 2,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Booking(
                restaurantId: "demo-restaurant",
                clientId: "client2",
                tableId: "table2",
                date: Date().addingTimeInterval(172800),
                timeSlot: "20:00-22:00",
                guests: 4,
                status: .confirmed,
                specialRequests: "VIP-столик",
                totalPrice: 5000.0,
                paymentStatus: .paid,
                clientName: "Михаил Иванов",
                clientPhone: "+7 (999) 987-65-43",
                clientEmail: "mikhail@example.com",
                tableName: "VIP-1",
                tableCapacity: 6,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }
    
    func getMockReviews() -> [Review] {
        return [
            Review(
                restaurantId: "restaurant-1", // ID первого ресторана
                userId: "user-1",
                userName: "Алексей",
                rating: 4.5,
                text: "Отличный ресторан! Очень вкусная еда и приятная атмосфера."
            ),
            Review(
                restaurantId: "restaurant-1", // ID первого ресторана
                userId: "user-1",
                userName: "Мария",
                rating: 4.8,
                text: "Обслуживание на высоте, рекомендую всем!"
            ),
            Review(
                restaurantId: "restaurant-1", // ID второго ресторана
                userId: "user-1",
                userName: "Дмитрий",
                rating: 4.3,
                text: "Хороший ресторан, но можно лучше."
            )
        ]
    }
}

// MARK: - Error Handling

extension DependencyContainer {
    func handleError(_ error: Error) {
        // Централизованная обработка ошибок
        print("❌ Error occurred: \(error.localizedDescription)")
        
        // Здесь можно добавить:
        // - Отправку в аналитику (Crashlytics, Firebase Analytics)
        // - Показ пользователю уведомления об ошибке
        // - Логирование для разработчиков
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
    
    func deleteUser(id: UUID) async throws {
        // Ничего не делаем для MVP
    }
}

// AppState moved to separate file 