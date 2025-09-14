import Foundation
import CoreLocation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class RestaurantRepository: RestaurantRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let storageService: StorageServiceProtocol
    private let cacheService: CacheServiceProtocol
    
    init(networkService: NetworkServiceProtocol, storageService: StorageServiceProtocol, cacheService: CacheServiceProtocol) {
        self.networkService = networkService
        self.storageService = storageService
        self.cacheService = cacheService
    }
    
    func fetchRestaurants() async throws -> [Restaurant] {
        print("🔥 RestaurantRepository: НАЧАЛО ЗАГРУЗКИ РЕСТОРАНОВ")
        
        do {
            print("🔥 RestaurantRepository: Загружаем рестораны из Firebase...")
            let restaurants: [Restaurant] = try await networkService.request(FirebaseEndpoint.getRestaurants)
            print("✅ RestaurantRepository: Загружено \(restaurants.count) ресторанов из Firebase")
            await cacheService.save(restaurants, forKey: "restaurants", expiration: 300)
            return restaurants
        } catch {
            print("❌ RestaurantRepository: Ошибка загрузки из Firebase: \(error)")
            // Fallback to cached data
            if let cached: [Restaurant] = await cacheService.load(forKey: "restaurants") {
                print("📱 RestaurantRepository: Используем кэшированные данные (\(cached.count) ресторанов)")
                return cached
            }
            // Возвращаем пустой массив вместо моковых данных
            print("📱 RestaurantRepository: Возвращаем пустой массив ресторанов")
            return []
        }
    }
    
    func fetchRestaurant(by id: String) async throws -> Restaurant {
        do {
            let restaurants: [Restaurant] = try await networkService.request(FirebaseEndpoint.getRestaurants)
            guard let restaurant = restaurants.first(where: { $0.id == id }) else {
                throw RepositoryError.notFound
            }
            return restaurant
        } catch {
            // Fallback to cached data
            if let cached: [Restaurant] = await cacheService.load(forKey: "restaurants") {
                guard let restaurant = cached.first(where: { $0.id == id }) else {
                    throw RepositoryError.notFound
                }
                return restaurant
            }
            // Fallback to mock data for MVP
            guard let restaurant = getMockRestaurants().first(where: { $0.id == id }) else {
                throw RepositoryError.notFound
            }
            return restaurant
        }
    }
    
    func searchRestaurants(query: String) async throws -> [Restaurant] {
        do {
            let restaurants: [Restaurant] = try await networkService.request(FirebaseEndpoint.getRestaurants)
            return restaurants.filter { restaurant in
                restaurant.name.lowercased().contains(query.lowercased()) ||
                restaurant.description.lowercased().contains(query.lowercased()) ||
                restaurant.cuisineType.rawValue.lowercased().contains(query.lowercased())
            }
        } catch {
            // Fallback to cached data
            if let cached: [Restaurant] = await cacheService.load(forKey: "restaurants") {
                return cached.filter { restaurant in
                    restaurant.name.lowercased().contains(query.lowercased()) ||
                    restaurant.description.lowercased().contains(query.lowercased()) ||
                    restaurant.cuisineType.rawValue.lowercased().contains(query.lowercased())
                }
            }
            // Fallback to mock data for MVP
            return getMockRestaurants().filter { restaurant in
                restaurant.name.lowercased().contains(query.lowercased()) ||
                restaurant.description.lowercased().contains(query.lowercased()) ||
                restaurant.cuisineType.rawValue.lowercased().contains(query.lowercased())
            }
        }
    }
    
    func fetchRestaurantsByCuisine(_ cuisine: String) async throws -> [Restaurant] {
        do {
            let restaurants: [Restaurant] = try await networkService.request(FirebaseEndpoint.getRestaurants)
            return restaurants.filter { restaurant in
                restaurant.cuisineType.rawValue.lowercased() == cuisine.lowercased()
            }
        } catch {
            // Fallback to cached data
            if let cached: [Restaurant] = await cacheService.load(forKey: "restaurants") {
                return cached.filter { restaurant in
                    restaurant.cuisineType.rawValue.lowercased() == cuisine.lowercased()
                }
            }
            // Fallback to mock data for MVP
            return getMockRestaurants().filter { restaurant in
                restaurant.cuisineType.rawValue.lowercased() == cuisine.lowercased()
            }
        }
    }
    
    func fetchNearbyRestaurants(latitude: Double, longitude: Double, radius: Double) async throws -> [Restaurant] {
        do {
            let restaurants: [Restaurant] = try await networkService.request(FirebaseEndpoint.getRestaurants)
            return restaurants.filter { restaurant in
                let distance = calculateDistance(
                    from: CLLocation(latitude: latitude, longitude: longitude),
                    to: CLLocation(
                        latitude: restaurant.coordinates.latitude,
                        longitude: restaurant.coordinates.longitude
                    )
                )
                return distance <= radius
            }
        } catch {
            // Fallback to cached data
            if let cached: [Restaurant] = await cacheService.load(forKey: "restaurants") {
                return cached.filter { restaurant in
                    let distance = calculateDistance(
                        from: CLLocation(latitude: latitude, longitude: longitude),
                        to: CLLocation(
                            latitude: restaurant.coordinates.latitude,
                            longitude: restaurant.coordinates.longitude
                        )
                    )
                    return distance <= radius
                }
            }
            // Fallback to mock data for MVP
            return getMockRestaurants().filter { restaurant in
                let distance = calculateDistance(
                    from: CLLocation(latitude: latitude, longitude: longitude),
                    to: CLLocation(
                        latitude: restaurant.coordinates.latitude,
                        longitude: restaurant.coordinates.longitude
                    )
                )
                return distance <= radius
            }
        }
    }
    
    private func calculateDistance(from: CLLocation, to: CLLocation) -> Double {
        return from.distance(from: to) / 1000 // Convert to kilometers
    }
    
    // MARK: - Mock Data for MVP
    
    private func getMockRestaurants() -> [Restaurant] {
        return [
            Restaurant(
                id: "1",
                name: "Le Petit Bistrot",
                description: "Уютный французский ресторан с традиционной кухней",
                cuisineType: CuisineType.european,
                address: "ул. Тверская, 15",
                coordinates: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176),
                phoneNumber: "+7 (495) 123-45-67",
                website: "https://lepetitbistrot.ru",
                rating: 4.8,
                reviewCount: 156,
                priceRange: PriceRange.high,
                workingHours: WorkingHours(),
                photos: ["restaurant1_1", "restaurant1_2"],
                isOpen: true,
                isVerified: true,
                ownerId: "owner1",
                subscriptionPlan: SubscriptionPlan.premium,
                status: RestaurantStatus.active,
                features: [RestaurantFeature.wifi, RestaurantFeature.parking, RestaurantFeature.outdoorSeating, RestaurantFeature.`private`],
                tables: [],
                menu: Menu(),
                analytics: RestaurantAnalytics(),
                settings: RestaurantSettings()
            ),
            Restaurant(
                id: "2",
                name: "Sakura Sushi",
                description: "Аутентичная японская кухня с доставкой",
                cuisineType: CuisineType.japanese,
                address: "Ленинский проспект, 42",
                coordinates: CLLocationCoordinate2D(latitude: 55.7000, longitude: 37.5000),
                phoneNumber: "+7 (495) 987-65-43",
                website: "https://sakurasushi.ru",
                rating: 4.6,
                reviewCount: 89,
                priceRange: PriceRange.medium,
                workingHours: WorkingHours(),
                photos: ["restaurant2_1", "restaurant2_2"],
                isOpen: true,
                isVerified: true,
                ownerId: "owner2",
                subscriptionPlan: SubscriptionPlan.free,
                status: RestaurantStatus.active,
                features: [RestaurantFeature.wifi, RestaurantFeature.delivery, RestaurantFeature.takeaway],
                tables: [],
                menu: Menu(),
                analytics: RestaurantAnalytics(),
                settings: RestaurantSettings()
            ),
            Restaurant(
                id: "3",
                name: "Trattoria Bella",
                description: "Семейная итальянская траттория",
                cuisineType: CuisineType.italian,
                address: "Кутузовский проспект, 8",
                coordinates: CLLocationCoordinate2D(latitude: 55.7500, longitude: 37.5500),
                phoneNumber: "+7 (495) 555-12-34",
                website: "https://trattoriabella.ru",
                rating: 4.7,
                reviewCount: 203,
                priceRange: PriceRange.high,
                workingHours: WorkingHours(),
                photos: ["restaurant3_1", "restaurant3_2"],
                isOpen: true,
                isVerified: true,
                ownerId: "owner3",
                subscriptionPlan: SubscriptionPlan.premium,
                status: RestaurantStatus.active,
                features: [RestaurantFeature.wifi, RestaurantFeature.parking, RestaurantFeature.liveMusic, RestaurantFeature.petFriendly],
                tables: [],
                menu: Menu(),
                analytics: RestaurantAnalytics(),
                settings: RestaurantSettings()
            ),
            Restaurant(
                id: "4",
                name: "Golden Palace",
                description: "Премиум китайский ресторан",
                cuisineType: CuisineType.chinese,
                address: "Новый Арбат, 25",
                coordinates: CLLocationCoordinate2D(latitude: 55.7600, longitude: 37.5800),
                phoneNumber: "+7 (495) 777-88-99",
                website: "https://goldenpalace.ru",
                rating: 4.9,
                reviewCount: 312,
                priceRange: PriceRange.premium,
                workingHours: WorkingHours(),
                photos: ["restaurant4_1", "restaurant4_2"],
                isOpen: true,
                isVerified: true,
                ownerId: "owner4",
                subscriptionPlan: SubscriptionPlan.enterprise,
                status: RestaurantStatus.active,
                features: [RestaurantFeature.wifi, RestaurantFeature.parking, RestaurantFeature.outdoorSeating, RestaurantFeature.`private`, RestaurantFeature.wheelchairAccessible],
                tables: [],
                menu: Menu(),
                analytics: RestaurantAnalytics(),
                settings: RestaurantSettings()
            ),
            Restaurant(
                id: "5",
                name: "Family Cafe",
                description: "Уютное кафе для всей семьи",
                cuisineType: CuisineType.european,
                address: "Проспект Мира, 100",
                coordinates: CLLocationCoordinate2D(latitude: 55.7800, longitude: 37.6300),
                phoneNumber: "+7 (495) 111-22-33",
                website: "https://familycafe.ru",
                rating: 4.4,
                reviewCount: 67,
                priceRange: PriceRange.high,
                workingHours: WorkingHours(),
                photos: ["restaurant5_1", "restaurant5_2"],
                isOpen: true,
                isVerified: true,
                ownerId: "owner5",
                subscriptionPlan: SubscriptionPlan.free,
                status: RestaurantStatus.active,
                features: [RestaurantFeature.wifi, RestaurantFeature.parking, RestaurantFeature.outdoorSeating, RestaurantFeature.kidsMenu],
                tables: [],
                menu: Menu(),
                analytics: RestaurantAnalytics(),
                settings: RestaurantSettings()
            )
        ]
    }
} 