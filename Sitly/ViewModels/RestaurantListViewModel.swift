//
//  RestaurantListViewModel.swift
//  Sitly
//
//  Created by Maxim Gotovchenko on 30.06.2025.
//

import Foundation
import CoreLocation
import SwiftUI
import MapKit

@MainActor
final class RestaurantListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var restaurants: [Restaurant] = []
    @Published var filteredRestaurants: [Restaurant] = []
    @Published var aiRecommendations: [Restaurant] = []
    @Published var isLoading = false
    @Published var isLoadingAI = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedCuisine = "Все"
    @Published var showMap = false
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176), // Москва
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    // MARK: - Private Properties
    private let restaurantUseCase: RestaurantUseCaseProtocol
    private let locationUseCase: LocationUseCaseProtocol
    private let aiService: AIServiceProtocol
    
    // MARK: - Computed Properties
    var cuisines: [String] {
        let allCuisines = Set(restaurants.map { $0.cuisineType.displayName })
        return ["Все"] + Array(allCuisines).sorted()
    }
    
    // MARK: - Initialization
    init(restaurantUseCase: RestaurantUseCaseProtocol, locationUseCase: LocationUseCaseProtocol, aiService: AIServiceProtocol = AIService()) {
        self.restaurantUseCase = restaurantUseCase
        self.locationUseCase = locationUseCase
        self.aiService = aiService
    }
    
    // MARK: - Public Methods
    
    func loadRestaurants() async {
        isLoading = true
        errorMessage = nil
        
        do {
            restaurants = try await restaurantUseCase.getRestaurants()
            applyFilters()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func searchRestaurants() async {
        guard !searchText.isEmpty else {
            await loadRestaurants()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            restaurants = try await restaurantUseCase.searchRestaurants(query: searchText)
            applyFilters()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadNearbyRestaurants() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let location = try await locationUseCase.getCurrentLocation()
            restaurants = try await locationUseCase.getNearbyRestaurants(
                latitude: location.latitude,
                longitude: location.longitude,
                radius: 5000
            )
            applyFilters()
        } catch {
            errorMessage = error.localizedDescription
            // В случае ошибки геолокации, загружаем все рестораны
            await loadRestaurants()
        }
        
        isLoading = false
    }
    
    func filterByCuisine(_ cuisine: String) {
        selectedCuisine = cuisine
        applyFilters()
    }
    
    func clearFilters() {
        searchText = ""
        selectedCuisine = "Все"
        applyFilters()
    }
    
    func toggleMapView() {
        showMap.toggle()
    }
    
    // MARK: - Private Methods
    
    private func applyFilters() {
        var filtered = restaurants
        
        // Фильтр по кухне
        if selectedCuisine != "Все" {
            filtered = filtered.filter { $0.cuisineType.displayName == selectedCuisine }
        }
        
        filteredRestaurants = filtered
    }
    
    func refreshData() async {
        await loadRestaurants()
        await loadAIRecommendations()
    }
    
    func loadAIRecommendations() async {
        isLoadingAI = true
        
        do {
            // Создаем демо пользователя для AI рекомендаций
            let demoUser = User(
                id: "demo-user",
                email: "demo@sitly.app",
                name: "Demo User"
            )
            
            let preferences = UserPreferences(
                cuisineTypes: ["Русская", "Европейская", "Итальянская"],
                priceRange: .medium,
                maxDistance: 5.0,
                preferredTimes: ["19:00", "20:00"],
                dietaryRestrictions: [],
                notificationSettings: NotificationSettings()
            )
            
            // Получаем AI рекомендации (пока используем MockAIService)
            let recommendedRestaurants = try await aiService.getPersonalizedRecommendations(for: demoUser, preferences: preferences)
            
            // AI возвращает строку с рекомендациями, пока используем топ рестораны
            print("🤖 AI рекомендации: \(recommendedRestaurants)")
            aiRecommendations = Array(restaurants.sorted { $0.rating > $1.rating }.prefix(3))
        } catch {
            print("❌ Ошибка загрузки AI рекомендаций: \(error)")
            // Fallback: показываем топ рестораны по рейтингу
            aiRecommendations = Array(restaurants.sorted { $0.rating > $1.rating }.prefix(3))
        }
        
        isLoadingAI = false
    }
    
    func smartSearch(query: String) async {
        guard !query.isEmpty else {
            await loadRestaurants()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Пока используем обычный поиск, но с AI-интерфейсом
            // В будущем здесь будет реальный AI поиск
            restaurants = try await restaurantUseCase.searchRestaurants(query: query)
            applyFilters()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - Restaurant Detail ViewModel

@MainActor
final class RestaurantDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var restaurant: Restaurant
    @Published var reviews: [Review] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isBooking = false
    @Published var showBookingView = false
    
    // MARK: - Private Properties
    private let reviewUseCase: ReviewUseCaseProtocol
    private let bookingUseCase: BookingUseCaseProtocol
    
    // MARK: - Initialization
    init(restaurant: Restaurant, reviewUseCase: ReviewUseCaseProtocol, bookingUseCase: BookingUseCaseProtocol) {
        self.restaurant = restaurant
        self.reviewUseCase = reviewUseCase
        self.bookingUseCase = bookingUseCase
    }
    
    // MARK: - Public Methods
    
    func loadReviews() async {
        isLoading = true
        errorMessage = nil
        
        do {
            reviews = try await reviewUseCase.getRestaurantReviews(restaurantId: restaurant.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createBooking(date: Date, time: String, guestCount: Int, tableType: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            // Проверяем доступность
            let isAvailable = try await bookingUseCase.checkAvailability(
                restaurantId: restaurant.id,
                date: date,
                time: time
            )
            
            guard isAvailable else {
                errorMessage = "Выбранное время недоступно. Попробуйте другое время."
                isLoading = false
                return false
            }
            
            // Преобразуем строку в TableType
            let tableTypeEnum: TableType
            switch tableType.lowercased() {
            case "у окна", "window":
                tableTypeEnum = .indoor  // Столик у окна - это в зале
            case "терраса", "terrace":
                tableTypeEnum = .outdoor // Терраса - это на улице
            case "бар", "bar":
                tableTypeEnum = .bar
            case "приватный", "private":
                tableTypeEnum = .vip  // Приватный столик - это VIP
            default:
                tableTypeEnum = .standard
            }
            
            // Создаём бронирование
            _ = try await bookingUseCase.createBooking(
                restaurantId: restaurant.id,
                userId: "current-user-id", // В реальном приложении здесь был бы ID текущего пользователя
                date: date,
                time: time,
                guestCount: guestCount,
                tableType: tableTypeEnum,
                specialRequests: nil,
                contactPhone: "+7 (999) 123-45-67" // В реальном приложении здесь был бы телефон пользователя
            )
            
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func getAverageRating() -> Double {
        guard !reviews.isEmpty else { return 0.0 }
        let totalRating = reviews.reduce(0.0) { $0 + $1.rating }
        return totalRating / Double(reviews.count)
    }
    
    func getReviewCount() -> Int {
        return reviews.count
    }
}

// MARK: - Booking ViewModel




