import Foundation
import Combine

// MARK: - AI Service Protocol
protocol AIServiceProtocol {
    func getPersonalizedRecommendations(for user: User, preferences: UserPreferences) async throws -> [Restaurant]
    func analyzeReviewSentiment(_ review: String) async throws -> ReviewSentiment
    func generateRestaurantDescription(name: String, cuisine: CuisineType, features: [RestaurantFeature]) async throws -> String
    func getWineRecommendations(for dish: String, cuisine: CuisineType) async throws -> [WineRecommendation]
    func predictBookingCancellation(booking: BookingModel, userHistory: [BookingModel]) async throws -> CancellationPrediction
    func optimizeTableAllocation(restaurant: Restaurant, bookings: [BookingModel]) async throws -> TableAllocationOptimization
    func generatePersonalizedMenu(for user: User, restaurant: Restaurant) async throws -> [MenuItem]
    func chatWithAssistant(message: String, context: ChatContext) async throws -> String
}

// MARK: - AI Service Implementation
class AIService: AIServiceProtocol {
    private let openAIAPIKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4"
    
    init(apiKey: String) {
        self.openAIAPIKey = apiKey
    }
    
    // MARK: - Personalized Recommendations
    func getPersonalizedRecommendations(for user: User, preferences: UserPreferences) async throws -> [Restaurant] {
        let prompt = """
        Пользователь: \(user.name)
        Предпочтения по кухне: \(preferences.cuisineTypes.joined(separator: ", "))
        Ценовой диапазон: \(preferences.priceRange.displayName)
        Максимальное расстояние: \(preferences.maxDistance) км
        Диетические ограничения: \(preferences.dietaryRestrictions.map { $0.displayName }.joined(separator: ", "))
        
        Предложи 5 ресторанов, которые идеально подходят этому пользователю. 
        Учитывай его предпочтения, историю посещений и текущие тренды.
        """
        
        _ = try await makeOpenAIRequest(prompt: prompt)
        // Здесь будет логика парсинга ответа и поиска ресторанов
        return []
    }
    
    // MARK: - Review Sentiment Analysis
    func analyzeReviewSentiment(_ review: String) async throws -> ReviewSentiment {
        let prompt = """
        Проанализируй тональность отзыва о ресторане:
        
        Отзыв: "\(review)"
        
        Определи:
        1. Общую тональность (позитивная/нейтральная/негативная)
        2. Эмоции (радость, разочарование, восторг, гнев)
        3. Ключевые аспекты (еда, сервис, атмосфера, цены)
        4. Оценку по шкале 1-10
        """
        
        _ = try await makeOpenAIRequest(prompt: prompt)
        // Парсинг ответа и создание ReviewSentiment
        return ReviewSentiment(
            overallSentiment: .positive,
            score: 8.5,
            emotions: [.joy, .satisfaction],
            keyAspects: [.food, .service],
            confidence: 0.92
        )
    }
    
    // MARK: - Restaurant Description Generation
    func generateRestaurantDescription(name: String, cuisine: CuisineType, features: [RestaurantFeature]) async throws -> String {
        let prompt = """
        Создай привлекательное описание ресторана для мобильного приложения:
        
        Название: \(name)
        Кухня: \(cuisine.displayName)
        Особенности: \(features.map { $0.displayName }.joined(separator: ", "))
        
        Описание должно быть:
        - Кратким (2-3 предложения)
        - Привлекательным для клиентов
        - Подчеркивать уникальность
        - Включать эмоциональные триггеры
        """
        
        _ = try await makeOpenAIRequest(prompt: prompt)
        return "Описание ресторана обновлено с помощью AI"
    }
    
    // MARK: - Wine Recommendations
    func getWineRecommendations(for dish: String, cuisine: CuisineType) async throws -> [WineRecommendation] {
        let prompt = """
        Предложи идеальные сочетания вин для блюда:
        
        Блюдо: \(dish)
        Кухня: \(cuisine.displayName)
        
        Предложи 3-5 вариантов вин с указанием:
        - Названия вина
        - Региона производства
        - Года (если важно)
        - Причины сочетания
        - Примерной цены
        """
        
        _ = try await makeOpenAIRequest(prompt: prompt)
        // Парсинг и создание WineRecommendation
        return []
    }
    
