import Foundation
import Combine
import SwiftUI

@MainActor
class RestaurantDashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var restaurant: Restaurant?
    @Published var todayStats = TodayStats()
    @Published var upcomingBookings: [Booking] = []
    @Published var notifications: [Notification] = []
    @Published var hourlyLoadData: [HourlyLoadData] = []
    @Published var popularTablesData: [PopularTableData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Navigation States
    @Published var showingManualBooking = false
    @Published var showingAIAssistant = false
    @Published var showingBookingDetail: Booking?
    @Published var showingProfile = false
    @Published var showingSettings = false
    
    // MARK: - Toast System
    @Published var showToast = false
    @Published var toastMessage = ""
    @Published var toastType: ToastType = .success
    
    // MARK: - Computed Properties
    var pendingBookingsCount: Int {
        upcomingBookings.filter { $0.status == .pending }.count
    }
    
    // MARK: - Dependencies
    private let restaurantRepository: RestaurantRepositoryProtocol
    private let bookingRepository: BookingRepositoryProtocol
    private let aiService: AIServiceProtocol
    private let userRepository: UserRepositoryProtocol
    private let notificationService: NotificationServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - AppState Integration
    @Published var currentUser: User?
    
    // MARK: - Initialization
    init(restaurantRepository: RestaurantRepositoryProtocol = RestaurantRepository(networkService: NetworkService(), storageService: StorageService(), cacheService: CacheService(storageService: StorageService())),
         bookingRepository: BookingRepositoryProtocol = BookingRepository(networkService: NetworkService(), storageService: StorageService()),
         aiService: AIServiceProtocol = AIService(),
         userRepository: UserRepositoryProtocol = UserRepository(networkService: NetworkService(), storageService: StorageService()),
         notificationService: NotificationServiceProtocol = NotificationService.shared,
         analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared) {
        self.restaurantRepository = restaurantRepository
        self.bookingRepository = bookingRepository
        self.aiService = aiService
        self.userRepository = userRepository
        self.notificationService = notificationService
        self.analyticsService = analyticsService
        
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Запрашиваем разрешения на уведомления
        Task {
            await notificationService.requestPermission()
        }
        
        // Загружаем данные при инициализации
        loadDashboardData()
        
        // Автоматическое обновление данных каждые 5 минут
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.refreshData()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    func loadDashboardData() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            await loadRestaurantData()
            await loadTodayStats()
            await loadUpcomingBookings()
            await loadNotifications()
            await loadAnalyticsData()
            await loadAIRecommendations()
        }
    }
    
    private func loadRestaurantData() async {
        // Загружаем данные ресторана для текущего пользователя
        guard let currentUser = await getCurrentUser(),
              let restaurantId = currentUser.restaurantId else { return }
        
        do {
            restaurant = try await restaurantRepository.fetchRestaurant(by: restaurantId)
            
            // Логируем просмотр дашборда
            analyticsService.logScreenView("restaurant_dashboard", parameters: [
                AnalyticsParameter.restaurantId.rawValue: restaurantId
            ])
            
        } catch {
            errorMessage = "Не удалось загрузить данные ресторана: \(error.localizedDescription)"
            analyticsService.logError(error, context: "loadRestaurantData")
        }
    }
    
    private func loadTodayStats() async {
        guard let restaurant = restaurant else { return }
        
        do {
            let today = Date()
            let allBookings = try await bookingRepository.fetchRestaurantBookings(restaurantId: restaurant.id)
            
            // Фильтруем брони по дате
            let todayBookings = allBookings.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
            let yesterdayBookings = allBookings.filter { Calendar.current.isDate($0.date, inSameDayAs: yesterday) }
            
            // Вычисляем статистику
            todayStats.newBookings = todayBookings.count
            todayStats.confirmedBookings = todayBookings.filter { $0.status == .confirmed }.count
            todayStats.pendingBookings = todayBookings.filter { $0.status == .pending }.count
            
            let confirmedRate = todayBookings.isEmpty ? 0 : (todayStats.confirmedBookings * 100) / todayBookings.count
            todayStats.confirmationRate = confirmedRate
            
            // Вычисляем изменения по сравнению со вчера
            let yesterdayNewBookings = yesterdayBookings.count
            todayStats.newBookingsChange = yesterdayNewBookings == 0 ? 100 : ((todayStats.newBookings - yesterdayNewBookings) * 100) / yesterdayNewBookings
            
            // Выручка (моковые данные для демо)
            todayStats.revenue = Int.random(in: 25000...75000)
            todayStats.revenueChange = Int.random(in: -15...25)
            
        } catch {
            errorMessage = "Не удалось загрузить статистику: \(error.localizedDescription)"
        }
    }
    
    private func loadUpcomingBookings() async {
        guard let restaurant = restaurant else { return }
        
        do {
            let today = Date()
            let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today) ?? today
            
            let allBookings = try await bookingRepository.fetchRestaurantBookings(restaurantId: restaurant.id)
            
            upcomingBookings = allBookings
                .filter { $0.date >= today && $0.date <= nextWeek }
                .filter { $0.status == .pending || $0.status == .confirmed }
                .sorted { $0.date < $1.date }
                .prefix(10)
                .map { $0 }
            
        } catch {
            errorMessage = "Не удалось загрузить брони: \(error.localizedDescription)"
        }
    }
    
    private func loadNotifications() async {
        // Загружаем уведомления для ресторана
        notifications = [
            Notification(
                id: "1",
                title: "Новое бронирование",
                message: "Столик на 4 персоны забронирован на 19:00",
                type: .booking,
                isRead: false,
                createdAt: Date(),
                icon: "calendar.badge.plus",
                color: .blue
            ),
            Notification(
                id: "2",
                title: "Отмена брони",
                message: "Бронирование на 20:30 отменено",
                type: .cancellation,
                isRead: false,
                createdAt: Date().addingTimeInterval(-3600),
                icon: "xmark.circle.fill",
                color: .red
            ),
            Notification(
                id: "3",
                title: "AI-рекомендация",
                message: "Оптимизация столиков может увеличить выручку на 15%",
                type: .ai,
                isRead: true,
                createdAt: Date().addingTimeInterval(-7200),
                icon: "brain.head.profile",
                color: .purple
            )
        ]
    }
    
    private func loadAnalyticsData() async {
        // Загружаем данные для графиков
        hourlyLoadData = (12...22).map { hour in
            HourlyLoadData(
                hour: "\(hour):00",
                load: Double.random(in: 0.3...1.0)
            )
        }
        
        popularTablesData = [
            PopularTableData(tableName: "VIP-столик", bookingCount: 8, revenue: 45000),
            PopularTableData(tableName: "У окна", bookingCount: 12, revenue: 38000),
            PopularTableData(tableName: "Терраса", bookingCount: 6, revenue: 28000),
            PopularTableData(tableName: "Центр", bookingCount: 10, revenue: 32000)
        ]
    }
    
    private func loadAIRecommendations() async {
        // AI-рекомендации загружаются автоматически при анализе данных
        // Здесь можно добавить дополнительную логику
    }
    
    // MARK: - Quick Actions
    func confirmAllBookings() {
        Task {
            do {
                let pendingBookings = upcomingBookings.filter { $0.status == .pending }
                for booking in pendingBookings {
                    _ = try await bookingRepository.updateBookingStatus(bookingId: booking.id, status: .confirmed)
                }
                
                await loadUpcomingBookings()
                await loadTodayStats()
                
                // Показываем уведомление об успехе
                showSuccessMessage("Все брони подтверждены")
                
            } catch {
                errorMessage = "Не удалось подтвердить брони: \(error.localizedDescription)"
            }
        }
    }
    
    func createManualBooking() {
        showingManualBooking = true
        analyticsService.logEvent(.manualBookingOpened, parameters: [
            AnalyticsParameter.restaurantId.rawValue: restaurant?.id ?? "unknown"
        ])
    }
    
    func toggleRestaurantStatus() {
        Task {
            guard let restaurant = restaurant else { 
                showError("Ресторан не найден")
                return 
            }
            
            do {
                let updatedRestaurant = Restaurant(
                    id: restaurant.id,
                    name: restaurant.name,
                    description: restaurant.description,
                    cuisineType: restaurant.cuisineType,
                    address: restaurant.address,
                    coordinates: restaurant.coordinates,
                    phoneNumber: restaurant.phoneNumber,
                    website: restaurant.website,
                    rating: restaurant.rating,
                    reviewCount: restaurant.reviewCount,
                    priceRange: restaurant.priceRange,
                    workingHours: restaurant.workingHours,
                    photos: restaurant.photos,
                    isOpen: !restaurant.isOpen,
                    isVerified: restaurant.isVerified,
                    ownerId: restaurant.ownerId,
                    subscriptionPlan: restaurant.subscriptionPlan,
                    status: restaurant.status,
                    features: restaurant.features,
                    tables: restaurant.tables,
                    menu: restaurant.menu,
                    analytics: restaurant.analytics,
                    settings: restaurant.settings
                )
                
                // Обновляем в Firebase
                try await restaurantRepository.updateRestaurant(updatedRestaurant)
                
                // Обновляем локальное состояние
                self.restaurant = updatedRestaurant
                
                let status = updatedRestaurant.isOpen ? "открыт" : "закрыт"
                showSuccessMessage("Ресторан \(status)")
                
                analyticsService.logEvent(.restaurantStatusChanged, parameters: [
                    AnalyticsParameter.restaurantId.rawValue: restaurant.id,
                    "new_status": updatedRestaurant.isOpen ? "open" : "closed"
                ])
                
            } catch {
                showError("Не удалось изменить статус: \(error.localizedDescription)")
            }
        }
    }
    
    func openAIAssistant() {
        showingAIAssistant = true
        analyticsService.logEvent(.aiAssistantOpened, parameters: [
            AnalyticsParameter.restaurantId.rawValue: restaurant?.id ?? "unknown"
        ])
    }
    
    // MARK: - AI Actions
    func applyAIRecommendation() {
        Task {
            do {
                // Применяем AI-рекомендацию
                let recommendation = "Оптимизация столиков"
                
                // Здесь будет логика применения рекомендации
                try await Task.sleep(nanoseconds: 1_000_000_000) // Имитация обработки
                
                showSuccessMessage("AI-рекомендация применена: \(recommendation)")
                
                // Обновляем данные
                await loadAnalyticsData()
                
            } catch {
                errorMessage = "Не удалось применить рекомендацию: \(error.localizedDescription)"
            }
        }
    }
    
    func handleCancellationRisk() {
        Task {
            do {
                // Обрабатываем риск отмены
                let riskMessage = "Отправлено напоминание гостю о брони"
                
                try await Task.sleep(nanoseconds: 1_000_000_000) // Имитация обработки
                
                showSuccessMessage(riskMessage)
                
            } catch {
                errorMessage = "Не удалось обработать риск отмены: \(error.localizedDescription)"
            }
        }
    }
    
    func createPersonalizedMenu() {
        Task {
            do {
                // Создаем персонализированное меню
                let menuMessage = "Персонализированное меню создано"
                
                try await Task.sleep(nanoseconds: 1_000_000_000) // Имитация обработки
                
                showSuccessMessage(menuMessage)
                
            } catch {
                errorMessage = "Не удалось создать меню: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Booking Actions
    func handleBookingAction(_ booking: Booking) {
        showingBookingDetail = booking
        analyticsService.logEvent(.bookingDetailOpened, parameters: [
            AnalyticsParameter.bookingId.rawValue: booking.id,
            AnalyticsParameter.restaurantId.rawValue: restaurant?.id ?? "unknown"
        ])
    }
    
    func confirmBooking(_ booking: Booking) {
        Task { @MainActor in
            do {
                _ = try await bookingRepository.updateBookingStatus(bookingId: booking.id, status: .confirmed)
                await loadUpcomingBookings()
                await loadTodayStats()
                showSuccessMessage("Бронирование подтверждено")
                
                analyticsService.logEvent(.bookingConfirmed, parameters: [
                    AnalyticsParameter.bookingId.rawValue: booking.id,
                    AnalyticsParameter.restaurantId.rawValue: restaurant?.id ?? "unknown"
                ])
                
            } catch {
                showError("Не удалось подтвердить бронирование: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelBooking(_ booking: Booking) {
        Task { @MainActor in
            do {
                _ = try await bookingRepository.updateBookingStatus(bookingId: booking.id, status: .cancelled)
                await loadUpcomingBookings()
                await loadTodayStats()
                showSuccessMessage("Бронирование отменено")
                
                analyticsService.logEvent(.bookingCancelled, parameters: [
                    AnalyticsParameter.bookingId.rawValue: booking.id,
                    AnalyticsParameter.restaurantId.rawValue: restaurant?.id ?? "unknown"
                ])
                
            } catch {
                showError("Не удалось отменить бронирование: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Notification Actions
    func handleNotification(_ notification: Notification) {
        // Помечаем уведомление как прочитанное
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            let updatedNotification = Notification(
                id: notification.id,
                title: notification.title,
                message: notification.message,
                type: notification.type,
                isRead: true,
                createdAt: notification.createdAt,
                icon: notification.icon,
                color: notification.color
            )
            notifications[index] = updatedNotification
        }
        
        analyticsService.logEvent(.notificationTapped, parameters: [
            "notification_id": notification.id,
            AnalyticsParameter.notificationType.rawValue: notification.type.rawValue
        ])
    }
    
    func markAllNotificationsAsRead() {
        notifications = notifications.map { notification in
            Notification(
                id: notification.id,
                title: notification.title,
                message: notification.message,
                type: notification.type,
                isRead: true,
                createdAt: notification.createdAt,
                icon: notification.icon,
                color: notification.color
            )
        }
        showSuccessMessage("Все уведомления прочитаны")
    }
    
    // MARK: - Data Refresh
    func refreshData() async {
        await loadTodayStats()
        await loadUpcomingBookings()
        await loadNotifications()
        await loadAnalyticsData()
    }
    
    // MARK: - Helper Methods
    func setCurrentUser(_ user: User?) {
        currentUser = user
        if let user = user {
            // Логируем вход пользователя
            analyticsService.setUserId(user.id)
            analyticsService.setUserProperty(user.role.rawValue, forName: "user_role")
            
            Task {
                await refreshData()
            }
        }
    }
    
    private func getCurrentUser() async -> User? {
        // Получаем текущего пользователя из AppState
        return currentUser
    }
    
    private func showSuccessMessage(_ message: String) {
        toastMessage = message
        toastType = .success
        showToast = true
        
        // Автоматически скрываем toast через 3 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showToast = false
        }
    }
    
    private func showError(_ message: String) {
        toastMessage = message
        toastType = .error
        showToast = true
        
        // Автоматически скрываем toast через 5 секунд
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showToast = false
        }
    }
    
    func hideToast() {
        showToast = false
    }
    
    // MARK: - Manual Booking Creation
    func createBooking(_ booking: Booking) async {
        do {
            _ = try await bookingRepository.createBooking(booking)
            await loadUpcomingBookings()
            await loadTodayStats()
            showSuccessMessage("Бронирование создано")
            
            analyticsService.logEvent(.manualBookingCreated, parameters: [
                AnalyticsParameter.bookingId.rawValue: booking.id,
                AnalyticsParameter.restaurantId.rawValue: restaurant?.id ?? "unknown"
            ])
            
        } catch {
            showError("Не удалось создать бронирование: \(error.localizedDescription)")
        }
    }
}

// MARK: - Supporting Models

struct TodayStats {
    var newBookings: Int = 0
    var newBookingsChange: Int = 0
    var confirmedBookings: Int = 0
    var confirmationRate: Int = 0
    var pendingBookings: Int = 0
    var revenue: Int = 0
    var revenueChange: Int = 0
}

struct HourlyLoadData: Identifiable {
    let id = UUID()
    let hour: String
    let load: Double
}

struct PopularTableData: Identifiable {
    let id = UUID()
    let tableName: String
    let bookingCount: Int
    let revenue: Int
}

struct Notification: Identifiable {
    let id: String
    let title: String
    let message: String
    let type: NotificationType
    let isRead: Bool
    let createdAt: Date
    let icon: String
    let color: Color
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

enum NotificationType: String, CaseIterable {
    case booking = "booking"
    case cancellation = "cancellation"
    case review = "review"
    case ai = "ai"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .booking: return "Бронирование"
        case .cancellation: return "Отмена"
        case .review: return "Отзыв"
        case .ai: return "AI"
        case .system: return "Система"
        }
    }
}

enum ToastType {
    case success
    case error
    case warning
    case info
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
}
