import Foundation
import CoreLocation

// MARK: - Supporting Enums

enum CuisineType: String, Codable, CaseIterable {
    case european = "european"
    case asian = "asian"
    case italian = "italian"
    case japanese = "japanese"
    case chinese = "chinese"
    case indian = "indian"
    case mexican = "mexican"
    case mediterranean = "mediterranean"
    case american = "american"
    case russian = "russian"
    
    var displayName: String {
        switch self {
        case .european: return "Европейская"
        case .asian: return "Азиатская"
        case .italian: return "Итальянская"
        case .japanese: return "Японская"
        case .chinese: return "Китайская"
        case .indian: return "Индийская"
        case .mexican: return "Мексиканская"
        case .mediterranean: return "Средиземноморская"
        case .american: return "Американская"
        case .russian: return "Русская"
        }
    }
}

enum PriceRange: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case premium = "premium"
    
    var displayName: String {
        switch self {
        case .low: return "Экономно"
        case .medium: return "Средне"
        case .high: return "Дорого"
        case .premium: return "Премиум"
        }
    }
    
    var range: String {
        switch self {
        case .low: return "до ₽1,000"
        case .medium: return "₽1,000 - ₽3,000"
        case .high: return "₽3,000 - ₽8,000"
        case .premium: return "от ₽8,000"
        }
    }
}

struct WorkingHours: Codable {
    let monday: DayHours
    let tuesday: DayHours
    let wednesday: DayHours
    let thursday: DayHours
    let friday: DayHours
    let saturday: DayHours
    let sunday: DayHours
    
    init() {
        self.monday = DayHours()
        self.tuesday = DayHours()
        self.wednesday = DayHours()
        self.thursday = DayHours()
        self.friday = DayHours()
        self.saturday = DayHours()
        self.sunday = DayHours()
    }
    
    init(monday: DayHours, tuesday: DayHours, wednesday: DayHours, thursday: DayHours, friday: DayHours, saturday: DayHours, sunday: DayHours) {
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
    }
}

struct DayHours: Codable {
    let isOpen: Bool
    let openTime: String
    let closeTime: String
    
    init(isOpen: Bool = true, openTime: String = "09:00", closeTime: String = "22:00") {
        self.isOpen = isOpen
        self.openTime = openTime
        self.closeTime = closeTime
    }
}

// MARK: - Restaurant Model

struct Restaurant: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let cuisineType: CuisineType
    let address: String
    let coordinates: CLLocationCoordinate2D
    let phoneNumber: String
    let website: String?
    let rating: Double
    let reviewCount: Int
    let priceRange: PriceRange
    let workingHours: WorkingHours
    let photos: [String]
    let isOpen: Bool
    let isVerified: Bool
    let ownerId: String
    
    // Админка ресторана
    let subscriptionPlan: SubscriptionPlan
    let status: RestaurantStatus
    let features: [RestaurantFeature]
    let tables: [Table]
    let menu: Menu
    let analytics: RestaurantAnalytics
    let settings: RestaurantSettings
    
    init(id: String, name: String, description: String, cuisineType: CuisineType, address: String, coordinates: CLLocationCoordinate2D, phoneNumber: String, website: String? = nil, rating: Double = 0.0, reviewCount: Int = 0, priceRange: PriceRange = .medium, workingHours: WorkingHours = WorkingHours(), photos: [String] = [], isOpen: Bool = true, isVerified: Bool = false, ownerId: String, subscriptionPlan: SubscriptionPlan = .free, status: RestaurantStatus = .active, features: [RestaurantFeature] = [], tables: [Table] = [], menu: Menu = Menu(), analytics: RestaurantAnalytics = RestaurantAnalytics(), settings: RestaurantSettings = RestaurantSettings()) {
        self.id = id
        self.name = name
        self.description = description
        self.cuisineType = cuisineType
        self.address = address
        self.coordinates = coordinates
        self.phoneNumber = phoneNumber
        self.website = website
        self.rating = rating
        self.reviewCount = reviewCount
        self.priceRange = priceRange
        self.workingHours = workingHours
        self.photos = photos
        self.isOpen = isOpen
        self.isVerified = isVerified
        self.ownerId = ownerId
        self.subscriptionPlan = subscriptionPlan
        self.status = status
        self.features = features
        self.tables = tables
        self.menu = menu
        self.analytics = analytics
        self.settings = settings
    }
}

enum RestaurantStatus: String, Codable, CaseIterable {
    case active = "active"
    case pending = "pending"
    case suspended = "suspended"
    case closed = "closed"
    
    var displayName: String {
        switch self {
        case .active: return "Активен"
        case .pending: return "На модерации"
        case .suspended: return "Приостановлен"
        case .closed: return "Закрыт"
        }
    }
    
    var color: String {
        switch self {
        case .active: return "green"
        case .pending: return "orange"
        case .suspended: return "red"
        case .closed: return "gray"
        }
    }
}

