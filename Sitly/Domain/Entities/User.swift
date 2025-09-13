import Foundation
import CoreLocation

enum UserRole: String, Codable, CaseIterable {
    case client = "client"
    case restaurant = "restaurant"
    
    var displayName: String {
        switch self {
        case .client: return "Клиент"
        case .restaurant: return "Ресторан"
        }
    }
    
    var icon: String {
        switch self {
        case .client: return "person.fill"
        case .restaurant: return "building.2.fill"
        }
    }
}

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let role: UserRole
    let phoneNumber: String?
    let profileImageURL: String?
    let createdAt: Date
    let lastLoginAt: Date?
    
    // Для ресторанов
    let restaurantId: String?
    let isVerified: Bool
    let subscriptionPlan: SubscriptionPlan?
    
    // Для клиентов
    let preferences: UserPreferences?
    let favoriteRestaurants: [String]?
    
    init(id: String, email: String, name: String, role: UserRole = .client, phoneNumber: String? = nil, profileImageURL: String? = nil, createdAt: Date = Date(), lastLoginAt: Date? = nil, restaurantId: String? = nil, isVerified: Bool = false, subscriptionPlan: SubscriptionPlan? = nil, preferences: UserPreferences? = nil, favoriteRestaurants: [String]? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.role = role
        self.phoneNumber = phoneNumber
        self.profileImageURL = profileImageURL
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
        self.restaurantId = restaurantId
        self.isVerified = isVerified
        self.subscriptionPlan = subscriptionPlan
        self.preferences = preferences
        self.favoriteRestaurants = favoriteRestaurants
    }
}

enum SubscriptionPlan: String, Codable, CaseIterable {
    case free = "free"
    case premium = "premium"
    case enterprise = "enterprise"
    
    var displayName: String {
        switch self {
        case .free: return "Базовый"
        case .premium: return "Премиум"
        case .enterprise: return "Enterprise"
        }
    }
    
    var price: String {
        switch self {
        case .free: return "Бесплатно"
        case .premium: return "₽5,000/месяц"
        case .enterprise: return "По запросу"
        }
    }
    
    var features: [String] {
        switch self {
        case .free:
            return [
                "Базовые бронирования",
                "Профиль ресторана",
                "Email уведомления"
            ]
        case .premium:
            return [
                "Все функции Free",
                "AI-аналитика",
                "Push уведомления",
                "Расширенная статистика",
                "Интеграции с POS"
            ]
        case .enterprise:
            return [
                "Все функции Premium",
                "Персональный менеджер",
                "API доступ",
                "Белый лейбл",
                "Приоритетная поддержка"
            ]
        }
    }
}

struct UserPreferences: Codable {
    let cuisineTypes: [String]
    let priceRange: PriceRange
    let maxDistance: Double
    let preferredTimes: [String]
    let dietaryRestrictions: [DietaryRestriction]
    let notificationSettings: NotificationSettings

    init(cuisineTypes: [String] = [], priceRange: PriceRange = .medium, maxDistance: Double = 10.0, preferredTimes: [String] = [], dietaryRestrictions: [DietaryRestriction] = [], notificationSettings: NotificationSettings = NotificationSettings()) {
        self.cuisineTypes = cuisineTypes
        self.priceRange = priceRange
        self.maxDistance = maxDistance
        self.preferredTimes = preferredTimes
        self.dietaryRestrictions = dietaryRestrictions
        self.notificationSettings = notificationSettings
    }
}

enum DietaryRestriction: String, Codable, CaseIterable {
    case vegetarian = "vegetarian"
    case vegan = "vegan"
    case glutenFree = "glutenFree"
    case dairyFree = "dairyFree"
    case nutFree = "nutFree"
    case halal = "halal"
    case kosher = "kosher"

    var displayName: String {
        switch self {
        case .vegetarian: return "Вегетарианство"
        case .vegan: return "Веганство"
        case .glutenFree: return "Без глютена"
        case .dairyFree: return "Без молока"
        case .nutFree: return "Без орехов"
        case .halal: return "Халяль"
        case .kosher: return "Кошер"
        }
    }
}

struct NotificationSettings: Codable {
    let pushEnabled: Bool
    let emailEnabled: Bool
    let smsEnabled: Bool
    let bookingConfirmations: Bool
    let bookingReminders: Bool
    let promotions: Bool
    let newRestaurants: Bool

    init(pushEnabled: Bool = true, emailEnabled: Bool = true, smsEnabled: Bool = false, bookingConfirmations: Bool = true, bookingReminders: Bool = true, promotions: Bool = false, newRestaurants: Bool = true) {
        self.pushEnabled = pushEnabled
        self.emailEnabled = emailEnabled
        self.smsEnabled = smsEnabled
        self.bookingConfirmations = bookingConfirmations
        self.bookingReminders = bookingReminders
        self.promotions = promotions
        self.newRestaurants = newRestaurants
    }
}
