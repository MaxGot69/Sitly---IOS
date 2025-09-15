//
//  StorageService.swift
//  Sitly
//
//  Created by AI Assistant on 12.09.2025.
//

import Foundation
import Combine

// MARK: - Storage Service Protocol

protocol StorageServiceProtocol {
    func save<T: Codable>(_ object: T, forKey key: String) async throws
    func save<T: Codable>(_ object: T, forKey key: String, expiration: TimeInterval) async throws
    func load<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T?
    func delete(forKey key: String) async throws
    func clear() async throws
}

// MARK: - Storage Service Implementation

final class StorageService: StorageServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    
    init() {
        self.documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    // MARK: - Save Methods
    
    func save<T: Codable>(_ object: T, forKey key: String) async throws {
        do {
            let data = try JSONEncoder().encode(object)
            userDefaults.set(data, forKey: key)
            print("💾 StorageService: Сохранено \(type(of: object)) для ключа '\(key)'")
        } catch {
            print("❌ StorageService: Ошибка сохранения - \(error)")
            throw StorageError.saveFailed(error)
        }
    }
    
    func save<T: Codable>(_ object: T, forKey key: String, expiration: TimeInterval) async throws {
        let expirationDate = Date().addingTimeInterval(expiration)
        let wrapper = ExpirableWrapper(object: object, expirationDate: expirationDate)
        try await save(wrapper, forKey: key)
    }
    
    // MARK: - Load Methods
    
    func load<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            print("📭 StorageService: Данные не найдены для ключа '\(key)'")
            return nil
        }
        
        do {
            let object = try JSONDecoder().decode(type, from: data)
            print("📖 StorageService: Загружено \(type) для ключа '\(key)'")
            return object
        } catch {
            print("❌ StorageService: Ошибка загрузки - \(error)")
            throw StorageError.loadFailed(error)
        }
    }
    
    // MARK: - Delete Methods
    
    func delete(forKey key: String) async throws {
        userDefaults.removeObject(forKey: key)
        print("🗑️ StorageService: Удалено для ключа '\(key)'")
    }
    
    func clear() async throws {
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
        userDefaults.synchronize()
        print("🧹 StorageService: Очищены все данные")
    }
    
    // MARK: - Convenience Methods
    
    func saveUser(_ user: User) async throws {
        try await save(user, forKey: Keys.user)
    }
    
    func loadUser() async throws -> User? {
        return try await load(User.self, forKey: Keys.user)
    }
    
    func saveRestaurant(_ restaurant: Restaurant) async throws {
        try await save(restaurant, forKey: Keys.restaurant)
    }
    
    func loadRestaurant() async throws -> Restaurant? {
        return try await load(Restaurant.self, forKey: Keys.restaurant)
    }
    
    func saveBookings(_ bookings: [Booking]) async throws {
        try await save(bookings, forKey: Keys.bookings)
    }
    
    func loadBookings() async throws -> [Booking]? {
        return try await load([Booking].self, forKey: Keys.bookings)
    }
}

// MARK: - Storage Keys

private enum Keys {
    static let user = "user"
    static let restaurant = "restaurant"
    static let bookings = "bookings"
    static let settings = "settings"
    static let cache = "cache"
}

// MARK: - Storage Errors

enum StorageError: Error, LocalizedError {
    case saveFailed(Error)
    case loadFailed(Error)
    case notFound
    case expired
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Ошибка сохранения: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "Ошибка загрузки: \(error.localizedDescription)"
        case .notFound:
            return "Данные не найдены"
        case .expired:
            return "Данные истекли"
        }
    }
}

// MARK: - Expirable Wrapper

private struct ExpirableWrapper<T: Codable>: Codable {
    let object: T
    let expirationDate: Date
    
    var isExpired: Bool {
        return Date() > expirationDate
    }
}