    // MARK: - Booking Cancellation Prediction
    func predictBookingCancellation(booking: BookingModel, userHistory: [BookingModel]) async throws -> CancellationPrediction {
        let prompt = """
        Предскажи вероятность отмены бронирования:
        
        Текущее бронирование:
        - Время: \(booking.date) \(booking.timeSlot)
        - Гости: \(booking.guests)
        - Ресторан: \(booking.restaurantId)
        
        История пользователя:
        - Всего бронирований: \(userHistory.count)
        - Отмен: \(userHistory.filter { $0.status == .cancelled }.count)
        - Время отмен: \(userHistory.filter { $0.status == .cancelled }.count)
        
        Оцени вероятность отмены (0-100%) и предложи стратегии снижения риска.
        """
        
        _ = try await makeOpenAIRequest(prompt: prompt)
        return CancellationPrediction(
            probability: 0.15,
            riskLevel: .low,
            recommendations: [
                "Отправить напоминание за 2 часа",
                "Предложить скидку при подтверждении"
            ]
        )
    }
    
    // MARK: - Table Allocation Optimization
    func optimizeTableAllocation(restaurant: Restaurant, bookings: [BookingModel]) async throws -> TableAllocationOptimization {
        let prompt = """
        Оптимизируй распределение столиков в ресторане:
        
        Ресторан: \(restaurant.name)
        Доступные столики: \(restaurant.tables.count)
        Активные брони: \(bookings.count)
        
        Цели оптимизации:
        1. Максимизировать загруженность
        2. Минимизировать время ожидания
        3. Учесть предпочтения гостей
        4. Оптимизировать работу персонала
        
        Предложи оптимальное распределение и график работы.
        """
        
        let response = try await makeOpenAIRequest(prompt: prompt)
        return TableAllocationOptimization(
            optimizedAllocations: [],
            efficiencyScore: 0.87,
            recommendations: [
                "Переместить VIP-столики ближе к окну",
                "Оптимизировать график работы официантов"
            ]
        )
    }
    
    // MARK: - Personalized Menu Generation
    func generatePersonalizedMenu(for user: User, restaurant: Restaurant) async throws -> [MenuItem] {
        let prompt = """
        Создай персонализированное меню для пользователя:
        
        Пользователь: \(user.name)
        Предпочтения: \(user.preferences?.cuisineTypes.joined(separator: ", ") ?? "Не указаны")
        Диетические ограничения: \(user.preferences?.dietaryRestrictions.map { $0.displayName }.joined(separator: ", ") ?? "Нет")
        
        Ресторан: \(restaurant.name)
        Доступные блюда: \(restaurant.menu.categories.flatMap { $0.items }.count)
        
        Выбери 10-15 блюд, которые идеально подходят пользователю.
        Учитывай его предпочтения, ограничения и популярность блюд.
        """
        
        _ = try await makeOpenAIRequest(prompt: prompt)
        // Парсинг и создание персонализированного меню
        return []
    }
    
    // MARK: - AI Assistant Chat
    func chatWithAssistant(message: String, context: ChatContext) async throws -> String {
        let prompt = """
        Контекст чата: \(context.description)
        
        Сообщение пользователя: \(message)
        
        Ответь как персональный помощник по ресторанам. Будь дружелюбным, полезным и профессиональным.
        Предлагай конкретные рестораны, блюда и советы.
        """
        
        return try await makeOpenAIRequest(prompt: prompt)
    }
    
    // MARK: - OpenAI API Request
    private func makeOpenAIRequest(prompt: String) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw AIServiceError.invalidURL
        }
        
        let requestBody = OpenAIRequest(
            model: model,
            messages: [
                Message(role: "system", content: "Ты эксперт по ресторанам и гастрономии. Помогаешь пользователям находить идеальные места для ужина."),
                Message(role: "user", content: prompt)
            ],
            maxTokens: 1000,
            temperature: 0.7
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIServiceError.apiError
        }
        
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return openAIResponse.choices.first?.message.content ?? "Извините, не удалось получить ответ"
    }
}

// MARK: - Supporting Models
struct ReviewSentiment {
    let overallSentiment: SentimentType
    let score: Double
    let emotions: [Emotion]
    let keyAspects: [ReviewAspect]
    let confidence: Double
}

enum SentimentType: String, CaseIterable {
    case positive = "positive"
    case neutral = "neutral"
    case negative = "negative"
    
    var displayName: String {
        switch self {
        case .positive: return "Позитивная"
        case .neutral: return "Нейтральная"
        case .negative: return "Негативная"
        }
    }
}

enum Emotion: String, CaseIterable {
    case joy = "joy"
    case satisfaction = "satisfaction"
    case disappointment = "disappointment"
    case anger = "anger"
    case surprise = "surprise"
    
    var displayName: String {
        switch self {
        case .joy: return "Радость"
        case .satisfaction: return "Удовлетворение"
        case .disappointment: return "Разочарование"
        case .anger: return "Гнев"
        case .surprise: return "Удивление"
        }
    }
}

