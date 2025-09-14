import Foundation
import Combine
import SwiftUI

@MainActor
class AIAssistantViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var isAIReady = false
    @Published var errorMessage: String?
    @Published var quickSuggestions: [String] = []
    @Published var contextualActions: [String] = []
    @Published var loadingDots: [Bool] = [false, false, false]
    
    // MARK: - Dependencies
    private let aiService: AIServiceProtocol
    private let restaurantRepository: RestaurantRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(aiService: AIServiceProtocol = AIService(),
         restaurantRepository: RestaurantRepositoryProtocol = RestaurantRepository(networkService: NetworkService(), storageService: StorageService(), cacheService: CacheService(storageService: StorageService()))) {
        self.aiService = aiService
        self.restaurantRepository = restaurantRepository
        
        setupBindings()
        initializeAI()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Анимация точек загрузки
        Timer.publish(every: 0.6, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.animateLoadingDots()
            }
            .store(in: &cancellables)
    }
    
    private func initializeAI() {
        Task {
            // Имитация инициализации AI
            try await Task.sleep(nanoseconds: 2_000_000_000)
            isAIReady = true
        }
    }
    
    // MARK: - Loading Dots Animation
    private func animateLoadingDots() {
        for i in 0..<loadingDots.count {
            loadingDots[i].toggle()
        }
    }
    
    // MARK: - Initial Suggestions
    func loadInitialSuggestions() {
        quickSuggestions = [
            "Как оптимизировать работу ресторана?",
            "Какие блюда добавить в меню?",
            "Как увеличить выручку?",
            "Аналитика по бронированиям"
        ]
    }
    
    // MARK: - Message Handling
    func sendMessage(_ content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Добавляем сообщение пользователя
        let userMessage = ChatMessage(
            id: UUID().uuidString,
            content: content,
            isFromUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // Показываем индикатор загрузки
        isLoading = true
        
        // Отправляем сообщение в AI
        Task {
            do {
                let response = try await processMessage(content)
                
                // Добавляем ответ AI
                let aiMessage = ChatMessage(
                    id: UUID().uuidString,
                    content: response,
                    isFromUser: false,
                    timestamp: Date()
                )
                messages.append(aiMessage)
                
                // Обновляем контекстуальные действия
                updateContextualActions(based: content)
                
            } catch {
                // Показываем сообщение об ошибке
                let errorMessage = ChatMessage(
                    id: UUID().uuidString,
                    content: "Извините, произошла ошибка. Попробуйте еще раз.",
                    isFromUser: false,
                    timestamp: Date()
                )
                messages.append(errorMessage)
                
                self.errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    // MARK: - AI Processing
    private func processMessage(_ content: String) async throws -> String {
        // Создаем контекст для AI
        let context = ChatContext(
            currentRestaurant: nil, // Будет загружен из AppState
            userPreferences: nil, // Будет загружен из AppState
            preferences: nil // Будет загружен из AppState
        )
        
        // Отправляем сообщение в AI-сервис
        return try await aiService.chatWithAssistant(message: content, context: context)
    }
    
    // MARK: - Contextual Actions
    private func updateContextualActions(based message: String) {
        let lowercasedMessage = message.lowercased()
        
        var actions: [String] = []
        
        if lowercasedMessage.contains("меню") || lowercasedMessage.contains("блюда") {
            actions.append("Показать популярные блюда")
            actions.append("Добавить новое блюдо")
            actions.append("Изменить цены")
        }
        
        if lowercasedMessage.contains("бронирование") || lowercasedMessage.contains("столик") {
            actions.append("Показать свободные столики")
            actions.append("Создать бронь")
            actions.append("Отменить бронь")
        }
        
        if lowercasedMessage.contains("аналитика") || lowercasedMessage.contains("статистика") {
            actions.append("Показать графики")
            actions.append("Экспорт данных")
            actions.append("Сравнить периоды")
        }
        
        if lowercasedMessage.contains("оптимизация") || lowercasedMessage.contains("улучшить") {
            actions.append("AI-рекомендации")
            actions.append("Анализ эффективности")
            actions.append("План развития")
        }
        
        // Если действий нет, показываем общие
        if actions.isEmpty {
            actions = [
                "Показать статистику",
                "Управление меню",
                "AI-советы",
                "Настройки ресторана"
            ]
        }
        
        contextualActions = actions
    }
    
    // MARK: - Helper Methods
    private func extractRecentSearches() -> [String] {
        // Извлекаем недавние поиски из сообщений пользователя
        return messages
            .filter { $0.isFromUser }
            .suffix(5)
            .map { $0.content }
    }
    
    // MARK: - Message Actions
    func copyMessage(_ message: ChatMessage) {
        // Копируем сообщение в буфер обмена
        UIPasteboard.general.string = message.content
    }
    
    func shareMessage(_ message: ChatMessage) {
        // Поделиться сообщением
        // В реальном приложении это будет через ShareSheet
    }
    
    func regenerateResponse() {
        guard let lastUserMessage = messages.last(where: { $0.isFromUser }) else { return }
        
        // Удаляем последний ответ AI
        if let lastIndex = messages.lastIndex(where: { !$0.isFromUser }) {
            messages.remove(at: lastIndex)
        }
        
        // Генерируем новый ответ
        sendMessage(lastUserMessage.content)
    }
    
    // MARK: - Restaurant Context
    func loadRestaurantContext() async {
        // Загружаем контекст ресторана для более персонализированных ответов
        // В реальном приложении это будет из AppState
    }
    
    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
    }
    
    func retryLastMessage() {
        guard let lastUserMessage = messages.last(where: { $0.isFromUser }) else { return }
        sendMessage(lastUserMessage.content)
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id: String
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let metadata: MessageMetadata?
    
    init(id: String, content: String, isFromUser: Bool, timestamp: Date, metadata: MessageMetadata? = nil) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

// MARK: - Message Metadata
struct MessageMetadata {
    let messageType: MessageType
    let attachments: [Attachment]
    let sentiment: SentimentType?
    let confidence: Double?
    
    init(messageType: MessageType = .text, attachments: [Attachment] = [], sentiment: SentimentType? = nil, confidence: Double? = nil) {
        self.messageType = messageType
        self.attachments = attachments
        self.sentiment = sentiment
        self.confidence = confidence
    }
}

enum MessageType: String, CaseIterable {
    case text = "text"
    case image = "image"
    case voice = "voice"
    case file = "file"
    case recommendation = "recommendation"
    case action = "action"
    
    var displayName: String {
        switch self {
        case .text: return "Текст"
        case .image: return "Изображение"
        case .voice: return "Голос"
        case .file: return "Файл"
        case .recommendation: return "Рекомендация"
        case .action: return "Действие"
        }
    }
}

struct Attachment {
    let id: String
    let type: AttachmentType
    let url: URL?
    let thumbnail: Data?
    let name: String
    let size: Int64
    
    init(id: String, type: AttachmentType, url: URL? = nil, thumbnail: Data? = nil, name: String, size: Int64) {
        self.id = id
        self.type = type
        self.url = url
        self.thumbnail = thumbnail
        self.name = name
        self.size = size
    }
}

enum AttachmentType: String, CaseIterable {
    case image = "image"
    case audio = "audio"
    case video = "video"
    case document = "document"
    case spreadsheet = "spreadsheet"
    
    var displayName: String {
        switch self {
        case .image: return "Изображение"
        case .audio: return "Аудио"
        case .video: return "Видео"
        case .document: return "Документ"
        case .spreadsheet: return "Таблица"
        }
    }
    
    var icon: String {
        switch self {
        case .image: return "photo"
        case .audio: return "waveform"
        case .video: return "video"
        case .document: return "doc.text"
        case .spreadsheet: return "tablecells"
        }
    }
}

// MARK: - AI Response Types
enum AIResponseType: String, CaseIterable {
    case text = "text"
    case recommendation = "recommendation"
    case action = "action"
    case chart = "chart"
    case table = "table"
    
    var displayName: String {
        switch self {
        case .text: return "Текст"
        case .recommendation: return "Рекомендация"
        case .action: return "Действие"
        case .chart: return "График"
        case .table: return "Таблица"
        }
    }
}

// MARK: - AI Response Context
struct AIResponseContext {
    let userIntent: UserIntent
    let restaurantContext: RestaurantContext?
    let conversationHistory: [ChatMessage]
    let userPreferences: UserPreferences?
    
    init(userIntent: UserIntent, restaurantContext: RestaurantContext? = nil, conversationHistory: [ChatMessage] = [], userPreferences: UserPreferences? = nil) {
        self.userIntent = userIntent
        self.restaurantContext = restaurantContext
        self.conversationHistory = conversationHistory
        self.userPreferences = userPreferences
    }
}

enum UserIntent: String, CaseIterable {
    case question = "question"
    case request = "request"
    case complaint = "complaint"
    case suggestion = "suggestion"
    case general = "general"
    
    var displayName: String {
        switch self {
        case .question: return "Вопрос"
        case .request: return "Запрос"
        case .complaint: return "Жалоба"
        case .suggestion: return "Предложение"
        case .general: return "Общий"
        }
    }
}

struct RestaurantContext {
    let id: String
    let name: String
    let cuisineType: CuisineType
    let currentStatus: RestaurantStatus
    let recentBookings: [Booking]
    let currentMenu: Menu
    let analytics: RestaurantAnalytics
    
    init(id: String, name: String, cuisineType: CuisineType, currentStatus: RestaurantStatus, recentBookings: [Booking] = [], currentMenu: Menu = Menu(), analytics: RestaurantAnalytics = RestaurantAnalytics()) {
        self.id = id
        self.name = name
        self.cuisineType = cuisineType
        self.currentStatus = currentStatus
        self.recentBookings = recentBookings
        self.currentMenu = currentMenu
        self.analytics = analytics
    }
}
