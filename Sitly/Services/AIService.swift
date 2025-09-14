//
//  AIService.swift
//  Sitly
//
//  Created by Maxim Gotovchenko on 14.09.2025.
//

import Foundation
import FirebaseAI

// MARK: - AI Service Protocol
protocol AIServiceProtocol {
    func generateResponse(prompt: String) async throws -> String
    func generateRestaurantRecommendations(userPreferences: String) async throws -> String
    func generateMenuRecommendations(restaurantType: String) async throws -> String
    func analyzeReview(reviewText: String) async throws -> String
    func generateBookingConfirmation(bookingDetails: String) async throws -> String
    func predictCancellation(bookingData: String) async throws -> String
    func optimizeTableAllocation(bookings: String) async throws -> String
    func getPersonalizedRecommendations(for user: User, preferences: UserPreferences) async throws -> String
}

// MARK: - AI Service Implementation
class AIService: AIServiceProtocol {
    private let ai: FirebaseAI
    private let model: GenerativeModel
    
    init() {
        print("🤖 AIService: Инициализация с Gemini")
        self.ai = FirebaseAI.firebaseAI(backend: .googleAI())
        self.model = ai.generativeModel(modelName: "gemini-2.5-flash")
        print("✅ AIService: Gemini модель загружена")
    }
    
    // MARK: - Main Response Generation
    func generateResponse(prompt: String) async throws -> String {
        print("🤖 AIService: Генерация ответа для: \(prompt)")
        
        do {
            let response = try await model.generateContent(prompt)
            let result = response.text ?? "Извините, не удалось сгенерировать ответ"
            print("✅ AIService: Ответ сгенерирован успешно")
            return result
        } catch {
            print("❌ AIService: Ошибка генерации: \(error)")
            throw AIServiceError.generationFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Restaurant Recommendations
    func generateRestaurantRecommendations(userPreferences: String) async throws -> String {
        let prompt = """
        Как AI-помощник ресторана, предложите персонализированные рекомендации на основе предпочтений пользователя: "\(userPreferences)".
        
        Включите:
        - Рекомендуемые блюда
        - Подходящее время для посещения
        - Особые предложения
        - Советы по бронированию
        
        Ответьте на русском языке в дружелюбном тоне.
        """
        
        return try await generateResponse(prompt: prompt)
    }
    
    // MARK: - Menu Recommendations
    func generateMenuRecommendations(restaurantType: String) async throws -> String {
        let prompt = """
        Как AI-помощник, предложите рекомендации по меню для \(restaurantType) ресторана.
        
        Включите:
        - Популярные блюда для этого типа ресторана
        - Сезонные рекомендации
        - Сочетания блюд и напитков
        - Советы по ценообразованию
        
        Ответьте на русском языке в профессиональном тоне.
        """
        
        return try await generateResponse(prompt: prompt)
    }
    
    // MARK: - Review Analysis
    func analyzeReview(reviewText: String) async throws -> String {
        let prompt = """
        Проанализируйте отзыв о ресторане: "\(reviewText)"
        
        Определите:
        - Общий тон отзыва (позитивный/негативный/нейтральный)
        - Основные моменты (еда, сервис, атмосфера, цена)
        - Рекомендации для улучшения
        - Предложение ответа владельца ресторана
        
        Ответьте на русском языке в структурированном виде.
        """
        
        return try await generateResponse(prompt: prompt)
    }
    
    // MARK: - Booking Confirmation
    func generateBookingConfirmation(bookingDetails: String) async throws -> String {
        let prompt = """
        Создайте подтверждение бронирования на основе деталей: "\(bookingDetails)"
        
        Включите:
        - Приветственное сообщение
        - Подтверждение деталей бронирования
        - Полезную информацию для гостя
        - Контактную информацию
        
        Ответьте на русском языке в дружелюбном тоне.
        """
        
        return try await generateResponse(prompt: prompt)
    }
    
    // MARK: - Cancellation Prediction
    func predictCancellation(bookingData: String) async throws -> String {
        let prompt = """
        Проанализируйте вероятность отмены бронирования на основе данных: "\(bookingData)"
        
        Оцените:
        - Вероятность отмены (высокая/средняя/низкая)
        - Факторы риска
        - Рекомендации по предотвращению отмены
        - Стратегии удержания клиента
        
        Ответьте на русском языке в аналитическом тоне.
        """
        
        return try await generateResponse(prompt: prompt)
    }
    
    // MARK: - Table Allocation Optimization
    func optimizeTableAllocation(bookings: String) async throws -> String {
        let prompt = """
        Оптимизируйте распределение столиков на основе бронирований: "\(bookings)"
        
        Предложите:
        - Оптимальное распределение столиков
        - Учет предпочтений гостей
        - Максимизацию загрузки ресторана
        - Решение конфликтов в расписании
        
        Ответьте на русском языке в структурированном виде.
        """
        
        return try await generateResponse(prompt: prompt)
    }
    
    // MARK: - Personalized Recommendations
    func getPersonalizedRecommendations(for user: User, preferences: UserPreferences) async throws -> String {
        let prompt = """
        Создайте персонализированные рекомендации ресторанов для пользователя \(user.name).
        
        Предпочтения: \(preferences)
        
        Включите:
        - Рекомендуемые рестораны
        - Обоснование выбора
        - Особые предложения
        - Советы по бронированию
        
        Ответьте на русском языке в дружелюбном тоне.
        """
        
        return try await generateResponse(prompt: prompt)
    }
}

// MARK: - AI Service Error
enum AIServiceError: Error, LocalizedError {
    case generationFailed(String)
    case invalidPrompt
    case networkError
    case quotaExceeded
    
    var errorDescription: String? {
        switch self {
        case .generationFailed(let message):
            return "Ошибка генерации: \(message)"
        case .invalidPrompt:
            return "Неверный запрос"
        case .networkError:
            return "Ошибка сети"
        case .quotaExceeded:
            return "Превышена квота запросов"
        }
    }
}

// MARK: - AI Models
struct CancellationPrediction {
    let probability: Double
    let riskFactors: [String]
    let recommendations: [String]
}

struct TableAllocation {
    let tableId: String
    let guestId: String
    let timeSlot: String
    let priority: Int
}

// MARK: - Sentiment Analysis
enum SentimentType: String, CaseIterable {
    case positive = "positive"
    case negative = "negative"
    case neutral = "neutral"
    
    var displayName: String {
        switch self {
        case .positive: return "Позитивный"
        case .negative: return "Негативный"
        case .neutral: return "Нейтральный"
        }
    }
}

// MARK: - Chat Context
struct ChatContext {
    let currentRestaurant: Restaurant?
    let userPreferences: [String: Any]?
    let preferences: [String: Any]?
}

// MARK: - AI Service Protocol Extension
extension AIServiceProtocol {
    func chatWithAssistant(message: String, context: ChatContext) async throws -> String {
        let prompt = """
        Как AI-помощник ресторана, ответьте на вопрос: "\(message)"
        
        Контекст:
        - Ресторан: \(context.currentRestaurant?.name ?? "Не указан")
        - Предпочтения пользователя: \(context.userPreferences?.description ?? "Не указаны")
        
        Ответьте на русском языке в дружелюбном тоне, как профессиональный помощник ресторана.
        """
        
        return try await generateResponse(prompt: prompt)
    }
}