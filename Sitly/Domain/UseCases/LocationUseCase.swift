import Foundation
import CoreLocation

// MARK: - Location Use Case Protocol

protocol LocationUseCaseProtocol {
    func getCurrentLocation() async throws -> CLLocationCoordinate2D
    func requestLocationPermission() async -> Bool
    func getNearbyRestaurants(latitude: Double, longitude: Double, radius: Double) async throws -> [Restaurant]
}

// MARK: - Location Use Case

final class LocationUseCase: LocationUseCaseProtocol {
    private let locationService: LocationServiceProtocol
    private let restaurantRepository: RestaurantRepositoryProtocol
    
    init(locationService: LocationServiceProtocol, restaurantRepository: RestaurantRepositoryProtocol) {
        self.locationService = locationService
        self.restaurantRepository = restaurantRepository
    }
    
    // MARK: - Location Methods
    
    func getCurrentLocation() async throws -> CLLocationCoordinate2D {
        do {
            return try await locationService.getCurrentLocation()
        } catch {
            throw UseCaseError.businessLogicError("Не удалось получить текущее местоположение: \(error.localizedDescription)")
        }
    }
    
    func requestLocationPermission() async -> Bool {
        return await locationService.requestLocationPermission()
    }
    
    func startLocationUpdates() {
        locationService.startLocationUpdates()
    }
    
    func stopLocationUpdates() {
        locationService.stopLocationUpdates()
    }
    
    // MARK: - Restaurant Location Methods
    
    func getNearbyRestaurants(latitude: Double, longitude: Double, radius: Double) async throws -> [Restaurant] {
        let restaurants = try await restaurantRepository.fetchRestaurants()
        
        let nearbyRestaurants = restaurants.filter { restaurant in
            let distance = calculateDistance(
                from: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                to: restaurant.coordinates
            )
            return distance <= radius
        }
        
        return nearbyRestaurants.sorted { first, second in
            let distance1 = calculateDistance(
                from: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                to: first.coordinates
            )
            let distance2 = calculateDistance(
                from: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                to: second.coordinates
            )
            return distance1 < distance2
        }
    }
    
    func getRestaurantsInRadius(_ radius: Double) async throws -> [Restaurant] {
        let currentLocation = try await getCurrentLocation()
        return try await getNearbyRestaurants(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
            radius: radius
        )
    }
    
    func getPopularRestaurants(latitude: Double, longitude: Double, limit: Int = 10) async throws -> [Restaurant] {
        let restaurants = try await restaurantRepository.fetchRestaurants()
        
        let popularRestaurants = restaurants.sorted { first, second in
            let score1 = calculatePopularityScore(restaurant: first)
            let score2 = calculatePopularityScore(restaurant: second)
            return score1 > score2
        }
        
        return Array(popularRestaurants.prefix(limit))
    }
    
    func getRestaurantsByCuisine(_ cuisine: String, latitude: Double, longitude: Double) async throws -> [Restaurant] {
        let restaurants = try await restaurantRepository.fetchRestaurantsByCuisine(cuisine)
        
        let sortedRestaurants = restaurants.sorted { first, second in
            let distance1 = calculateDistance(
                from: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                to: first.coordinates
            )
            let distance2 = calculateDistance(
                from: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                to: second.coordinates
            )
            return distance1 < distance2
        }
        
        return sortedRestaurants
    }
    
    func getRestaurantRecommendations(for user: User, latitude: Double, longitude: Double) async throws -> [Restaurant] {
        let restaurants = try await restaurantRepository.fetchRestaurants()
        let recommendations = restaurants.compactMap { restaurant -> (Restaurant, Double)? in
            let distance = calculateDistance(from: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), to: restaurant.coordinates)
            
            // Проверяем соответствие предпочтениям пользователя
            let preferenceScore = calculatePreferenceScore(restaurant: restaurant, user: user)
            
            if preferenceScore > 0.5 && distance <= 20.0 { // 20 км максимум
                let finalScore = preferenceScore * (1.0 / (1.0 + distance))
                return (restaurant, finalScore)
            }
            return nil
        }
        
