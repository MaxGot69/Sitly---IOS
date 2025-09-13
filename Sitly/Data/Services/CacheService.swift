import Foundation

// MARK: - Cache Service Protocol

protocol CacheServiceProtocol {
    func save<T: Codable & Sendable>(_ object: T, forKey key: String, expiration: TimeInterval?) async
    func load<T: Codable & Sendable>(forKey key: String) async -> T?
    func remove(forKey key: String) async
    func clear() async
    func isExpired(forKey key: String) async -> Bool
}

// MARK: - Cache Entry

private struct CacheEntry<T: Codable & Sendable>: Codable, Sendable {
    let data: T
    let timestamp: Date
    let expiration: TimeInterval?
    
    var isExpired: Bool {
        guard let expiration = expiration else { return false }
        return Date().timeIntervalSince(timestamp) > expiration
    }
}

// MARK: - Cache Service Implementation

final class CacheService: CacheServiceProtocol {
    private let storageService: StorageServiceProtocol
    private let cache = NSCache<NSString, CacheItem>()
    private let queue = DispatchQueue(label: "com.sitly.cache", qos: .utility)
    
    init(storageService: StorageServiceProtocol) {
        self.storageService = storageService
        setupCache()
    }
    
    // MARK: - CacheServiceProtocol
    
    func save<T: Codable & Sendable>(_ object: T, forKey key: String, expiration: TimeInterval?) async {
        let entry = CacheEntry(data: object, timestamp: Date(), expiration: expiration)
        
        do {
            let data = try JSONEncoder().encode(entry)
            try storageService.save(data, forKey: key)
            
            // Обновляем память
            let cacheItem = CacheItem(data: data, timestamp: Date(), expiration: expiration)
            cache.setObject(cacheItem, forKey: key as NSString)
        } catch {
            print("❌ Failed to save cache for key: \(key), error: \(error)")
        }
    }
    
    func load<T: Codable & Sendable>(forKey key: String) async -> T? {
        // Сначала проверяем память
        if let cacheItem = cache.object(forKey: key as NSString) {
            if !cacheItem.isExpired {
                do {
                    let entry = try JSONDecoder().decode(CacheEntry<T>.self, from: cacheItem.data)
                    return entry.data
                } catch {
                    print("❌ Failed to decode cached data for key: \(key), error: \(error)")
                }
            } else {
                // Удаляем истекший элемент из памяти
                cache.removeObject(forKey: key as NSString)
            }
        }
        
        // Проверяем хранилище
        do {
            guard let data: Data = try storageService.load(forKey: key) else { return nil }
            let entry = try JSONDecoder().decode(CacheEntry<T>.self, from: data)
            
            if !entry.isExpired {
                // Обновляем память
                let cacheItem = CacheItem(data: data, timestamp: entry.timestamp, expiration: entry.expiration)
                cache.setObject(cacheItem, forKey: key as NSString)
                return entry.data
            } else {
                // Удаляем истекший элемент
                try? storageService.remove(forKey: key)
                return nil
            }
        } catch {
            print("❌ Failed to load cache for key: \(key), error: \(error)")
            return nil
        }
    }
    
    func remove(forKey key: String) async {
        cache.removeObject(forKey: key as NSString)
        storageService.remove(forKey: key)
    }
    
    func clear() async {
        cache.removeAllObjects()
        storageService.clear()
    }
    
    func isExpired(forKey key: String) async -> Bool {
        // Проверяем память
        if let cacheItem = cache.object(forKey: key as NSString) {
            return cacheItem.isExpired
        }
        
        // Проверяем хранилище
        do {
            guard let data: Data = try storageService.load(forKey: key) else { return true }
            let entry = try JSONDecoder().decode(CacheEntry<Data>.self, from: data)
            return entry.isExpired
        } catch {
            return true
        }
    }
    
    // MARK: - Private Methods
    
    private func setupCache() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    private func cleanupExpiredItems() async {
        // Упрощенная очистка для MVP
        // В реальном приложении здесь была бы более сложная логика
    }
}

// MARK: - Cache Item

private class CacheItem {
    let data: Data
    let timestamp: Date
    let expiration: TimeInterval?
    
    var isExpired: Bool {
        guard let expiration = expiration else { return false }
        return Date().timeIntervalSince(timestamp) > expiration
    }
    
    init(data: Data, timestamp: Date, expiration: TimeInterval?) {
        self.data = data
        self.timestamp = timestamp
        self.expiration = expiration
    }
}

// MARK: - Cache Info

struct CacheInfo: Sendable {
    let memoryItemCount: Int
    let diskSizeBytes: Int
    let totalKeys: Int
    
    var diskSizeMB: Double {
        Double(diskSizeBytes) / (1024 * 1024)
    }
    
    var formattedDiskSize: String {
        if diskSizeMB < 1 {
            return "\(diskSizeBytes) байт"
        } else if diskSizeMB < 1024 {
            return String(format: "%.1f МБ", diskSizeMB)
        } else {
            return String(format: "%.1f ГБ", diskSizeMB / 1024)
        }
    }
}

// MARK: - Cache Keys

enum CacheKey: String, Sendable {
    case restaurants = "restaurants"
    case restaurant = "restaurant_"
    case userProfile = "user_profile"
    case userBookings = "user_bookings"
    
    static func restaurant(id: String) -> String {
        return restaurant.rawValue + id
    }
}

// MARK: - Cache Extensions

extension CacheService {
    // Специализированные методы для часто используемых типов
    
    func cacheRestaurants(_ restaurants: [Restaurant]) async {
        await save(restaurants, forKey: CacheKey.restaurants.rawValue, expiration: 300) // 5 минут
    }
    
    func getCachedRestaurants() async -> [Restaurant]? {
        return await load(forKey: CacheKey.restaurants.rawValue)
    }
    
    func cacheRestaurant(_ restaurant: Restaurant) async {
        await save(restaurant, forKey: CacheKey.restaurant(id: restaurant.id), expiration: 600) // 10 минут
    }
    
    func getCachedRestaurant(id: String) async -> Restaurant? {
        return await load(forKey: CacheKey.restaurant(id: id))
    }
} 