enum RestaurantFeature: String, Codable, CaseIterable {
    case wifi = "wifi"
    case parking = "parking"
    case delivery = "delivery"
    case takeaway = "takeaway"
    case outdoorSeating = "outdoorSeating"
    case `private` = "private"
    case liveMusic = "liveMusic"
    case kidsMenu = "kidsMenu"
    case wheelchairAccessible = "wheelchairAccessible"
    case petFriendly = "petFriendly"
    
    var displayName: String {
        switch self {
        case .wifi: return "Wi-Fi"
        case .parking: return "Парковка"
        case .delivery: return "Доставка"
        case .takeaway: return "На вынос"
        case .outdoorSeating: return "Летняя веранда"
        case .`private`: return "Приватные залы"
        case .liveMusic: return "Живая музыка"
        case .kidsMenu: return "Детское меню"
        case .wheelchairAccessible: return "Доступно для инвалидов"
        case .petFriendly: return "С животными"
        }
    }
}

// MARK: - Table Model

struct Table: Codable, Identifiable {
    let id: String
    let number: Int
    let capacity: Int
    let location: TableLocation
    let features: [TableFeature]
    let isAvailable: Bool
    let price: Double
    
    init(id: String, number: Int, capacity: Int, location: TableLocation = .indoor, features: [TableFeature] = [], isAvailable: Bool = true, price: Double = 0.0) {
        self.id = id
        self.number = number
        self.capacity = capacity
        self.location = location
        self.features = features
        self.isAvailable = isAvailable
        self.price = price
    }
}

enum TableLocation: String, Codable, CaseIterable {
    case indoor = "indoor"
    case outdoor = "outdoor"
    case window = "window"
    case bar = "bar"
    case `private` = "private"
    
    var displayName: String {
        switch self {
        case .indoor: return "Внутри"
        case .outdoor: return "На улице"
        case .window: return "У окна"
        case .bar: return "Барная стойка"
        case .`private`: return "Приватный зал"
        }
    }
}

enum TableFeature: String, Codable, CaseIterable {
    case quiet = "quiet"
    case romantic = "romantic"
    case business = "business"
    case family = "family"
    case accessible = "accessible"
    
    var displayName: String {
        switch self {
        case .quiet: return "Тихий уголок"
        case .romantic: return "Романтично"
        case .business: return "Для бизнеса"
        case .family: return "Семейный"
        case .accessible: return "Доступно"
        }
    }
}

// MARK: - Menu Model

struct Menu: Codable {
    let categories: [MenuCategory]
    let specialOffers: [SpecialOffer]
    let seasonalItems: [SeasonalItem]
    
    init(categories: [MenuCategory] = [], specialOffers: [SpecialOffer] = [], seasonalItems: [SeasonalItem] = []) {
        self.categories = categories
        self.specialOffers = specialOffers
        self.seasonalItems = seasonalItems
    }
}

struct MenuCategory: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let items: [MenuItem]
    
    init(id: String, name: String, description: String, items: [MenuItem] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.items = items
    }
}

struct MenuItem: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let allergens: [Allergen]
    let isVegetarian: Bool
    let isVegan: Bool
    let photoURL: String?
    
    init(id: String, name: String, description: String, price: Double, allergens: [Allergen] = [], isVegetarian: Bool = false, isVegan: Bool = false, photoURL: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.allergens = allergens
        self.isVegetarian = isVegetarian
        self.isVegan = isVegan
        self.photoURL = photoURL
    }
}

enum Allergen: String, Codable, CaseIterable {
    case gluten = "gluten"
    case dairy = "dairy"
    case nuts = "nuts"
    case shellfish = "shellfish"
    case eggs = "eggs"
    case soy = "soy"
    
    var displayName: String {
        switch self {
        case .gluten: return "Глютен"
        case .dairy: return "Молочные продукты"
        case .nuts: return "Орехи"
        case .shellfish: return "Морепродукты"
        case .eggs: return "Яйца"
        case .soy: return "Соя"
        }
    }
}

struct SpecialOffer: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let originalPrice: Double
    let discountedPrice: Double
    let validUntil: Date
    let conditions: String
    
    init(id: String, name: String, description: String, originalPrice: Double, discountedPrice: Double, validUntil: Date, conditions: String) {
        self.id = id
        self.name = name
        self.description = description
        self.originalPrice = originalPrice
        self.discountedPrice = discountedPrice
        self.validUntil = validUntil
        self.conditions = conditions
    }
}

struct SeasonalItem: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let season: Season
    let availableFrom: Date
    let availableUntil: Date
    
    init(id: String, name: String, description: String, price: Double, season: Season, availableFrom: Date, availableUntil: Date) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.season = season
        self.availableFrom = availableFrom
        self.availableUntil = availableUntil
    }
}

