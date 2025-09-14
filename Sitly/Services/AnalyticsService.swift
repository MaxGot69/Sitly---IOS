//
//  AnalyticsService.swift
//  Sitly
//
//  Created by AI Assistant on 14.09.2025.
//

import Foundation
import FirebaseAnalytics
import Combine

// MARK: - Analytics Events
enum AnalyticsEvent: String, CaseIterable {
    // Restaurant Events
    case restaurantRegistered = "restaurant_registered"
    case restaurantProfileUpdated = "restaurant_profile_updated"
    case restaurantDashboardViewed = "restaurant_dashboard_viewed"
    
    // Table Management Events
    case tableCreated = "table_created"
    case tableUpdated = "table_updated"
    case tableDeleted = "table_deleted"
    case tableManagementViewed = "table_management_viewed"
    
    // Booking Events
    case bookingCreated = "booking_created"
    case bookingConfirmed = "booking_confirmed"
    case bookingCancelled = "booking_cancelled"
    case bookingViewed = "booking_viewed"
    case bookingManagementViewed = "booking_management_viewed"
    
    // AI Events
    case aiRecommendationRequested = "ai_recommendation_requested"
    case aiRecommendationViewed = "ai_recommendation_viewed"
    case aiChatMessage = "ai_chat_message"
    case aiAnalysisRequested = "ai_analysis_requested"
    
    // Notification Events
    case notificationReceived = "notification_received"
    case notificationTapped = "notification_tapped"
    
    // User Engagement
    case screenViewed = "screen_viewed"
    case featureUsed = "feature_used"
    case errorOccurred = "error_occurred"
}

// MARK: - Analytics Parameters
enum AnalyticsParameter: String {
    case restaurantId = "restaurant_id"
    case userId = "user_id"
    case tableId = "table_id"
    case bookingId = "booking_id"
    case screenName = "screen_name"
    case featureName = "feature_name"
    case errorMessage = "error_message"
    case bookingStatus = "booking_status"
    case tableCapacity = "table_capacity"
    case guestsCount = "guests_count"
    case timeSlot = "time_slot"
    case cuisineType = "cuisine_type"
    case priceRange = "price_range"
    case aiModel = "ai_model"
    case notificationType = "notification_type"
    case sessionDuration = "session_duration"
    case userRole = "user_role"
}

// MARK: - Analytics Service Protocol
protocol AnalyticsServiceProtocol {
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?)
    func setUserProperty(_ value: String?, forName name: String)
    func setUserId(_ userId: String?)
    func logScreenView(_ screenName: String, parameters: [String: Any]?)
    func logError(_ error: Error, context: String?)
    func logUserEngagement(_ feature: String, duration: TimeInterval?)
    func logBookingManagement(bookingId: String, action: String, status: String, guests: Int)
}

