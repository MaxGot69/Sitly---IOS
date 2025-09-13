import Foundation

struct Review: Identifiable, Codable, Equatable {
    let id: String
    let restaurantId: String
    let userId: String
    let userName: String
    let rating: Double
    let text: String
    let createdAt: Date
    let photos: [String]?
    let helpfulCount: Int
    let isVerified: Bool
    
    init(
        id: String = UUID().uuidString,
        restaurantId: String,
        userId: String,
        userName: String,
        rating: Double,
        text: String,
        createdAt: Date = Date(),
        photos: [String]? = nil,
        helpfulCount: Int = 0,
        isVerified: Bool = false
    ) {
        self.id = id
        self.restaurantId = restaurantId
        self.userId = userId
        self.userName = userName
        self.rating = rating
        self.text = text
        self.createdAt = createdAt
        self.photos = photos
        self.helpfulCount = helpfulCount
        self.isVerified = isVerified
    }
    
    // Валидация рейтинга
    var isValidRating: Bool {
        rating >= 1.0 && rating <= 5.0
    }
    
    // Форматированная дата
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: createdAt)
    }
    
    // Время с момента создания
    var timeAgo: String {
        let interval = Date().timeIntervalSince(createdAt)
        let days = Int(interval / 86400)
        let hours = Int((interval.truncatingRemainder(dividingBy: 86400)) / 3600)
        
        if days > 0 {
            return "\(days) дн. назад"
        } else if hours > 0 {
            return "\(hours) ч. назад"
        } else {
            return "Только что"
        }
    }
}

// MARK: - Review Statistics

struct ReviewStatistics: Codable {
    let averageRating: Double
    let totalReviews: Int
    let ratingDistribution: [Int: Int] // rating -> count
    let recentReviews: [Review]
    
    var ratingPercentage: Double {
        guard totalReviews > 0 else { return 0 }
        return (averageRating / 5.0) * 100
    }
    
    var hasReviews: Bool {
        totalReviews > 0
    }
}
