import Foundation
import CoreLocation

// MARK: - Repository Protocols

protocol RestaurantRepositoryProtocol {
    func fetchRestaurants() async throws -> [Restaurant]
    func fetchRestaurant(by id: String) async throws -> Restaurant
    func searchRestaurants(query: String) async throws -> [Restaurant]
    func fetchRestaurantsByCuisine(_ cuisine: String) async throws -> [Restaurant]
    func fetchNearbyRestaurants(latitude: Double, longitude: Double, radius: Double) async throws -> [Restaurant]
}

protocol UserRepositoryProtocol {
    func createUser(_ user: User) async throws -> User
    func fetchUser(by id: UUID) async throws -> User
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: UUID) async throws
    func authenticateUser(email: String, password: String) async throws -> User
    func registerUser(email: String, password: String, name: String) async throws -> User
    func registerUserWithRole(email: String, password: String, name: String, role: UserRole) async throws -> User
}

protocol BookingRepositoryProtocol {
    func createBooking(_ booking: BookingModel) async throws -> BookingModel
    func fetchUserBookings(userId: String) async throws -> [BookingModel]
    func fetchRestaurantBookings(restaurantId: String) async throws -> [BookingModel]
    func updateBookingStatus(bookingId: String, status: BookingStatus) async throws -> BookingModel
    func cancelBooking(bookingId: String) async throws -> BookingModel
    func checkAvailability(restaurantId: String, date: Date, time: String) async throws -> Bool
}

protocol ReviewRepositoryProtocol {
    func createReview(_ review: Review) async throws -> Review
    func fetchRestaurantReviews(restaurantId: String) async throws -> [Review]
    func fetchUserReviews(userId: String) async throws -> [Review]
    func updateReview(_ review: Review) async throws -> Review
    func deleteReview(id: String) async throws
}

// MARK: - Use Case Protocols

protocol RestaurantUseCaseProtocol {
    func getRestaurants() async throws -> [Restaurant]
    func getRestaurant(id: String) async throws -> Restaurant
    func searchRestaurants(query: String) async throws -> [Restaurant]
    func getRestaurantsByCuisine(_ cuisine: String) async throws -> [Restaurant]
    func getNearbyRestaurants(latitude: Double, longitude: Double) async throws -> [Restaurant]
    func getCurrentLocationRestaurants() async throws -> [Restaurant]
}

protocol UserUseCaseProtocol {
    func login(email: String, password: String, rememberMe: Bool) async throws -> Bool
    func loginWithApple() async throws -> Bool
    func loginWithGoogle() async throws -> Bool
    func register(email: String, password: String, name: String) async throws -> Bool
    func registerWithRole(email: String, password: String, name: String, role: UserRole) async throws -> User
    func sendPasswordResetEmail(email: String) async throws -> Bool
    func logout() async throws
    func validateSession() async throws -> Bool
    func authenticateWithBiometrics() async throws -> Bool
    func getUserProfile() async throws -> User
    func updateUserProfile(_ user: User) async throws -> User
    func updateUserPreferences(_ preferences: UserPreferences) async throws -> User
    func setRememberMe(_ enabled: Bool) async throws
}

protocol BookingUseCaseProtocol {
    func createBooking(
        restaurantId: String,
        userId: String,
        date: Date,
        time: String,
        guestCount: Int,
        tableType: TableType,
        specialRequests: String?,
        contactPhone: String
    ) async throws -> BookingModel
    
    func getUserBookings(userId: String) async throws -> [BookingModel]
    func getRestaurantBookings(restaurantId: String) async throws -> [BookingModel]
    func updateBookingStatus(bookingId: String, status: BookingStatus) async throws -> BookingModel
    func cancelBooking(bookingId: String) async throws -> BookingModel
    func checkAvailability(restaurantId: String, date: Date, time: String) async throws -> Bool
    func getUpcomingBookings(userId: String) async throws -> [BookingModel]
    func getPastBookings(userId: String) async throws -> [BookingModel]
    func getBookingsByStatus(userId: String, status: BookingStatus) async throws -> [BookingModel]
    func getBookingsForDate(userId: String, date: Date) async throws -> [BookingModel]
    func canModifyBooking(_ booking: BookingModel) -> Bool
    func getAvailableTimeSlots(restaurantId: String, date: Date) async throws -> [String]
    func getAvailableTableTypes(restaurantId: String, date: Date, time: String) async throws -> [TableType]
}

protocol ReviewUseCaseProtocol {
    func createReview(
        restaurantId: String,
        userId: String,
        rating: Double,
        text: String,
        photos: [String]?
    ) async throws -> Review
    
    func getRestaurantReviews(restaurantId: String) async throws -> [Review]
    func getUserReviews(userId: String) async throws -> [Review]
    func updateReview(_ review: Review) async throws -> Review
    func deleteReview(id: String) async throws
    func getReviewStatistics(restaurantId: String) async throws -> ReviewStatistics
    func getTopReviews(restaurantId: String, limit: Int) async throws -> [Review]
    func getReviewsByRating(restaurantId: String, rating: Double) async throws -> [Review]
    func getRecentReviews(restaurantId: String, days: Int) async throws -> [Review]
    func canEditReview(_ review: Review) -> Bool
    func canDeleteReview(_ review: Review) -> Bool
    func reportReview(_ review: Review, reason: String) async throws
    func moderateReview(_ review: Review, action: ReviewModerationAction) async throws
    func getReviewTrends(restaurantId: String, days: Int) async throws -> [Date: Double]
}



// MARK: - Service Protocols

protocol NetworkServiceProtocol {
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
    func upload<T: Codable>(_ data: Data, to endpoint: APIEndpoint) async throws -> T
}

protocol StorageServiceProtocol {
    func save<T: Codable>(_ object: T, forKey key: String) throws
    func save<T: Codable>(_ object: T, forKey key: String, expiration: TimeInterval) throws
    func load<T: Codable>(forKey key: String) throws -> T?
    func remove(forKey key: String)
    func clear()
}



protocol LocationServiceProtocol {
    func getCurrentLocation() async throws -> CLLocationCoordinate2D
    func requestLocationPermission() async -> Bool
    func startLocationUpdates()
    func stopLocationUpdates()
}

// MARK: - Supporting Types

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

enum RepositoryError: LocalizedError {
    case networkError(Error)
    case serverError(String)
    case notFound
    case unauthorized
    case validationError(String)
    case authenticationError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .serverError(let message):
            return "Ошибка сервера: \(message)"
        case .notFound:
            return "Данные не найдены"
        case .unauthorized:
            return "Не авторизован"
        case .validationError(let message):
            return "Ошибка валидации: \(message)"
        case .authenticationError(let message):
            return "Ошибка аутентификации: \(message)"
        }
    }
}

enum UseCaseError: LocalizedError {
    case businessLogicError(String)
    case repositoryError(RepositoryError)
    
    var errorDescription: String? {
        switch self {
        case .businessLogicError(let message):
            return "Ошибка бизнес-логики: \(message)"
        case .repositoryError(let error):
            return error.localizedDescription
        }
    }
}

 