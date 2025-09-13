import Foundation
import SwiftUI

@MainActor
class AdminAnalyticsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var totalRevenue = 8427350
    @Published var revenueGrowth = 24.7
    @Published var activeRestaurants = 247
    @Published var newRestaurantsCount = 12
    @Published var totalBookings = 15684
    @Published var bookingsGrowth = 18.5
    @Published var newUsers = 1247
    @Published var userGrowth = 32.1
    
    @Published var averageCheck = 2850
    @Published var conversionRate = 12.4
    @Published var averageSessionTime = 8
    @Published var cancellationRate = 7.2
    
    @Published var revenueData: [RevenueData] = []
    @Published var weeklyBookingsData: [WeeklyBookingData] = []
    @Published var cuisineStats: [CuisineStats] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    init() {
        generateMockData()
    }
    
    // MARK: - Public Methods
    func loadAnalytics() {
        isLoading = true
        
        // Имитация загрузки данных
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshAnalytics()
            self.isLoading = false
        }
    }
    
    private func refreshAnalytics() {
        // Обновление ключевых метрик
        totalRevenue += Int.random(in: 10000...50000)
        totalBookings += Int.random(in: 10...100)
        newUsers += Int.random(in: 5...25)
        
        // Обновление данных графиков
        updateChartsData()
    }
    
    // MARK: - Private Methods
    private func generateMockData() {
        // Данные выручки за последние 30 дней
        revenueData = (0..<30).map { dayOffset in
            let baseRevenue = 280000
            let variation = Int.random(in: -50000...80000)
            let weekendBonus = (dayOffset % 7 >= 5) ? 50000 : 0 // Выходные больше
            
            return RevenueData(
                day: dayOffset,
                revenue: baseRevenue + variation + weekendBonus
            )
        }
        
        // Данные бронирований по дням недели
        let weekDays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
        weeklyBookingsData = weekDays.enumerated().map { index, day in
            let baseBookings = 1200
            let weekendBonus = (index >= 5) ? 400 : 0 // Выходные больше
            let variation = Int.random(in: -200...300)
            
            return WeeklyBookingData(
                day: day,
                bookings: baseBookings + weekendBonus + variation
            )
        }
        
        // Статистика по типам кухонь
        cuisineStats = [
            CuisineStats(cuisine: "Европейская", percentage: 28.5, color: .blue),
            CuisineStats(cuisine: "Азиатская", percentage: 22.1, color: .orange),
            CuisineStats(cuisine: "Итальянская", percentage: 18.7, color: .green),
            CuisineStats(cuisine: "Японская", percentage: 15.3, color: .red),
            CuisineStats(cuisine: "Русская", percentage: 10.2, color: .purple),
            CuisineStats(cuisine: "Другие", percentage: 5.2, color: .gray)
        ]
    }
    
    private func updateChartsData() {
        // Небольшие обновления данных графиков
        for i in revenueData.indices {
            let change = Int.random(in: -10000...10000)
            revenueData[i] = RevenueData(
                day: revenueData[i].day,
                revenue: max(100000, revenueData[i].revenue + change)
            )
        }
        
        for i in weeklyBookingsData.indices {
            let change = Int.random(in: -50...50)
            weeklyBookingsData[i] = WeeklyBookingData(
                day: weeklyBookingsData[i].day,
                bookings: max(500, weeklyBookingsData[i].bookings + change)
            )
        }
    }
}

// MARK: - Data Models
struct RevenueData {
    let day: Int
    let revenue: Int
}

struct WeeklyBookingData {
    let day: String
    let bookings: Int
}

struct CuisineStats {
    let cuisine: String
    let percentage: Double
    let color: Color
}
