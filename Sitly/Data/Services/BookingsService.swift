//
//  BookingsService.swift
//  Sitly
//
//  Created by AI Assistant on 12.09.2025.
//

import Foundation
import FirebaseFirestore
import Combine

protocol BookingsServiceProtocol {
    func fetchBookings(for restaurantId: String) async throws -> [Booking]
    func createBooking(_ booking: Booking) async throws -> Booking
    func updateBooking(_ booking: Booking) async throws
    func deleteBooking(_ booking: Booking) async throws
    func updateBookingStatus(_ bookingId: String, status: BookingStatus, restaurantId: String) async throws
    func observeBookings(for restaurantId: String) -> AnyPublisher<[Booking], Error>
    func getBookingAnalytics(for restaurantId: String) async throws -> [String: Any]
}

class BookingsService: BookingsServiceProtocol {
    private let db = Firestore.firestore()
    private var listeners: [String: ListenerRegistration] = [:]
    private let notificationService: NotificationServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    init(notificationService: NotificationServiceProtocol = NotificationService.shared,
         analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared) {
        self.notificationService = notificationService
        self.analyticsService = analyticsService
    }
    
    // MARK: - Fetch Bookings
    func fetchBookings(for restaurantId: String) async throws -> [Booking] {
        print("📅 Загружаем бронирования для ресторана: \(restaurantId)")
        
        let snapshot = try await db
            .collection("restaurants")
            .document(restaurantId)
            .collection("bookings")
            .order(by: "date", descending: false)
            .getDocuments()
        
        let bookings = try snapshot.documents.compactMap { document -> Booking? in
            var data = document.data()
            data["id"] = document.documentID
            
            // Конвертируем Timestamp в Date
            if let timestamp = data["date"] as? Timestamp {
                data["date"] = timestamp.dateValue()
            }
            if let createdTimestamp = data["createdAt"] as? Timestamp {
                data["createdAt"] = createdTimestamp.dateValue()
            }
            if let updatedTimestamp = data["updatedAt"] as? Timestamp {
                data["updatedAt"] = updatedTimestamp.dateValue()
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            return try JSONDecoder().decode(Booking.self, from: jsonData)
        }
        
        print("✅ Загружено бронирований: \(bookings.count)")
        return bookings
    }
    
    // MARK: - Create Booking
    func createBooking(_ booking: Booking) async throws -> Booking {
        print("➕ Создаем бронирование: \(booking.clientName) на \(booking.date)")
        
        let bookingData = Booking(
            id: booking.id,
            restaurantId: booking.restaurantId,
            clientId: booking.clientId,
            tableId: booking.tableId,
            date: booking.date,
            timeSlot: booking.timeSlot,
            guests: booking.guests,
            status: booking.status,
            specialRequests: booking.specialRequests,
            totalPrice: booking.totalPrice,
            paymentStatus: booking.paymentStatus,
            clientName: booking.clientName,
            clientPhone: booking.clientPhone,
            clientEmail: booking.clientEmail,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let jsonData = try JSONEncoder().encode(bookingData)
        var data = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
        
        // Убираем id, чтобы Firestore сгенерировал автоматически
        data.removeValue(forKey: "id")
        
        // Добавляем timestamp
        data["createdAt"] = FieldValue.serverTimestamp()
        data["updatedAt"] = FieldValue.serverTimestamp()
        
        let documentRef = try await db
            .collection("restaurants")
            .document(booking.restaurantId)
            .collection("bookings")
            .addDocument(data: data)
        
        // Возвращаем бронирование с новым ID
        var createdBooking = bookingData
        createdBooking.id = documentRef.documentID
        
        print("✅ Бронирование создано с ID: \(documentRef.documentID)")
        
        // Логируем создание бронирования
        analyticsService.logBookingManagement(
            bookingId: createdBooking.id,
            action: "created",
            status: createdBooking.status.rawValue,
            guests: createdBooking.guests
        )
        
        // Отправляем уведомление ресторану
        await sendBookingNotification(booking: createdBooking, type: .newBooking)
        
        return createdBooking
    }
    
    // MARK: - Update Booking
    func updateBooking(_ booking: Booking) async throws {
        print("🔄 Обновляем бронирование: \(booking.id)")
        
        var updatedBooking = booking
        updatedBooking.updatedAt = Date()
        
        let jsonData = try JSONEncoder().encode(updatedBooking)
        var data = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
        
        // Убираем id и добавляем timestamp
        data.removeValue(forKey: "id")
        data["updatedAt"] = FieldValue.serverTimestamp()
        
        try await db
            .collection("restaurants")
            .document(booking.restaurantId)
            .collection("bookings")
            .document(booking.id)
            .updateData(data)
        
        print("✅ Бронирование обновлено")
    }
    
    // MARK: - Delete Booking
    func deleteBooking(_ booking: Booking) async throws {
        print("🗑️ Удаляем бронирование: \(booking.id)")
        
        try await db
            .collection("restaurants")
            .document(booking.restaurantId)
            .collection("bookings")
            .document(booking.id)
            .delete()
        
        print("✅ Бронирование удалено")
    }
    
    // MARK: - Update Booking Status
    func updateBookingStatus(_ bookingId: String, status: BookingStatus, restaurantId: String) async throws {
        print("🔄 Обновляем статус бронирования \(bookingId) на \(status.displayName)")
        
        try await db
            .collection("restaurants")
            .document(restaurantId)
            .collection("bookings")
            .document(bookingId)
            .updateData([
                "status": status.rawValue,
                "updatedAt": FieldValue.serverTimestamp()
            ])
        
        print("✅ Статус бронирования обновлен")
        
        // Получаем данные бронирования для уведомления
        do {
            let booking = try await fetchBooking(bookingId: bookingId, restaurantId: restaurantId)
            let notificationType: BookingNotificationType
            
            switch status {
            case .confirmed:
                notificationType = .bookingConfirmed
            case .cancelled:
                notificationType = .bookingCancelled
            case .pending, .noShow, .completed:
                notificationType = .newBooking
            }
            
            // Логируем изменение статуса
            analyticsService.logBookingManagement(
                bookingId: bookingId,
                action: status == .confirmed ? "confirmed" : status == .cancelled ? "cancelled" : "updated",
                status: status.rawValue,
                guests: booking.guests
            )
            
            await sendBookingNotification(booking: booking, type: notificationType)
        } catch {
            print("⚠️ Не удалось получить данные бронирования для уведомления: \(error)")
            analyticsService.logError(error, context: "updateBookingStatus")
        }
    }
    
    // MARK: - Real-time Observations
    func observeBookings(for restaurantId: String) -> AnyPublisher<[Booking], Error> {
        print("👀 Настраиваем наблюдение за бронированиями ресторана: \(restaurantId)")
        
        return Future<[Booking], Error> { promise in
            let listener = self.db
                .collection("restaurants")
                .document(restaurantId)
                .collection("bookings")
                .order(by: "date", descending: false)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("❌ Ошибка наблюдения за бронированиями: \(error)")
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    do {
                        let bookings = try documents.compactMap { document -> Booking? in
                            var data = document.data()
                            data["id"] = document.documentID
                            
                            // Конвертируем Timestamp в Date
                            if let timestamp = data["date"] as? Timestamp {
                                data["date"] = timestamp.dateValue()
                            }
                            if let createdTimestamp = data["createdAt"] as? Timestamp {
                                data["createdAt"] = createdTimestamp.dateValue()
                            }
                            if let updatedTimestamp = data["updatedAt"] as? Timestamp {
                                data["updatedAt"] = updatedTimestamp.dateValue()
                            }
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: data)
                            return try JSONDecoder().decode(Booking.self, from: jsonData)
                        }
                        
                        print("📊 Обновлено бронирований: \(bookings.count)")
                        promise(.success(bookings))
                    } catch {
                        print("❌ Ошибка парсинга бронирований: \(error)")
                        promise(.failure(error))
                    }
                }
            
            // Сохраняем listener для отписки
            self.listeners[restaurantId] = listener
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Analytics
    func getBookingAnalytics(for restaurantId: String) async throws -> [String: Any] {
        print("📊 Получаем аналитику бронирований для ресторана: \(restaurantId)")
        
        let bookings = try await fetchBookings(for: restaurantId)
        
        let totalBookings = bookings.count
        let confirmedBookings = bookings.filter { $0.status == .confirmed }.count
        let cancelledBookings = bookings.filter { $0.status == .cancelled }.count
        let noShowBookings = bookings.filter { $0.status == .noShow }.count
        
        let averagePartySize = bookings.isEmpty ? 0.0 : Double(bookings.reduce(0) { $0 + $1.guests }) / Double(bookings.count)
        let totalRevenue = bookings.filter { $0.paymentStatus == .paid }.reduce(0.0) { $0 + $1.totalPrice }
        
        // Популярные временные слоты
        var timeSlotCounts: [String: Int] = [:]
        for booking in bookings {
            timeSlotCounts[booking.timeSlot, default: 0] += 1
        }
        
        // Популярные столики
        var tableCounts: [String: Int] = [:]
        for booking in bookings {
            tableCounts[booking.tableId, default: 0] += 1
        }
        
        return [
            "totalBookings": totalBookings,
            "confirmedBookings": confirmedBookings,
            "cancelledBookings": cancelledBookings,
            "noShowBookings": noShowBookings,
            "averagePartySize": averagePartySize,
            "totalRevenue": totalRevenue,
            "popularTimeSlots": timeSlotCounts,
            "popularTables": tableCounts
        ] as [String: Any]
    }
    
    // MARK: - Helper Methods
    private func fetchBooking(bookingId: String, restaurantId: String) async throws -> Booking {
        let document = try await db
            .collection("restaurants")
            .document(restaurantId)
            .collection("bookings")
            .document(bookingId)
            .getDocument()
        
        guard let data = document.data() else {
            throw NSError(domain: "BookingsService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Бронирование не найдено"])
        }
        
        var bookingData = data
        bookingData["id"] = document.documentID
        
        // Конвертируем Timestamp в Date
        if let timestamp = data["date"] as? Timestamp {
            bookingData["date"] = timestamp.dateValue()
        }
        if let createdTimestamp = data["createdAt"] as? Timestamp {
            bookingData["createdAt"] = createdTimestamp.dateValue()
        }
        if let updatedTimestamp = data["updatedAt"] as? Timestamp {
            bookingData["updatedAt"] = updatedTimestamp.dateValue()
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: bookingData)
        return try JSONDecoder().decode(Booking.self, from: jsonData)
    }
    
    // MARK: - Notifications
    private func sendBookingNotification(booking: Booking, type: BookingNotificationType) async {
        print("🔔 Отправляем уведомление: \(type.rawValue)")
        
        let notification: NotificationData
        
        switch type {
        case .newBooking:
            notification = NotificationData(
                type: .newBooking,
                body: "Новое бронирование на \(booking.timeSlot) для \(booking.guests) гостей",
                data: [
                    "bookingId": booking.id,
                    "restaurantId": booking.restaurantId,
                    "guests": booking.guests,
                    "timeSlot": booking.timeSlot
                ]
            )
        case .bookingConfirmed:
            notification = NotificationData(
                type: .bookingConfirmed,
                body: "Бронирование подтверждено на \(booking.timeSlot)",
                data: [
                    "bookingId": booking.id,
                    "restaurantId": booking.restaurantId
                ]
            )
        case .bookingCancelled:
            notification = NotificationData(
                type: .bookingCancelled,
                body: "Бронирование отменено на \(booking.timeSlot)",
                data: [
                    "bookingId": booking.id,
                    "restaurantId": booking.restaurantId
                ]
            )
        case .reminderBooking:
            notification = NotificationData(
                type: .bookingConfirmed,
                body: "Напоминание о бронировании на \(booking.timeSlot)",
                data: [
                    "bookingId": booking.id,
                    "restaurantId": booking.restaurantId
                ]
            )
        }
        
        notificationService.sendNotification(notification)
    }
    
    // MARK: - Cleanup
    func stopObserving(restaurantId: String) {
        listeners[restaurantId]?.remove()
        listeners.removeValue(forKey: restaurantId)
        print("🛑 Остановлено наблюдение за бронированиями ресторана: \(restaurantId)")
    }
    
    deinit {
        listeners.values.forEach { $0.remove() }
        print("🧹 BookingsService очищен")
    }
}

// MARK: - Mock Service for Development
class MockBookingsService: BookingsServiceProtocol {
    private var mockBookings: [Booking] = []
    private let subject = PassthroughSubject<[Booking], Error>()
    