// MARK: - Analytics Service Implementation
class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()
    
    private init() {
        // Настройка Firebase Analytics
        setupAnalytics()
    }
    
    private func setupAnalytics() {
        // Включаем сбор аналитики
        Analytics.setAnalyticsCollectionEnabled(true)
        
        // Настраиваем параметры сессии
        Analytics.setSessionTimeoutInterval(1800) // 30 минут
        
        print("📊 AnalyticsService инициализирован")
    }
    
    // MARK: - Event Logging
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        var eventParameters: [String: Any] = [:]
        
        // Добавляем базовые параметры
        eventParameters["timestamp"] = Date().timeIntervalSince1970
        eventParameters["platform"] = "ios"
        
        // Добавляем переданные параметры
        if let parameters = parameters {
            eventParameters.merge(parameters) { (_, new) in new }
        }
        
        Analytics.logEvent(event.rawValue, parameters: eventParameters)
        print("📊 Analytics: \(event.rawValue) - \(eventParameters)")
    }
    
    func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
        print("📊 Analytics: User property set - \(name): \(value ?? "nil")")
    }
    
    func setUserId(_ userId: String?) {
        Analytics.setUserID(userId)
        print("📊 Analytics: User ID set - \(userId ?? "nil")")
    }
    
    func logScreenView(_ screenName: String, parameters: [String: Any]? = nil) {
        var screenParameters: [String: Any] = [
            AnalyticsParameter.screenName.rawValue: screenName,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let parameters = parameters {
            screenParameters.merge(parameters) { (_, new) in new }
        }
        
        Analytics.logEvent(AnalyticsEvent.screenViewed.rawValue, parameters: screenParameters)
        print("📊 Analytics: Screen viewed - \(screenName)")
    }
    
    func logError(_ error: Error, context: String? = nil) {
        var errorParameters: [String: Any] = [
            AnalyticsParameter.errorMessage.rawValue: error.localizedDescription,
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code
        ]
        
        if let context = context {
            errorParameters["error_context"] = context
        }
        
        Analytics.logEvent(AnalyticsEvent.errorOccurred.rawValue, parameters: errorParameters)
        print("📊 Analytics: Error logged - \(error.localizedDescription)")
    }
    
    func logUserEngagement(_ feature: String, duration: TimeInterval? = nil) {
        var engagementParameters: [String: Any] = [
            AnalyticsParameter.featureName.rawValue: feature
        ]
        
        if let duration = duration {
            engagementParameters[AnalyticsParameter.sessionDuration.rawValue] = duration
        }
        
        Analytics.logEvent(AnalyticsEvent.featureUsed.rawValue, parameters: engagementParameters)
        print("📊 Analytics: User engagement - \(feature)")
    }
    
    // MARK: - Convenience Methods
    func logRestaurantRegistration(restaurantId: String, cuisineType: String, priceRange: String) {
        logEvent(.restaurantRegistered, parameters: [
            AnalyticsParameter.restaurantId.rawValue: restaurantId,
            AnalyticsParameter.cuisineType.rawValue: cuisineType,
            AnalyticsParameter.priceRange.rawValue: priceRange
        ])
    }
    
    func logTableManagement(tableId: String, action: String, capacity: Int) {
        let event: AnalyticsEvent
        switch action {
        case "created": event = .tableCreated
        case "updated": event = .tableUpdated
        case "deleted": event = .tableDeleted
        default: event = .tableManagementViewed
        }
        
        logEvent(event, parameters: [
            AnalyticsParameter.tableId.rawValue: tableId,
            AnalyticsParameter.tableCapacity.rawValue: capacity
        ])
    }
    
    func logBookingManagement(bookingId: String, action: String, status: String, guests: Int) {
        let event: AnalyticsEvent
        switch action {
        case "created": event = .bookingCreated
        case "confirmed": event = .bookingConfirmed
        case "cancelled": event = .bookingCancelled
        default: event = .bookingViewed
        }
        
        logEvent(event, parameters: [
            AnalyticsParameter.bookingId.rawValue: bookingId,
            AnalyticsParameter.bookingStatus.rawValue: status,
            AnalyticsParameter.guestsCount.rawValue: guests
        ])
    }
    
    func logAIUsage(feature: String, model: String = "gpt-3.5-turbo") {
        logEvent(.aiRecommendationRequested, parameters: [
            AnalyticsParameter.featureName.rawValue: feature,
            AnalyticsParameter.aiModel.rawValue: model
        ])
    }
    
    func logNotificationReceived(type: String, bookingId: String? = nil) {
        var parameters: [String: Any] = [
            AnalyticsParameter.notificationType.rawValue: type
        ]
        
        if let bookingId = bookingId {
            parameters[AnalyticsParameter.bookingId.rawValue] = bookingId
        }
        
        logEvent(.notificationReceived, parameters: parameters)
    }
}

// MARK: - Mock Analytics Service
class MockAnalyticsService: AnalyticsServiceProtocol {
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?) {
        print("🎭 Mock Analytics: \(event.rawValue) - \(parameters ?? [:])")
    }
    
    func setUserProperty(_ value: String?, forName name: String) {
        print("🎭 Mock Analytics: User property set - \(name): \(value ?? "nil")")
    }
    
    func setUserId(_ userId: String?) {
        print("🎭 Mock Analytics: User ID set - \(userId ?? "nil")")
    }
    
    func logScreenView(_ screenName: String, parameters: [String: Any]?) {
        print("🎭 Mock Analytics: Screen viewed - \(screenName)")
    }
    
    func logError(_ error: Error, context: String?) {
        print("🎭 Mock Analytics: Error logged - \(error.localizedDescription)")
    }
    
    func logUserEngagement(_ feature: String, duration: TimeInterval?) {
        print("🎭 Mock Analytics: User engagement - \(feature)")
    }
    
    func logBookingManagement(bookingId: String, action: String, status: String, guests: Int) {
        print("🎭 Mock Analytics: Booking management - \(action) for booking \(bookingId)")
    }
}
