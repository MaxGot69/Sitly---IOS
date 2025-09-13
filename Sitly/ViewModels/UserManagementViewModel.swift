import Foundation

@MainActor
class UserManagementViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol = UserRepository(
        networkService: NetworkService(),
        storageService: StorageService()
    )) {
        self.userRepository = userRepository
        generateMockUsers()
    }
    
    // MARK: - Public Methods
    func loadUsers() {
        isLoading = true
        
        Task {
            // В реальном приложении здесь будет загрузка из API
            // users = try await userRepository.fetchAllUsers()
            
            // Для демо используем моковые данные
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isLoading = false
            }
        }
    }
    
    func toggleUserStatus(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            // Переключаем статус верификации вместо isActive
            let updatedUser = User(
                id: user.id,
                email: user.email,
                name: user.name,
                role: user.role,
                phoneNumber: user.phoneNumber,
                profileImageURL: user.profileImageURL,
                createdAt: user.createdAt,
                lastLoginAt: user.lastLoginAt,
                restaurantId: user.restaurantId,
                isVerified: !user.isVerified,
                subscriptionPlan: user.subscriptionPlan,
                preferences: user.preferences,
                favoriteRestaurants: user.favoriteRestaurants
            )
            
            users[index] = updatedUser
            
            // В реальном приложении здесь будет API вызов
            // Task {
            //     try await userRepository.updateUserStatus(user.id, isVerified: !user.isVerified)
            // }
        }
    }
    
    func deleteUser(_ user: User) {
        users.removeAll { $0.id == user.id }
        
        // В реальном приложении здесь будет API вызов
        // Task {
        //     try await userRepository.deleteUser(user.id)
        // }
    }
    
    // MARK: - Private Methods
    private func generateMockUsers() {
        users = [
            User(
                id: "user_1",
                email: "anna.petrova@example.com",
                name: "Анна Петрова",
                role: .client,
                phoneNumber: "+7 (925) 123-45-67",
                profileImageURL: nil,
                createdAt: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
                lastLoginAt: Date(),
                isVerified: true
            ),
            User(
                id: "user_2",
                email: "maxim.smirnov@example.com",
                name: "Максим Смирнов",
                role: .client,
                phoneNumber: "+7 (925) 234-56-78",
                profileImageURL: nil,
                createdAt: Calendar.current.date(byAdding: .day, value: -25, to: Date()) ?? Date(),
                lastLoginAt: Date(),
                isVerified: true
            ),
            User(
                id: "user_3",
                email: "manager@beluga-restaurant.ru",
                name: "Ресторан Белуга",
                role: .restaurant,
                phoneNumber: "+7 (495) 123-45-67",
                profileImageURL: nil,
                createdAt: Calendar.current.date(byAdding: .day, value: -60, to: Date()) ?? Date(),
                lastLoginAt: Date(),
                restaurantId: "1",
                isVerified: true
            ),
            User(
                id: "user_4",
                email: "elena.kozlova@example.com",
                name: "Елена Козлова",
                role: .client,
                phoneNumber: "+7 (925) 345-67-89",
                profileImageURL: nil,
                createdAt: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
                lastLoginAt: Date(),
                isVerified: false
            ),
            User(
                id: "user_5",
                email: "info@sirovarnya.com",
                name: "Ресторан Сыроварня",
                role: .restaurant,
                phoneNumber: "+7 (495) 234-56-78",
                profileImageURL: nil,
                createdAt: Calendar.current.date(byAdding: .day, value: -45, to: Date()) ?? Date(),
                lastLoginAt: Date(),
                restaurantId: "2",
                isVerified: true
            ),
            User(
                id: "user_6",
                email: "dmitry.admin@sitly.ru",
                name: "Дмитрий Админов",
                role: .restaurant,
                phoneNumber: "+7 (495) 000-00-00",
                profileImageURL: nil,
                createdAt: Calendar.current.date(byAdding: .day, value: -100, to: Date()) ?? Date(),
                lastLoginAt: Date(),
                isVerified: true
            ),
            User(
                id: "user_7",
                email: "irina.volkova@example.com",
                name: "Ирина Волкова",
                role: .client,
                phoneNumber: "+7 (925) 456-78-90",
                profileImageURL: nil,
                createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                lastLoginAt: Date(),
                isVerified: true
            ),
            User(
                id: "user_8",
                email: "manager@tanuki.ru",
                name: "Тануки",
                role: .restaurant,
                phoneNumber: "+7 (495) 345-67-89",
                profileImageURL: nil,
                createdAt: Calendar.current.date(byAdding: .day, value: -35, to: Date()) ?? Date(),
                lastLoginAt: Date(),
                restaurantId: "3",
                isVerified: true
            ),
            User(
                id: "user_9",
                email: "alexey.novikov@example.com",
                name: "Алексей Новиков",
                role: .client,
                phoneNumber: "+7 (925) 567-89-01",
                profileImageURL: nil,
                createdAt: Calendar.current.date(byAdding: .day, value: -12, to: Date()) ?? Date(),
                lastLoginAt: Date(),
                isVerified: true
            ),
            User(
                id: "user_10",
                email: "marina.fedorova@example.com",
                name: "Марина Федорова",
                role: .client,
                phoneNumber: "+7 (925) 678-90-12",
                profileImageURL: nil,
                createdAt: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(),
                lastLoginAt: Date(),
                isVerified: false
            ),
            User(
                id: "user_11",
                email: "info@pasta-basilik.ru",
                name: "Паста & Базилик",
                role: .restaurant,
                phoneNumber: "+7 (495) 456-78-90",
                profileImageURL: nil,
                createdAt: Calendar.current.date(byAdding: .day, value: -50, to: Date()) ?? Date(),
                lastLoginAt: Date(),
                restaurantId: "4",
                isVerified: false
            ),
            User(
                id: "user_12",
                email: "oleg.sidorov@example.com",
                name: "Олег Сидоров",
                role: .client,
                phoneNumber: "+7 (925) 789-01-23",
                profileImageURL: nil,
                createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                lastLoginAt: Date(),
                isVerified: true
            )
        ]
    }
}