    init() {
        generateMockBookings()
    }
    
    private func generateMockBookings() {
        let calendar = Calendar.current
        let today = Date()
        
        mockBookings = [
            Booking(
                restaurantId: "demo-restaurant",
                clientId: "client1",
                tableId: "table1",
                date: calendar.date(byAdding: .hour, value: 2, to: today) ?? today,
                timeSlot: "18:00-20:00",
                guests: 2,
                status: .pending,
                specialRequests: "У окна, пожалуйста",
                totalPrice: 2500.0,
                paymentStatus: .unpaid,
                clientName: "Анна Петрова",
                clientPhone: "+7 (999) 123-45-67",
                clientEmail: "anna@example.com",
                createdAt: Date(),
                updatedAt: Date()
            ),
            Booking(
                restaurantId: "demo-restaurant",
                clientId: "client2",
                tableId: "table2",
                date: calendar.date(byAdding: .day, value: 1, to: today) ?? today,
                timeSlot: "20:00-22:00",
                guests: 4,
                status: .confirmed,
                specialRequests: "День рождения",
                totalPrice: 5000.0,
                paymentStatus: .paid,
                clientName: "Михаил Иванов",
                clientPhone: "+7 (999) 987-65-43",
                clientEmail: "mikhail@example.com",
                createdAt: Date(),
                updatedAt: Date()
            ),
            Booking(
                restaurantId: "demo-restaurant",
                clientId: "client3",
                tableId: "table3",
                date: calendar.date(byAdding: .day, value: -1, to: today) ?? today,
                timeSlot: "19:00-21:00",
                guests: 6,
                status: .completed,
                specialRequests: nil,
                totalPrice: 7500.0,
                paymentStatus: .paid,
                clientName: "Елена Соколова",
                clientPhone: "+7 (999) 555-12-34",
                clientEmail: "elena@example.com",
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }
    
    func fetchBookings(for restaurantId: String) async throws -> [Booking] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return mockBookings
    }
    
    func createBooking(_ booking: Booking) async throws -> Booking {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        var newBooking = booking
        newBooking.id = UUID().uuidString
        mockBookings.append(newBooking)
        
        subject.send(mockBookings)
        return newBooking
    }
    
    func updateBooking(_ booking: Booking) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        if let index = mockBookings.firstIndex(where: { $0.id == booking.id }) {
            mockBookings[index] = booking
            subject.send(mockBookings)
        }
    }
    