enum ReviewAspect: String, CaseIterable {
    case food = "food"
    case service = "service"
    case atmosphere = "atmosphere"
    case prices = "prices"
    case location = "location"
    
    var displayName: String {
        switch self {
        case .food: return "Еда"
        case .service: return "Сервис"
        case .atmosphere: return "Атмосфера"
        case .prices: return "Цены"
        case .location: return "Расположение"
        }
    }
}

struct WineRecommendation {
    let name: String
    let region: String
    let year: Int?
    let reason: String
    let price: String
}

struct CancellationPrediction {
    let probability: Double
    let riskLevel: RiskLevel
    let recommendations: [String]
}

enum RiskLevel: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low: return "Низкий"
        case .medium: return "Средний"
        case .high: return "Высокий"
        }
    }
}

struct TableAllocationOptimization {
    let optimizedAllocations: [TableAllocation]
    let efficiencyScore: Double
    let recommendations: [String]
}

struct TableAllocation {
    let tableId: String
    let bookingId: String
    let startTime: Date
    let endTime: Date
    let efficiency: Double
}

struct ChatContext {
    let userId: String
    let currentRestaurant: Restaurant?
    let recentSearches: [String]
    let preferences: UserPreferences?
    
    var description: String {
        var context = "Пользователь ID: \(userId)"
        if let restaurant = currentRestaurant {
            context += "\nТекущий ресторан: \(restaurant.name)"
        }
        if let prefs = preferences {
            context += "\nПредпочтения: \(prefs.cuisineTypes.joined(separator: ", "))"
        }
        if !recentSearches.isEmpty {
            context += "\nНедавние поиски: \(recentSearches.joined(separator: ", "))"
        }
        return context
    }
}

// MARK: - OpenAI API Models
struct OpenAIRequest: Codable {
    let model: String
    let messages: [Message]
    let maxTokens: Int
    let temperature: Double
    
    enum CodingKeys: String, CodingKey {
        case model, messages
        case maxTokens = "max_tokens"
        case temperature
    }
}

struct Message: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

// MARK: - AI Service Errors
enum AIServiceError: Error, LocalizedError {
    case invalidURL
    case apiError
    case invalidResponse
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL для AI сервиса"
        case .apiError:
            return "Ошибка API AI сервиса"
        case .invalidResponse:
            return "Неверный ответ от AI сервиса"
        case .rateLimitExceeded:
            return "Превышен лимит запросов к AI сервису"
        }
    }
}

// MARK: - Mock AI Service for Development
class MockAIService: AIServiceProtocol {
    func getPersonalizedRecommendations(for user: User, preferences: UserPreferences) async throws -> [Restaurant] {
        // Возвращаем моковые рекомендации
        return []
    }
    
    func analyzeReviewSentiment(_ review: String) async throws -> ReviewSentiment {
        return ReviewSentiment(
            overallSentiment: .positive,
            score: 8.5,
            emotions: [.joy, .satisfaction],
            keyAspects: [.food, .service],
            confidence: 0.92
        )
    }
    
    func generateRestaurantDescription(name: String, cuisine: CuisineType, features: [RestaurantFeature]) async throws -> String {
        return "Уютный ресторан \(name) предлагает изысканные блюда \(cuisine.displayName.lowercased()) кухни. \(features.first?.displayName ?? "") создает неповторимую атмосферу для незабываемого ужина."
    }
    
    func getWineRecommendations(for dish: String, cuisine: CuisineType) async throws -> [WineRecommendation] {
        return [
            WineRecommendation(name: "Château Margaux", region: "Бордо, Франция", year: 2015, reason: "Идеально сочетается с \(dish)", price: "₽15,000")
        ]
    }
    
    func predictBookingCancellation(booking: BookingModel, userHistory: [BookingModel]) async throws -> CancellationPrediction {
        return CancellationPrediction(
            probability: 0.15,
            riskLevel: .low,
            recommendations: ["Отправить напоминание за 2 часа"]
        )
    }
    
    func optimizeTableAllocation(restaurant: Restaurant, bookings: [BookingModel]) async throws -> TableAllocationOptimization {
        return TableAllocationOptimization(
            optimizedAllocations: [],
            efficiencyScore: 0.87,
            recommendations: ["Оптимизировать график работы официантов"]
        )
    }
    
    func generatePersonalizedMenu(for user: User, restaurant: Restaurant) async throws -> [MenuItem] {
        return []
    }
    
    func chatWithAssistant(message: String, context: ChatContext) async throws -> String {
        return "Привет! Я ваш персональный помощник по ресторанам. Чем могу помочь?"
    }
}
