import Foundation
import SwiftUI

// MARK: - Booking Status
enum BookingStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case cancelled = "cancelled"
    case completed = "completed"
    case noShow = "no_show"
}

// MARK: - Payment Status
enum PaymentStatus: String, CaseIterable, Codable {
    case unpaid = "unpaid"
    case paid = "paid"
    case refunded = "refunded"
}

// MARK: - Table Type (compatibility)
enum TableType: String, CaseIterable, Codable {
    case standard = "standard"
    case indoor = "indoor"
    case vip = "vip"
    case outdoor = "outdoor"
    case bar = "bar"
}

// MARK: - Booking Model
struct BookingModel: Identifiable, Codable {
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
    let clientEmail: String

    // Table info
    let tableName: String
    let tableCapacity: Int

    // Timestamps
    var createdAt: Date
    var updatedAt: Date
}

// MARK: - Compatibility
// Many parts of the code still refer to `Booking`. Keep a typealias for seamless migration.
typealias Booking = BookingModel

// MARK: - Analytics
struct BookingAnalytics: Codable {
    let totalBookings: Int
    let confirmedBookings: Int
    let cancelledBookings: Int
    let noShowBookings: Int
    let averagePartySize: Double
    let totalRevenue: Double
    let popularTimeSlots: [String: Int]
    let popularTables: [String: Int]

    init() {
        self.totalBookings = 0
        self.confirmedBookings = 0
        self.cancelledBookings = 0
        self.noShowBookings = 0
        self.averagePartySize = 0.0
        self.totalRevenue = 0.0
        self.popularTimeSlots = [:]
        self.popularTables = [:]
    }

    init(
        totalBookings: Int,
        confirmedBookings: Int,
        cancelledBookings: Int,
        noShowBookings: Int,
        averagePartySize: Double,
        totalRevenue: Double,
        popularTimeSlots: [String: Int],
        popularTables: [String: Int]
    ) {
        self.totalBookings = totalBookings
        self.confirmedBookings = confirmedBookings
        self.cancelledBookings = cancelledBookings
        self.noShowBookings = noShowBookings
        self.averagePartySize = averagePartySize
        self.totalRevenue = totalRevenue
        self.popularTimeSlots = popularTimeSlots
        self.popularTables = popularTables
    }
}

// MARK: - Formatting helpers used in UI/Logs
extension BookingModel {
    var formattedDate: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: date)
    }
    
    // Business rules for UI actions
    var canBeConfirmed: Bool { status == .pending }
    var canBeCancelled: Bool { status == .pending || status == .confirmed }
}

// MARK: - UI helpers for status
extension BookingStatus {
    var displayName: String {
        switch self {
        case .pending: return "Ожидает"
        case .confirmed: return "Подтверждено"
        case .cancelled: return "Отменено"
        case .completed: return "Завершено"
        case .noShow: return "Не пришел"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .confirmed: return .green
        case .cancelled: return .red
        case .completed: return .blue
        case .noShow: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .noShow: return "person.fill.questionmark"
        }
    }
}

extension PaymentStatus {
    var displayName: String {
        switch self {
        case .unpaid: return "Не оплачен"
        case .paid: return "Оплачен"
        case .refunded: return "Возврат"
        }
    }
    
    var color: Color {
        switch self {
        case .unpaid: return .orange
        case .paid: return .green
        case .refunded: return .blue
        }
    }
}