    func deleteBooking(_ booking: Booking) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        mockBookings.removeAll { $0.id == booking.id }
        subject.send(mockBookings)
    }
    
    func updateBookingStatus(_ bookingId: String, status: BookingStatus, restaurantId: String) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        if let index = mockBookings.firstIndex(where: { $0.id == bookingId }) {
            mockBookings[index].status = status
            mockBookings[index].updatedAt = Date()
            subject.send(mockBookings)
        }
    }
    
    func observeBookings(for restaurantId: String) -> AnyPublisher<[Booking], Error> {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.subject.send(self.mockBookings)
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func getBookingAnalytics(for restaurantId: String) async throws -> [String: Any] {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let confirmed = mockBookings.filter { $0.status == .confirmed }.count
        let cancelled = mockBookings.filter { $0.status == .cancelled }.count
        let noShow = mockBookings.filter { $0.status == .noShow }.count
        let avgPartySize = mockBookings.isEmpty ? 0.0 : Double(mockBookings.reduce(0) { $0 + $1.guests }) / Double(mockBookings.count)
        let revenue = mockBookings.filter { $0.paymentStatus == .paid }.reduce(0.0) { $0 + $1.totalPrice }
        
        return [
            "totalBookings": mockBookings.count,
            "confirmedBookings": confirmed,
            "cancelledBookings": cancelled,
            "noShowBookings": noShow,
            "averagePartySize": avgPartySize,
            "totalRevenue": revenue,
            "popularTimeSlots": ["18:00-20:00": 5, "20:00-22:00": 3],
            "popularTables": ["VIP-1": 8, "Стол 1": 6, "Терраса 1": 4]
        ] as [String: Any]
    }
}

// MARK: - Notification Type
enum BookingNotificationType: String {
    case newBooking = "new_booking"
    case bookingConfirmed = "booking_confirmed"
    case bookingCancelled = "booking_cancelled"
    case reminderBooking = "reminder_booking"
}
