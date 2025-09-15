//
//  Booking.swift
//  Sitly
//
//  Created by AI Assistant on 12.09.2025.
//

import Foundation

// MARK: - Booking Status

enum BookingStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case cancelled = "cancelled"
    case completed = "completed"
    case noShow = "no_show"
    
    var displayName: String {
        switch self {
        case .pending: return "Ожидает подтверждения"
        case .confirmed: return "Подтверждено"
        case .cancelled: return "Отменено"
        case .completed: return "Завершено"
        case .noShow: return "Не явился"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .confirmed: return "green"
        case .cancelled: return "red"
        case .completed: return "blue"
        case .noShow: return "gray"
        }
    }
}

// MARK: - Payment Status

enum PaymentStatus: String, CaseIterable, Codable {
    case unpaid = "unpaid"
    case paid = "paid"
    case refunded = "refunded"
    case pending = "pending"
    
    var displayName: String {
        switch self {
        case .unpaid: return "Не оплачено"
        case .paid: return "Оплачено"
        case .refunded: return "Возвращено"
        case .pending: return "Ожидает оплаты"
        }
    }
}

// MARK: - Table Type

enum TableType: String, CaseIterable, Codable {
    case standard = "standard"
    case indoor = "indoor"
    case vip = "vip"
    case outdoor = "outdoor"
    case bar = "bar"
    
    var displayName: String {
        switch self {
        case .standard: return "Стандартный"
        case .indoor: return "Внутренний"
        case .vip: return "VIP"
        case .outdoor: return "На улице"
        case .bar: return "Бар"
        }
    }
}

// MARK: - Booking Model

struct Booking: Identifiable, Codable, Equatable {
    // Identifiers
    var id: String = UUID().uuidString
    let restaurantId: String
    let clientId: String
    let tableId: String

    // Timing
    let date: Date
    let timeSlot: String // e.g. "18:00-20:00"

    // Party
    let guests: Int
    var status: BookingStatus
    let specialRequests: String?

    // Pricing & Payment
    let totalPrice: Double
    var paymentStatus: PaymentStatus

    // Client info
    let clientName: String
    let clientPhone: String
    let clientEmail: String?

    // Timestamps
    let createdAt: Date
    var updatedAt: Date

    // MARK: - Initializers

    init(
        id: String = UUID().uuidString,
        restaurantId: String,
        clientId: String,
        tableId: String,
        date: Date,
        timeSlot: String,
        guests: Int,
        status: BookingStatus = .pending,
        specialRequests: String? = nil,
        totalPrice: Double,
        paymentStatus: PaymentStatus = .unpaid,
        clientName: String,
        clientPhone: String,
        clientEmail: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.restaurantId = restaurantId
        self.clientId = clientId
        self.tableId = tableId
        self.date = date
        self.timeSlot = timeSlot
        self.guests = guests
        self.status = status
        self.specialRequests = specialRequests
        self.totalPrice = totalPrice
        self.paymentStatus = paymentStatus
        self.clientName = clientName
        self.clientPhone = clientPhone
        self.clientEmail = clientEmail
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Mock Data

extension Booking {
    static let mockBookings: [Booking] = [
        Booking(
            restaurantId: "rest1",
            clientId: "client1",
            tableId: "table1",
            date: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
            timeSlot: "18:00-20:00",
            guests: 4,
            status: .pending,
            specialRequests: "Столик у окна",
            totalPrice: 2500.0,
            paymentStatus: .unpaid,
            clientName: "Иван Петров",
            clientPhone: "+7 (999) 123-45-67",
            clientEmail: "ivan@example.com"
        ),
        Booking(
            restaurantId: "rest1",
            clientId: "client2",
            tableId: "table2",
            date: Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date(),
            timeSlot: "20:00-22:00",
            guests: 2,
            status: .confirmed,
            specialRequests: nil,
            totalPrice: 1800.0,
            paymentStatus: .paid,
            clientName: "Мария Сидорова",
            clientPhone: "+7 (999) 765-43-21",
            clientEmail: "maria@example.com"
        ),
        Booking(
            restaurantId: "rest1",
            clientId: "client3",
            tableId: "table3",
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            timeSlot: "19:00-21:00",
            guests: 6,
            status: .confirmed,
            specialRequests: "Детский стульчик",
            totalPrice: 3200.0,
            paymentStatus: .paid,
            clientName: "Алексей Козлов",
            clientPhone: "+7 (999) 555-77-99",
            clientEmail: "alex@example.com"
        )
    ]
}

