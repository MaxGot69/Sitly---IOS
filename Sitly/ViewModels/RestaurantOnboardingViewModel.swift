//
//  RestaurantOnboardingViewModel.swift
//  Sitly
//
//  Created by AI Assistant on 12.09.2025.
//

import Foundation
import SwiftUI
import CoreLocation

@MainActor
class RestaurantOnboardingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var restaurantName = ""
    @Published var description = ""
    @Published var selectedCuisine: CuisineType = .european
    @Published var selectedPriceRange: PriceRange = .medium
    @Published var phoneNumber = ""
    
    @Published var address = ""
    @Published var city = "Москва"
    @Published var coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176)
    
    @Published var workingHours: [String: DayHours] = [:]
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Services
    private let restaurantService: RestaurantServiceProtocol
    
    // MARK: - Computed Properties
    var fullAddress: String {
        return "\(address), \(city)"
    }
    
    // MARK: - Initialization
    init(restaurantService: RestaurantServiceProtocol? = nil) {
        self.restaurantService = restaurantService ?? RestaurantService()
        setupDefaultWorkingHours()
    }
    
    // MARK: - Setup Methods
    private func setupDefaultWorkingHours() {
        let defaultHours = DayHours(isOpen: true, openTime: "09:00", closeTime: "22:00")
        let closedSunday = DayHours(isOpen: false, openTime: "09:00", closeTime: "22:00")
        
        workingHours = [
            "monday": defaultHours,
            "tuesday": defaultHours,
            "wednesday": defaultHours,
            "thursday": defaultHours,
            "friday": defaultHours,
            "saturday": defaultHours,
            "sunday": closedSunday
        ]
    }
    
    // MARK: - Working Hours Management
    func updateWorkingHours(day: String, isOpen: Bool) {
        workingHours[day] = DayHours(
            isOpen: isOpen,
            openTime: workingHours[day]?.openTime ?? "09:00",
            closeTime: workingHours[day]?.closeTime ?? "22:00"
        )
    }
    
    func updateWorkingTime(day: String, openTime: String, closeTime: String) {
        workingHours[day] = DayHours(
            isOpen: workingHours[day]?.isOpen ?? true,
            openTime: openTime,
            closeTime: closeTime
        )
    }
    
    // MARK: - Restaurant Creation
    func createRestaurant(userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🏢 Создаем ресторан для пользователя: \(userId)")
            
            // Создаем модель ресторана
            let restaurant = RestaurantModel(
                id: UUID().uuidString,
                name: restaurantName,
                description: description,
                cuisineType: selectedCuisine,
                address: fullAddress,
                coordinates: coordinates,
                phoneNumber: phoneNumber,
                priceRange: selectedPriceRange,
                workingHours: createWorkingHoursModel(),
                ownerId: userId,
                status: .pending // Ресторан на модерации
            )
            
            // Сохраняем в Firebase
            let createdRestaurant = try await restaurantService.createRestaurant(restaurant)
            print("✅ Ресторан создан: \(createdRestaurant.id)")
            
            // Обновляем пользователя - связываем с рестораном
            try await updateUserRestaurantId(userId: userId, restaurantId: createdRestaurant.id)
            
            // Создаем начальные столики
            try await createDefaultTables(restaurantId: createdRestaurant.id)
            
            HapticService.shared.notification(.success)
            print("✅ Регистрация ресторана завершена!")
            
        } catch {
            print("❌ Ошибка создания ресторана: \(error)")
            errorMessage = "Ошибка создания ресторана: \(error.localizedDescription)"
            HapticService.shared.notification(.error)
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    private func createWorkingHoursModel() -> WorkingHours {
        return WorkingHours(
            monday: workingHours["monday"] ?? DayHours(),
            tuesday: workingHours["tuesday"] ?? DayHours(),
            wednesday: workingHours["wednesday"] ?? DayHours(),
            thursday: workingHours["thursday"] ?? DayHours(),
            friday: workingHours["friday"] ?? DayHours(),
            saturday: workingHours["saturday"] ?? DayHours(),
            sunday: workingHours["sunday"] ?? DayHours()
        )
    }
    
    private func updateUserRestaurantId(userId: String, restaurantId: String) async throws {
        // TODO: Обновляем поле restaurantId у пользователя
        print("🔗 Обновляем пользователя \(userId) - связываем с рестораном \(restaurantId)")
    }
    
    private func createDefaultTables(restaurantId: String) async throws {
        print("🪑 Создаем базовые столики для ресторана: \(restaurantId)")
        
        let defaultTables = [
            TableModel(name: "Стол 1", capacity: 2, type: .indoor, status: .available, isVIP: false),
            TableModel(name: "Стол 2", capacity: 4, type: .indoor, status: .available, isVIP: false),
            TableModel(name: "VIP-1", capacity: 6, type: .vip, status: .available, isVIP: true),
            TableModel(name: "Терраса 1", capacity: 4, type: .outdoor, status: .available, isVIP: false)
        ]
        
        // TODO: Создаем столики через TablesService
        for table in defaultTables {
            print("➕ Создаем столик: \(table.name)")
        }
    }
}

