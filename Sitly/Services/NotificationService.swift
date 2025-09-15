//
//  NotificationService.swift
//  Sitly
//
//  Created by AI Assistant on 14.09.2025.
//

import Foundation
import UserNotifications
import Combine

// MARK: - Notification Types
enum AppNotificationType: String, CaseIterable {
    case newBooking = "new_booking"
    case bookingConfirmed = "booking_confirmed"
    case bookingCancelled = "booking_cancelled"
    case tableReserved = "table_reserved"
    case reviewReceived = "review_received"
    case aiRecommendation = "ai_recommendation"
    
    var title: String {
        switch self {
        case .newBooking:
            return "Новое бронирование! 🎉"
        case .bookingConfirmed:
            return "Бронирование подтверждено ✅"
        case .bookingCancelled:
            return "Бронирование отменено ❌"
        case .tableReserved:
            return "Столик забронирован 🪑"
        case .reviewReceived:
            return "Новый отзыв! ⭐"
        case .aiRecommendation:
            return "AI-рекомендация 🤖"
        }
    }
    
    var sound: UNNotificationSound {
        switch self {
        case .newBooking, .reviewReceived:
            return .default
        case .bookingConfirmed, .tableReserved:
            return .default
        case .bookingCancelled:
            return .default
        case .aiRecommendation:
            return .default
        }
    }
}

// MARK: - Notification Data
struct NotificationData {
    let type: AppNotificationType
    let title: String
    let body: String
    let data: [String: Any]
    let scheduledTime: Date?
    
    init(type: AppNotificationType, title: String? = nil, body: String, data: [String: Any] = [:], scheduledTime: Date? = nil) {
        self.type = type
        self.title = title ?? type.title
        self.body = body
        self.data = data
        self.scheduledTime = scheduledTime
    }
}

// MARK: - Notification Service Protocol
protocol NotificationServiceProtocol {
    func requestPermission() async -> Bool
    func sendNotification(_ notification: NotificationData)
    func scheduleNotification(_ notification: NotificationData)
    func cancelNotification(withId id: String)
    func cancelAllNotifications()
    func getPendingNotifications() async -> [UNNotificationRequest]
}

// MARK: - Notification Service Implementation
class NotificationService: NSObject, NotificationServiceProtocol, ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    private let center = UNUserNotificationCenter.current()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        center.delegate = self
        checkAuthorizationStatus()
    }
    
    // MARK: - Permission Management
    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                self.isAuthorized = granted
            }
            return granted
        } catch {
            print("❌ Ошибка запроса разрешений: \(error)")
            return false
        }
    }
    
    private func checkAuthorizationStatus() {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Send Notifications
    func sendNotification(_ notification: NotificationData) {
        guard isAuthorized else {
            print("⚠️ Уведомления не разрешены")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = notification.type.sound
        content.userInfo = notification.data
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        center.add(request) { error in
            if let error = error {
                print("❌ Ошибка отправки уведомления: \(error)")
            } else {
                print("✅ Уведомление отправлено: \(notification.title)")
            }
        }
    }
    
    func scheduleNotification(_ notification: NotificationData) {
        guard isAuthorized else {
            print("⚠️ Уведомления не разрешены")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = notification.type.sound
        content.userInfo = notification.data
        
        let trigger: UNNotificationTrigger
        if let scheduledTime = notification.scheduledTime {
            let timeInterval = scheduledTime.timeIntervalSinceNow
            if timeInterval > 0 {
                trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            } else {
                trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            }
        } else {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        }
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("❌ Ошибка планирования уведомления: \(error)")
            } else {
                print("✅ Уведомление запланировано: \(notification.title)")
            }
        }
    }
    
    // MARK: - Cancel Notifications
    func cancelNotification(withId id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.removeDeliveredNotifications(withIdentifiers: [id])
    }
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
    
    // MARK: - Get Pending Notifications
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await center.pendingNotificationRequests()
    }
    
    // MARK: - Convenience Methods
    func sendNewBookingNotification(booking: Booking) {
        let notification = NotificationData(
            type: .newBooking,
            body: "Новое бронирование на \(booking.timeSlot) для \(booking.guests) гостей",
            data: [
                "bookingId": booking.id,
                "restaurantId": booking.restaurantId,
                "guests": booking.guests,
                "timeSlot": booking.timeSlot
            ]
        )
        sendNotification(notification)
    }
    
    func sendBookingConfirmedNotification(booking: Booking) {
        let notification = NotificationData(
            type: .bookingConfirmed,
            body: "Бронирование подтверждено на \(booking.timeSlot)",
            data: [
                "bookingId": booking.id,
                "restaurantId": booking.restaurantId
            ]
        )
        sendNotification(notification)
    }
    
    func sendBookingCancelledNotification(booking: Booking) {
        let notification = NotificationData(
            type: .bookingCancelled,
            body: "Бронирование отменено на \(booking.timeSlot)",
            data: [
                "bookingId": booking.id,
                "restaurantId": booking.restaurantId
            ]
        )
        sendNotification(notification)
    }
    
    func sendAIRecommendationNotification(recommendation: String) {
        let notification = NotificationData(
            type: .aiRecommendation,
            body: recommendation,
            data: [
                "type": "ai_recommendation"
            ]
        )
        sendNotification(notification)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Показываем уведомление даже когда приложение открыто
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Обрабатываем нажатие на уведомление
        let userInfo = response.notification.request.content.userInfo
        
        if let bookingId = userInfo["bookingId"] as? String {
            print("🔔 Пользователь нажал на уведомление о бронировании: \(bookingId)")
            // Здесь можно открыть детали бронирования
        }
        
        completionHandler()
    }
}

// MARK: - Mock Notification Service
class MockNotificationService: NotificationServiceProtocol {
    func requestPermission() async -> Bool {
        print("🎭 Mock: Запрос разрешений на уведомления")
        return true
    }
    
    func sendNotification(_ notification: NotificationData) {
        print("🎭 Mock: Отправка уведомления - \(notification.title): \(notification.body)")
    }
    
    func scheduleNotification(_ notification: NotificationData) {
        print("🎭 Mock: Планирование уведомления - \(notification.title): \(notification.body)")
    }
    
    func cancelNotification(withId id: String) {
        print("🎭 Mock: Отмена уведомления с ID: \(id)")
    }
    
    func cancelAllNotifications() {
        print("🎭 Mock: Отмена всех уведомлений")
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        print("🎭 Mock: Получение запланированных уведомлений")
        return []
    }
}
