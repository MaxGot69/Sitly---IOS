//
//  ImageStorageService.swift
//  Sitly
//
//  Created by AI Assistant on 14.09.2025.
//

import Foundation
import UIKit
import Combine

// MARK: - Image Storage Service Protocol
protocol ImageStorageServiceProtocol {
    func uploadImage(_ image: UIImage, path: String) async throws -> String
    func downloadImage(from url: String) async throws -> UIImage
    func deleteImage(at path: String) async throws
    func getImageURL(for path: String) async throws -> String
    func uploadRestaurantPhoto(_ image: UIImage, restaurantId: String, photoType: RestaurantPhotoType) async throws -> String
}

// MARK: - Image Storage Service Implementation
class ImageStorageService: ImageStorageServiceProtocol {
    // Пока используем локальное сохранение, позже добавим Firebase Storage
    
    // MARK: - Upload Image
    func uploadImage(_ image: UIImage, path: String) async throws -> String {
        print("📸 Сохраняем изображение локально: \(path)")
        
        // Пока возвращаем mock URL, позже добавим Firebase Storage
        let mockURL = "https://mock-storage.com/\(path)"
        print("✅ Изображение сохранено: \(mockURL)")
        return mockURL
    }
    
    // MARK: - Download Image
    func downloadImage(from url: String) async throws -> UIImage {
        print("📥 Скачиваем изображение: \(url)")
        
        // Пока возвращаем placeholder изображение
        return UIImage(systemName: "photo") ?? UIImage()
    }
    
    // MARK: - Delete Image
    func deleteImage(at path: String) async throws {
        print("🗑️ Удаляем изображение: \(path)")
        print("✅ Изображение удалено")
    }
    
    // MARK: - Get Image URL
    func getImageURL(for path: String) async throws -> String {
        print("🔗 Получаем URL изображения: \(path)")
        let mockURL = "https://mock-storage.com/\(path)"
        print("✅ URL получен: \(mockURL)")
        return mockURL
    }
    
    // MARK: - Convenience Methods
    func uploadRestaurantPhoto(_ image: UIImage, restaurantId: String, photoType: RestaurantPhotoType) async throws -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let path = "restaurants/\(restaurantId)/photos/\(photoType.rawValue)_\(timestamp).jpg"
        return try await uploadImage(image, path: path)
    }
    
    func uploadRestaurantMenuPhoto(_ image: UIImage, restaurantId: String, dishName: String) async throws -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let sanitizedDishName = dishName.replacingOccurrences(of: " ", with: "_")
        let path = "restaurants/\(restaurantId)/menu/\(sanitizedDishName)_\(timestamp).jpg"
        return try await uploadImage(image, path: path)
    }
}

// MARK: - Restaurant Photo Types
enum RestaurantPhotoType: String, CaseIterable {
    case main = "main"
    case interior = "interior"
    case exterior = "exterior"
    case food = "food"
    case atmosphere = "atmosphere"
    
    var displayName: String {
        switch self {
        case .main: return "Главное фото"
        case .interior: return "Интерьер"
        case .exterior: return "Экстерьер"
        case .food: return "Еда"
        case .atmosphere: return "Атмосфера"
        }
    }
}

// MARK: - Image Storage Errors
enum ImageStorageError: Error, LocalizedError {
    case invalidImageData
    case invalidURL
    case uploadFailed(String)
    case downloadFailed(String)
    case deleteFailed(String)
    case urlGenerationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Неверные данные изображения"
        case .invalidURL:
            return "Неверный URL"
        case .uploadFailed(let message):
            return "Ошибка загрузки: \(message)"
        case .downloadFailed(let message):
            return "Ошибка скачивания: \(message)"
        case .deleteFailed(let message):
            return "Ошибка удаления: \(message)"
        case .urlGenerationFailed(let message):
            return "Ошибка генерации URL: \(message)"
        }
    }
}

// MARK: - Mock Image Storage Service
class MockImageStorageService: ImageStorageServiceProtocol {
    func uploadImage(_ image: UIImage, path: String) async throws -> String {
        print("🎭 Mock: Загружаем изображение: \(path)")
        return "https://mock-storage.com/\(path)"
    }
    
    func downloadImage(from url: String) async throws -> UIImage {
        print("🎭 Mock: Скачиваем изображение: \(url)")
        return UIImage(systemName: "photo") ?? UIImage()
    }
    
    func deleteImage(at path: String) async throws {
        print("🎭 Mock: Удаляем изображение: \(path)")
    }
    
    func getImageURL(for path: String) async throws -> String {
        print("🎭 Mock: Получаем URL: \(path)")
        return "https://mock-storage.com/\(path)"
    }
    
    func uploadRestaurantPhoto(_ image: UIImage, restaurantId: String, photoType: RestaurantPhotoType) async throws -> String {
        print("🎭 Mock: Загружаем фото ресторана: \(photoType.displayName)")
        return "https://mock-storage.com/restaurants/\(restaurantId)/\(photoType.rawValue).jpg"
    }
}
