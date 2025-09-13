import Foundation
import CoreLocation

final class RestaurantUseCase: RestaurantUseCaseProtocol {
    private let repository: RestaurantRepositoryProtocol
    private let locationService: LocationServiceProtocol
    
    init(repository: RestaurantRepositoryProtocol, locationService: LocationServiceProtocol) {
        self.repository = repository
        self.locationService = locationService
    }
    
    // MARK: - Restaurant Methods
    
    func getRestaurants() async throws -> [Restaurant] {
        do {
            var restaurants = try await repository.fetchRestaurants()
            
            // Добавляем расстояние от пользователя
            if let userLocation = try? await locationService.getCurrentLocation() {
                restaurants = restaurants.map { restaurant in
                    let updatedRestaurant = restaurant
                    _ = calculateDistance(
                        from: userLocation,
                        to: restaurant.coordinates
                    )
                    // Здесь нужно обновить distanceFromUser, но это требует изменения модели
                    return updatedRestaurant
                }
                
                // Сортируем по рейтингу и расстоянию
                restaurants.sort { first, second in
                    if first.rating == second.rating {
                        // Если рейтинг одинаковый, сортируем по расстоянию
                        return true // Временно, пока не добавим distanceFromUser
                    }
                    return first.rating > second.rating
                }
            }
            
            return restaurants
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    func getRestaurant(id: String) async throws -> Restaurant {
        do {
            return try await repository.fetchRestaurant(by: id)
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    func searchRestaurants(query: String) async throws -> [Restaurant] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw UseCaseError.businessLogicError("Поисковый запрос не может быть пустым")
        }
        
        guard query.count >= 2 else {
            throw UseCaseError.businessLogicError("Поисковый запрос должен содержать минимум 2 символа")
        }
        
        do {
            let restaurants = try await repository.searchRestaurants(query: query)
            
            // Сортируем результаты поиска по релевантности
            return restaurants.sorted { first, second in
                let firstScore = calculateSearchScore(restaurant: first, query: query)
                let secondScore = calculateSearchScore(restaurant: second, query: query)
                return firstScore > secondScore
            }
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    func getRestaurantsByCuisine(_ cuisine: String) async throws -> [Restaurant] {
        guard !cuisine.isEmpty else {
            throw UseCaseError.businessLogicError("Тип кухни не может быть пустым")
        }
        
        do {
            let restaurants = try await repository.fetchRestaurantsByCuisine(cuisine)
            return restaurants.sorted { $0.rating > $1.rating }
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    func getNearbyRestaurants(latitude: Double, longitude: Double) async throws -> [Restaurant] {
        guard latitude >= -90 && latitude <= 90 else {
            throw UseCaseError.businessLogicError("Некорректная широта")
        }
        
        guard longitude >= -180 && longitude <= 180 else {
            throw UseCaseError.businessLogicError("Некорректная долгота")
        }
        
        do {
            let restaurants = try await repository.fetchNearbyRestaurants(
                latitude: latitude,
                longitude: longitude,
                radius: 5000 // 5 км
            )
            
            // Сортируем по расстоянию и рейтингу
            return restaurants.sorted { first, second in
                let firstDistance = calculateDistance(
                    from: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    to: first.coordinates
                )
                let secondDistance = calculateDistance(
                    from: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    to: second.coordinates
                )
                
                if abs(firstDistance - secondDistance) < 100 { // Если разница менее 100м
                    return first.rating > second.rating
                }
                return firstDistance < secondDistance
            }
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    func getCurrentLocationRestaurants() async throws -> [Restaurant] {
        do {
            let location = try await locationService.getCurrentLocation()
            return try await getNearbyRestaurants(
                latitude: location.latitude,
                longitude: location.longitude
            )
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func calculateDistance(from userLocation: CLLocationCoordinate2D, to restaurantLocation: CLLocationCoordinate2D) -> Double {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let restaurantCLLocation = CLLocation(latitude: restaurantLocation.latitude, longitude: restaurantLocation.longitude)
        return userCLLocation.distance(from: restaurantCLLocation)
    }
    
    private func calculateSearchScore(restaurant: Restaurant, query: String) -> Double {
        let query = query.lowercased()
        var score: Double = 0
        
        // Поиск по названию (высший приоритет)
        if restaurant.name.lowercased().contains(query) {
            score += 100
        }
        
        // Поиск по кухне
        if restaurant.cuisineType.displayName.lowercased().contains(query) {
            score += 50
        }
        
        // Поиск по адресу
        if restaurant.address.lowercased().contains(query) {
            score += 30
        }
        
        // Поиск по описанию
        if restaurant.description.lowercased().contains(query) {
            score += 20
        }
        
        // Бонус за высокий рейтинг
        score += restaurant.rating * 10
        
        // Бонус за доступные столы
        if !restaurant.tables.isEmpty {
            score += 25
        }
        
        return score
    }
} 