enum Season: String, Codable, CaseIterable {
    case spring = "spring"
    case summer = "summer"
    case autumn = "autumn"
    case winter = "winter"
    
    var displayName: String {
        switch self {
        case .spring: return "Весна"
        case .summer: return "Лето"
        case .autumn: return "Осень"
        case .winter: return "Зима"
        }
    }
}

// MARK: - Analytics Model

struct RestaurantAnalytics: Codable {
    let totalBookings: Int
    let averageRating: Double
    let popularTimes: [PopularTime]
    let popularTables: [PopularTable]
    let revenue: Double
    let customerSatisfaction: Double
    
    init(totalBookings: Int = 0, averageRating: Double = 0.0, popularTimes: [PopularTime] = [], popularTables: [PopularTable] = [], revenue: Double = 0.0, customerSatisfaction: Double = 0.0) {
        self.totalBookings = totalBookings
        self.averageRating = averageRating
        self.popularTimes = popularTimes
        self.popularTables = popularTables
        self.revenue = revenue
        self.customerSatisfaction = customerSatisfaction
    }
}

struct PopularTime: Codable {
    let hour: Int
    let bookingCount: Int
    let averageWaitTime: Int
    
    init(hour: Int, bookingCount: Int, averageWaitTime: Int) {
        self.hour = hour
        self.bookingCount = bookingCount
        self.averageWaitTime = averageWaitTime
    }
}

struct PopularTable: Codable {
    let tableId: String
    let tableNumber: Int
    let bookingCount: Int
    let averageRating: Double
    
    init(tableId: String, tableNumber: Int, bookingCount: Int, averageRating: Double) {
        self.tableId = tableId
        self.tableNumber = tableNumber
        self.bookingCount = bookingCount
        self.averageRating = averageRating
    }
}

// MARK: - Settings Model

struct RestaurantSettings: Codable {
    let cancellationPolicy: CancellationPolicy
    let notificationSettings: RestaurantNotificationSettings
    let integrationSettings: IntegrationSettings
    
    init(cancellationPolicy: CancellationPolicy = CancellationPolicy(), notificationSettings: RestaurantNotificationSettings = RestaurantNotificationSettings(), integrationSettings: IntegrationSettings = IntegrationSettings()) {
        self.cancellationPolicy = cancellationPolicy
        self.notificationSettings = notificationSettings
        self.integrationSettings = integrationSettings
    }
}

struct CancellationPolicy: Codable {
    let freeCancellationHours: Int
    let partialRefundHours: Int
    let noRefundHours: Int
    let description: String
    
    init(freeCancellationHours: Int = 24, partialRefundHours: Int = 12, noRefundHours: Int = 2, description: String = "Бесплатная отмена за 24 часа") {
        self.freeCancellationHours = freeCancellationHours
        self.partialRefundHours = partialRefundHours
        self.noRefundHours = noRefundHours
        self.description = description
    }
}

struct RestaurantNotificationSettings: Codable {
    let newBookings: Bool
    let cancellations: Bool
    let reviews: Bool
    let systemUpdates: Bool
    let marketing: Bool
    
    init(newBookings: Bool = true, cancellations: Bool = true, reviews: Bool = true, systemUpdates: Bool = true, marketing: Bool = false) {
        self.newBookings = newBookings
        self.cancellations = cancellations
        self.reviews = reviews
        self.systemUpdates = systemUpdates
        self.marketing = marketing
    }
}

struct IntegrationSettings: Codable {
    let posIntegration: Bool
    let deliveryIntegration: Bool
    let paymentIntegration: Bool
    let analyticsIntegration: Bool
    
    init(posIntegration: Bool = false, deliveryIntegration: Bool = false, paymentIntegration: Bool = false, analyticsIntegration: Bool = false) {
        self.posIntegration = posIntegration
        self.deliveryIntegration = deliveryIntegration
        self.paymentIntegration = paymentIntegration
        self.analyticsIntegration = analyticsIntegration
    }
}

// MARK: - CLLocationCoordinate2D Codable Extension

extension CLLocationCoordinate2D: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
}

// MARK: - Extensions for Admin
extension RestaurantStatus {
    var adminDisplayName: String {
        switch self {
        case .active: return "Активен"
        case .pending: return "На модерации"
        case .suspended: return "Заблокирован"
        case .closed: return "Закрыт"
        }
    }
    
    var adminColor: Color {
        switch self {
        case .active: return .green
        case .pending: return .orange
        case .suspended: return .red
        case .closed: return .gray
        }
    }
}

extension SubscriptionPlan {
    var adminDisplayName: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium"
        case .enterprise: return "Enterprise"
        }
    }
    
    var adminColor: Color {
        switch self {
        case .free: return .gray
        case .premium: return .purple
        case .enterprise: return .yellow
        }
    }
}

import SwiftUI