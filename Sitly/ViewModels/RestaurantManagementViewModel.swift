import Foundation
import CoreLocation
import SwiftUI

@MainActor
class RestaurantManagementViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let restaurantRepository: RestaurantRepositoryProtocol
    
    init(restaurantRepository: RestaurantRepositoryProtocol = RestaurantRepository(
        networkService: NetworkService(),
        storageService: StorageService(),
        cacheService: CacheService(storageService: StorageService())
    )) {
        self.restaurantRepository = restaurantRepository
        generateMockRestaurants()
    }
    
    // MARK: - Public Methods
    func loadRestaurants() {
        isLoading = true
        
        Task {
            // В реальном приложении здесь будет загрузка из API
            // restaurants = try await restaurantRepository.fetchAllRestaurants()
            
            // Для демо используем моковые данные
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isLoading = false
            }
        }
    }
    
    func toggleRestaurantStatus(_ restaurant: Restaurant) {
        if let index = restaurants.firstIndex(where: { $0.id == restaurant.id }) {
            let newStatus: RestaurantStatus = restaurant.status == .active ? .suspended : .active
            
            // Создаем новый ресторан с обновленным статусом
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
                isOpen: restaurant.isOpen,
                isVerified: restaurant.isVerified,
                ownerId: restaurant.ownerId,
                subscriptionPlan: restaurant.subscriptionPlan,
                status: newStatus,
                features: restaurant.features,
                tables: restaurant.tables,
                menu: restaurant.menu,
                analytics: restaurant.analytics,
                settings: restaurant.settings
            )
            
            restaurants[index] = updatedRestaurant
            
            // В реальном приложении здесь будет API вызов
            // Task {
            //     try await restaurantRepository.updateRestaurantStatus(restaurant.id, status: newStatus)
            // }
        }
    }
    
    func deleteRestaurant(_ restaurant: Restaurant) {
        restaurants.removeAll { $0.id == restaurant.id }
        
        // В реальном приложении здесь будет API вызов
        // Task {
        //     try await restaurantRepository.deleteRestaurant(restaurant.id)
        // }
    }
    
    // MARK: - Private Methods
    private func generateMockRestaurants() {
        restaurants = [
            Restaurant(
                id: "1",
                name: "Белуга",
                description: "Изысканная русская кухня в современном исполнении",
                cuisineType: .russian,
                address: "ул. Тверская, 12, Москва",
                coordinates: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176),
                phoneNumber: "+7 (495) 123-45-67",
                website: "https://beluga-restaurant.ru",
                rating: 4.8,
                reviewCount: 342,
                priceRange: .premium,
                ownerId: "owner_1",
                subscriptionPlan: .premium,
                status: .active
            ),
            Restaurant(
                id: "2",
                name: "Сыроварня",
                description: "Авторские сыры и вина в уютной атмосфере",
                cuisineType: .european,
                address: "Камергерский пер., 3, Москва",
                coordinates: CLLocationCoordinate2D(latitude: 55.7598, longitude: 37.6156),
                phoneNumber: "+7 (495) 234-56-78",
                rating: 4.6,
                reviewCount: 189,
                priceRange: .high,
                ownerId: "owner_2",
                subscriptionPlan: .free,
                status: .active
            ),
            Restaurant(
                id: "3",
                name: "Тануки",
                description: "Аутентичная японская кухня и суши",
                cuisineType: .japanese,
                address: "ул. Петровка, 20/1, Москва",
                coordinates: CLLocationCoordinate2D(latitude: 55.7616, longitude: 37.6140),
                phoneNumber: "+7 (495) 345-67-89",
                rating: 4.7,
                reviewCount: 267,
                priceRange: .high,
                ownerId: "owner_3",
                subscriptionPlan: .premium,
                status: .pending
            ),
            Restaurant(
                id: "4",
                name: "Паста & Базилик",
                description: "Настоящая итальянская паста и пицца",
                cuisineType: .italian,
                address: "ул. Арбат, 45, Москва",
                coordinates: CLLocationCoordinate2D(latitude: 55.7515, longitude: 37.5934),
                phoneNumber: "+7 (495) 456-78-90",
                rating: 4.4,
                reviewCount: 156,
                priceRange: .medium,
                ownerId: "owner_4",
                subscriptionPlan: .free,
                status: .suspended
            ),
            Restaurant(
                id: "5",
                name: "Café Pushkin",
                description: "Русская классика в аристократической атмосфере",
                cuisineType: .russian,
                address: "Тверской бул., 26А, Москва",
                coordinates: CLLocationCoordinate2D(latitude: 55.7663, longitude: 37.6098),
                phoneNumber: "+7 (495) 567-89-01",
                rating: 4.9,
                reviewCount: 523,
                priceRange: .premium,
                ownerId: "owner_5",
                subscriptionPlan: .premium,
                status: .active
            ),
            Restaurant(
                id: "6",
                name: "Китайская грамота",
                description: "Региональная китайская кухня и чайная церемония",
                cuisineType: .chinese,
                address: "ул. Большая Дмитровка, 32, Москва",
                coordinates: CLLocationCoordinate2D(latitude: 55.7632, longitude: 37.6088),
                phoneNumber: "+7 (495) 678-90-12",
                rating: 4.3,
                reviewCount: 89,
                priceRange: .medium,
                ownerId: "owner_6",
                subscriptionPlan: .free,
                status: .active
            ),
            Restaurant(
                id: "7",
                name: "Seasons",
                description: "Сезонная европейская кухня от шеф-повара",
                cuisineType: .european,
                address: "Никольская ул., 12, Москва",
                coordinates: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6238),
                phoneNumber: "+7 (495) 789-01-23",
                rating: 4.5,
                reviewCount: 234,
                priceRange: .high,
                ownerId: "owner_7",
                subscriptionPlan: .free,
                status: .pending
            ),
            Restaurant(
                id: "8",
                name: "Mumbai Express",
                description: "Острая индийская кухня и традиционные карри",
                cuisineType: .indian,
                address: "ул. Маросейка, 13, Москва",
                coordinates: CLLocationCoordinate2D(latitude: 55.7546, longitude: 37.6312),
                phoneNumber: "+7 (495) 890-12-34",
                rating: 4.2,
                reviewCount: 112,
                priceRange: .medium,
                ownerId: "owner_8",
                subscriptionPlan: .free,
                status: .active
            )
        ]
    }
}