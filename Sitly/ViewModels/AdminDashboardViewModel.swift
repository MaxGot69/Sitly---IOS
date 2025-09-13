import Foundation
import Combine

@MainActor
class AdminDashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var totalRestaurants = 247
    @Published var newRestaurantsToday = 3
    @Published var activeUsers = 12847
    @Published var newUsersToday = 156
    @Published var todayBookings = 1284
    @Published var bookingGrowth = 18.5
    @Published var todayRevenue = 2847390
    @Published var revenueGrowth = 24.7
    
    @Published var weeklyBookingsData: [BookingData] = []
    @Published var cityStats: [CityStats] = []
    @Published var recentActivities: [AdminActivity] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    init() {
        generateMockData()
    }
    
    // MARK: - Data Loading
    func loadDashboardData() {
        isLoading = true
        
        // Имитация загрузки данных
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshStats()
            self.isLoading = false
        }
    }
    
    private func refreshStats() {
        // Обновление статистики в реальном времени
        totalRestaurants += Int.random(in: 0...2)
        activeUsers += Int.random(in: 10...50)
        todayBookings += Int.random(in: 5...25)
        todayRevenue += Int.random(in: 1000...10000)
        
        // Обновление данных графиков
        updateChartData()
        updateRecentActivities()
    }
    
    private func generateMockData() {
        // Данные для графика бронирований за неделю
        let days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
        weeklyBookingsData = days.enumerated().map { index, day in
            BookingData(
                day: day,
                bookings: Int.random(in: 800...1500) + (index >= 4 ? 300 : 0) // Выходные больше
            )
        }
        
        // Статистика по городам
        cityStats = [
            CityStats(city: "Москва", users: 8420, percentage: 0.85),
            CityStats(city: "Санкт-Петербург", users: 2156, percentage: 0.65),
            CityStats(city: "Новосибирск", users: 834, percentage: 0.4),
            CityStats(city: "Екатеринбург", users: 672, percentage: 0.32),
            CityStats(city: "Нижний Новгород", users: 456, percentage: 0.25),
            CityStats(city: "Казань", users: 309, percentage: 0.18)
        ]
        
        // Последние действия
        recentActivities = [
            AdminActivity(
                id: "1",
                type: .newRestaurant,
                title: "Новый ресторан",
                description: "\"Таверна у моря\" добавлен в систему",
                timeAgo: "2 мин назад"
            ),
            AdminActivity(
                id: "2",
                type: .userReport,
                title: "Жалоба пользователя",
                description: "Отзыв о ресторане требует модерации",
                timeAgo: "15 мин назад"
            ),
            AdminActivity(
                id: "3",
                type: .systemUpdate,
                title: "Обновление системы",
                description: "AI рекомендации обновлены до версии 2.1",
                timeAgo: "1 час назад"
            ),
            AdminActivity(
                id: "4",
                type: .newUser,
                title: "Массовая регистрация",
                description: "156 новых пользователей за последний час",
                timeAgo: "1 час назад"
            ),
            AdminActivity(
                id: "5",
                type: .payment,
                title: "Крупная транзакция",
                description: "Ресторан \"Белуга\" оплатил Premium подписку",
                timeAgo: "2 часа назад"
            )
        ]
    }
    
    private func updateChartData() {
        // Обновление данных графика с небольшими изменениями
        for i in weeklyBookingsData.indices {
            weeklyBookingsData[i] = BookingData(
                day: weeklyBookingsData[i].day,
                bookings: weeklyBookingsData[i].bookings + Int.random(in: -50...50)
            )
        }
    }
    
    private func updateRecentActivities() {
        // Добавление новой активности
        let newActivities = [
            AdminActivity(
                id: UUID().uuidString,
                type: .newBooking,
                title: "Пиковая активность",
                description: "125 новых бронирований за последние 10 минут",
                timeAgo: "только что"
            )
        ]
        
        recentActivities = newActivities + Array(recentActivities.prefix(4))
    }
}

// MARK: - Data Models
struct BookingData {
    let day: String
    let bookings: Int
}

struct CityStats {
    let city: String
    let users: Int
    let percentage: Double
}

struct AdminActivity {
    let id: String
    let type: ActivityType
    let title: String
    let description: String
    let timeAgo: String
}

enum ActivityType {
    case newRestaurant
    case newUser
    case newBooking
    case userReport
    case systemUpdate
    case payment
    
    var color: Color {
        switch self {
        case .newRestaurant: return .blue
        case .newUser: return .green
        case .newBooking: return .orange
        case .userReport: return .red
        case .systemUpdate: return .purple
        case .payment: return .yellow
        }
    }
}

import SwiftUI