        return recommendations.sorted { first, second in
            return first.1 > second.1
        }.map { $0.0 }
    }
    
    func getRestaurantAnalytics(latitude: Double, longitude: Double) async throws -> RestaurantAnalytics {
        let restaurants = try await restaurantRepository.fetchRestaurants()
        let currentLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        let nearbyRestaurants = restaurants.filter { restaurant in
            let distance = calculateDistance(from: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), to: restaurant.coordinates)
            return distance <= 10.0 // 10 км
        }
        
        let cuisineDistribution = nearbyRestaurants.reduce(into: [String: Int]()) { result, restaurant in
            result[restaurant.cuisineType.rawValue, default: 0] += 1
        }
        
        let averageRating = nearbyRestaurants.map { $0.rating }.reduce(0, +) / Double(max(nearbyRestaurants.count, 1))
        
        return RestaurantAnalytics(
            totalBookings: nearbyRestaurants.count,
            averageRating: averageRating,
            popularTimes: [],
            popularTables: [],
            revenue: 0.0,
            customerSatisfaction: averageRating
        )
    }
    
    // MARK: - Route Planning
    
    func getRouteToRestaurant(_ restaurant: Restaurant) async throws -> RouteInfo {
        let currentLocation = try await getCurrentLocation()
        let distance = calculateDistance(from: currentLocation, to: restaurant.coordinates)
        
        // В реальном приложении здесь был бы вызов к API маршрутизации
        // Пока что вычисляем примерное время в пути
        let estimatedTime = estimateTravelTime(distance: distance, transportType: .car)
        
        return RouteInfo(
            restaurantId: UUID(uuidString: restaurant.id) ?? UUID(),
            distance: distance,
            estimatedTime: estimatedTime,
            transportType: .car
        )
    }
    
    func getRouteToRestaurant(
        _ restaurant: Restaurant,
        transportType: TransportType
    ) async throws -> RouteInfo {
        let currentLocation = try await getCurrentLocation()
        let distance = calculateDistance(from: currentLocation, to: restaurant.coordinates)
        
        let estimatedTime = estimateTravelTime(distance: distance, transportType: transportType)
        
        return RouteInfo(
            restaurantId: UUID(uuidString: restaurant.id) ?? UUID(),
            distance: distance,
            estimatedTime: estimatedTime,
            transportType: transportType
        )
    }
    
    // MARK: - Location Analytics
    
    func getLocationStatistics() async throws -> LocationStatistics {
        let currentLocation = try await getCurrentLocation()
        
        // Получаем рестораны в радиусе 5 км
        let nearbyRestaurants = try await getNearbyRestaurants(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
            radius: 5000
        )
        
        // Анализируем распределение по кухням
        var cuisineDistribution: [String: Int] = [:]
        var totalRating: Double = 0
        var openRestaurants = 0
        
        for restaurant in nearbyRestaurants {
            cuisineDistribution[restaurant.cuisineType.rawValue, default: 0] += 1
            totalRating += restaurant.rating
            
            if restaurant.isOpen {
                openRestaurants += 1
            }
        }
        
        let averageRating = nearbyRestaurants.isEmpty ? 0 : totalRating / Double(nearbyRestaurants.count)
        
        return LocationStatistics(
            totalRestaurants: nearbyRestaurants.count,
            openRestaurants: openRestaurants,
            averageRating: averageRating,
            cuisineDistribution: cuisineDistribution,
            nearestRestaurant: nearbyRestaurants.first
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func calculateDistance(
        from userLocation: CLLocationCoordinate2D,
        to restaurantLocation: CLLocationCoordinate2D
    ) -> Double {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let restaurantCLLocation = CLLocation(latitude: restaurantLocation.latitude, longitude: restaurantLocation.longitude)
        return userCLLocation.distance(from: restaurantCLLocation)
    }
    
    private func estimateTravelTime(distance: Double, transportType: TransportType) -> TimeInterval {
        let averageSpeed: Double
        
        switch transportType {
        case .car:
            averageSpeed = 30.0 // км/ч в городе
        case .walking:
            averageSpeed = 5.0 // км/ч пешком
        case .publicTransport:
            averageSpeed = 20.0 // км/ч на общественном транспорте
        case .bicycle:
            averageSpeed = 15.0 // км/ч на велосипеде
        }
        
        let distanceInKm = distance / 1000
        let timeInHours = distanceInKm / averageSpeed
        return timeInHours * 3600 // Переводим в секунды
    }
    
    private func calculatePopularityScore(restaurant: Restaurant) -> Double {
        // Простая формула для расчета популярности
        let ratingScore = restaurant.rating * 0.4
        let reviewScore = min(Double(restaurant.reviewCount) / 100.0, 1.0) * 0.3
        let isOpenScore = restaurant.isOpen ? 0.3 : 0.0
        return ratingScore + reviewScore + isOpenScore
    }
    
    private func calculatePreferenceScore(restaurant: Restaurant, user: User) -> Double {
        guard let preferences = user.preferences else { return 0.5 }
        
        var score = 0.5 // Базовый балл
        
        // Проверяем соответствие кухни
        if preferences.cuisineTypes.contains(restaurant.cuisineType.rawValue) {
            score += 0.2
        }
        
        // Проверяем соответствие ценового диапазона
        if preferences.priceRange == restaurant.priceRange {
            score += 0.2
        }
        
        // Проверяем диетические ограничения
        let dietaryScore = preferences.dietaryRestrictions.isEmpty ? 0.1 : 0.0
        score += dietaryScore
        
        return min(score, 1.0)
    }
}

// MARK: - Supporting Types

struct RouteInfo {
    let restaurantId: UUID
    let distance: Double
    let estimatedTime: TimeInterval
    let transportType: TransportType
    
    var formattedDistance: String {
        if distance < 1000 {
            return "\(Int(distance)) м"
        } else {
            return String(format: "%.1f км", distance / 1000)
        }
    }
    
    var formattedTime: String {
        let minutes = Int(estimatedTime / 60)
        if minutes < 60 {
            return "\(minutes) мин"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours) ч \(remainingMinutes) мин"
        }
    }
}

enum TransportType: String, CaseIterable {
    case car = "car"
    case walking = "walking"
    case publicTransport = "publicTransport"
    case bicycle = "bicycle"
    
    var displayName: String {
        switch self {
        case .car: return "Автомобиль"
        case .walking: return "Пешком"
        case .publicTransport: return "Общественный транспорт"
        case .bicycle: return "Велосипед"
        }
    }
    
    var icon: String {
        switch self {
        case .car: return "car"
        case .walking: return "figure.walk"
        case .publicTransport: return "bus"
        case .bicycle: return "bicycle"
        }
    }
}

struct LocationStatistics {
    let totalRestaurants: Int
    let openRestaurants: Int
    let averageRating: Double
    let cuisineDistribution: [String: Int]
    let nearestRestaurant: Restaurant?
    
    var openPercentage: Double {
        guard totalRestaurants > 0 else { return 0 }
        return Double(openRestaurants) / Double(totalRestaurants) * 100
    }
    
    var topCuisine: String? {
        cuisineDistribution.max(by: { $0.value < $1.value })?.key
    }
} 