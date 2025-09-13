import Foundation

final class StorageService: StorageServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init() {
        // Настройка JSON кодировщика
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Save
    
    func save<T: Codable>(_ object: T, forKey key: String) throws {
        do {
            let data = try encoder.encode(object)
            userDefaults.set(data, forKey: key)
        } catch {
            throw StorageError.encodingError(error)
        }
    }
    
    func save<T: Codable>(_ object: T, forKey key: String, expiration: TimeInterval) throws {
        let expirationDate = Date().addingTimeInterval(expiration)
        let storageItem = StorageItem(object: object, expirationDate: expirationDate)
        try save(storageItem, forKey: key)
    }
    
    // MARK: - Load
    
    func load<T: Codable>(forKey key: String) throws -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        do {
            // Пытаемся загрузить как обычный объект
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            // Если не получилось, пытаемся загрузить как StorageItem
            do {
                let storageItem = try decoder.decode(StorageItem<T>.self, from: data)
                
                // Проверяем срок действия
                if storageItem.isExpired {
                    remove(forKey: key)
                    return nil
                }
                
                return storageItem.object
            } catch {
                throw StorageError.decodingError(error)
            }
        }
    }
    
    // MARK: - Remove
    
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func clear() {
        // Получаем все ключи
        let keys = userDefaults.dictionaryRepresentation().keys
        
        // Удаляем все ключи, кроме системных
        for key in keys {
            if !key.hasPrefix("Apple") && !key.hasPrefix("NS") && !key.hasPrefix("WebKit") {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
    
    // MARK: - Utility Methods
    
    func hasValue(forKey key: String) -> Bool {
        return userDefaults.object(forKey: key) != nil
    }
    
    func getKeys() -> [String] {
        return Array(userDefaults.dictionaryRepresentation().keys)
    }
    
    func getSize(forKey key: String) -> Int {
        guard let data = userDefaults.data(forKey: key) else { return 0 }
        return data.count
    }
    
    func getTotalSize() -> Int {
        let keys = getKeys()
        var totalSize = 0
        
        for key in keys {
            totalSize += getSize(forKey: key)
        }
        
        return totalSize
    }
    
    // MARK: - Migration
    
    func migrateData(from oldKey: String, to newKey: String) throws {
        guard let data = userDefaults.data(forKey: oldKey) else { return }
        
        // Копируем данные под новым ключом
        userDefaults.set(data, forKey: newKey)
        
        // Удаляем старый ключ
        userDefaults.removeObject(forKey: oldKey)
    }
}

// MARK: - Storage Item

private struct StorageItem<T: Codable>: Codable {
    let object: T
    let expirationDate: Date
    
    var isExpired: Bool {
        Date() > expirationDate
    }
}

// MARK: - Storage Error

enum StorageError: LocalizedError {
    case encodingError(Error)
    case decodingError(Error)
    case keyNotFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .encodingError(let error):
            return "Ошибка кодирования: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Ошибка декодирования: \(error.localizedDescription)"
        case .keyNotFound:
            return "Ключ не найден"
        case .invalidData:
            return "Некорректные данные"
        }
    }
}