// MARK: - Simplified Restaurant Model for Creation
struct RestaurantModel: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let cuisineType: CuisineType
    let address: String
    let coordinates: CLLocationCoordinate2D
    let phoneNumber: String
    let priceRange: PriceRange
    let workingHours: WorkingHours
    let ownerId: String
    let status: RestaurantStatus
    let createdAt: Date
    let updatedAt: Date
    
    // Дополнительные поля с дефолтными значениями
    let rating: Double
    let reviewCount: Int
    let photos: [String]
    let isOpen: Bool
    let isVerified: Bool
    let website: String?
    let features: [RestaurantFeature]
    
    init(id: String, name: String, description: String, cuisineType: CuisineType, address: String, coordinates: CLLocationCoordinate2D, phoneNumber: String, priceRange: PriceRange, workingHours: WorkingHours, ownerId: String, status: RestaurantStatus) {
        self.id = id
        self.name = name
        self.description = description
        self.cuisineType = cuisineType
        self.address = address
        self.coordinates = coordinates
        self.phoneNumber = phoneNumber
        self.priceRange = priceRange
        self.workingHours = workingHours
        self.ownerId = ownerId
        self.status = status
        self.createdAt = Date()
        self.updatedAt = Date()
        
        // Дефолтные значения
        self.rating = 0.0
        self.reviewCount = 0
        self.photos = []
        self.isOpen = true
        self.isVerified = false
        self.website = nil
        self.features = []
    }
}

// MARK: - Restaurant Service Protocol
protocol RestaurantServiceProtocol {
    func createRestaurant(_ restaurant: RestaurantModel) async throws -> RestaurantModel
    func getRestaurant(id: String) async throws -> RestaurantModel
    func updateRestaurant(_ restaurant: RestaurantModel) async throws
    func deleteRestaurant(id: String) async throws
}

// MARK: - Restaurant Service Implementation
class RestaurantService: RestaurantServiceProtocol {
    private let db = Firestore.firestore()
    
    func createRestaurant(_ restaurant: RestaurantModel) async throws -> RestaurantModel {
        print("🔥 Сохраняем ресторан в Firebase: \(restaurant.name)")
        
        do {
            // Кодируем данные ресторана
            let jsonData = try JSONEncoder().encode(restaurant)
            var restaurantData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
            
            // Убираем id, чтобы использовать кастомный
            restaurantData.removeValue(forKey: "id")
            
            // Добавляем timestamps
            restaurantData["createdAt"] = FieldValue.serverTimestamp()
            restaurantData["updatedAt"] = FieldValue.serverTimestamp()
            
            // Сохраняем в Firestore
            try await db.collection("restaurants").document(restaurant.id).setData(restaurantData)
            
            print("✅ Ресторан сохранен в Firebase с ID: \(restaurant.id)")
            return restaurant
            
        } catch {
            print("❌ Ошибка сохранения ресторана: \(error)")
            throw error
        }
    }
    
    func getRestaurant(id: String) async throws -> RestaurantModel {
        let document = try await db.collection("restaurants").document(id).getDocument()
        
        guard let data = document.data() else {
            throw NSError(domain: "RestaurantService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Ресторан не найден"])
        }
        
        var restaurantData = data
        restaurantData["id"] = id
        
        let jsonData = try JSONSerialization.data(withJSONObject: restaurantData)
        return try JSONDecoder().decode(RestaurantModel.self, from: jsonData)
    }
    
    func updateRestaurant(_ restaurant: RestaurantModel) async throws {
        let jsonData = try JSONEncoder().encode(restaurant)
        var restaurantData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
        
        restaurantData.removeValue(forKey: "id")
        restaurantData["updatedAt"] = FieldValue.serverTimestamp()
        
        try await db.collection("restaurants").document(restaurant.id).updateData(restaurantData)
    }
    
    func deleteRestaurant(id: String) async throws {
        try await db.collection("restaurants").document(id).delete()
    }
}

import FirebaseFirestore
