//
//  BookingsViewModel.swift
//  Sitly
//
//  Created by AI Assistant on 12.09.2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class BookingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var bookings: [BookingModel] = []
    @Published var filteredBookings: [BookingModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let bookingsService: BookingsServiceProtocol
    private let restaurantId: String
    private var cancellables = Set<AnyCancellable>()
    private var currentFilter: RestaurantBookingFilter = .all
    
    // MARK: - Computed Properties
    var todayBookings: Int {
        bookings.filter { Calendar.current.isDateInToday($0.date) }.count
    }
    
    var pendingBookings: Int {
        bookings.filter { $0.status == .pending }.count
    }
    
    var confirmedBookings: Int {
        bookings.filter { $0.status == .confirmed }.count
    }
    
    var totalRevenue: Double {
        bookings.filter { $0.paymentStatus == .paid }.reduce(0.0) { $0 + $1.totalPrice }
    }
    
    // MARK: - Initialization
    init(restaurantId: String = "demo-restaurant", bookingsService: BookingsServiceProtocol? = nil) {
        self.restaurantId = restaurantId
        self.bookingsService = bookingsService ?? MockBookingsService() // Используем Mock для разработки
        
        setupRealTimeObserver()
        Task {
            await loadBookings()
        }
    }
    
    // MARK: - Real-time Observer
    private func setupRealTimeObserver() {
        bookingsService.observeBookings(for: restaurantId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                        print("❌ Ошибка наблюдения за бронированиями: \(error)")
                    }
                },
                receiveValue: { bookings in
                    self.bookings = bookings.sorted { $0.date < $1.date }
                    self.filterBookings(by: self.currentFilter)
                    self.isLoading = false
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Load Bookings
    func loadBookings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedBookings = try await bookingsService.fetchBookings(for: restaurantId)
            self.bookings = fetchedBookings.sorted { $0.date < $1.date }
            self.filterBookings(by: currentFilter)
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            print("❌ Ошибка загрузки бронирований: \(error)")
        }
    }
    
    // MARK: - Filter Bookings
    func filterBookings(by filter: RestaurantBookingFilter) {
        currentFilter = filter
        
        switch filter {
        case .all:
            filteredBookings = bookings
        case .pending:
            filteredBookings = bookings.filter { $0.status == .pending }
        case .confirmed:
            filteredBookings = bookings.filter { $0.status == .confirmed }
        case .today:
            filteredBookings = bookings.filter { Calendar.current.isDateInToday($0.date) }
        case .cancelled:
            filteredBookings = bookings.filter { $0.status == .cancelled }
        case .completed:
            filteredBookings = bookings.filter { $0.status == .completed }
        }
        
        print("🔍 Фильтр \(filter.displayName): найдено \(filteredBookings.count) бронирований")
    }
    
    // MARK: - Update Booking Status
    func updateBookingStatus(_ bookingId: String, status: BookingStatus) async {
        do {
            try await bookingsService.updateBookingStatus(bookingId, status: status, restaurantId: restaurantId)
            HapticService.shared.notification(.success)
            print("✅ Статус бронирования обновлен на \(status.displayName)")
        } catch {
            self.errorMessage = error.localizedDescription
            HapticService.shared.notification(.error)
            print("❌ Ошибка обновления статуса: \(error)")
        }
    }
    
    // MARK: - Create Booking
    func createBooking(_ booking: BookingModel) async {
        do {
            let createdBooking = try await bookingsService.createBooking(booking)
            HapticService.shared.notification(.success)
            print("✅ Бронирование создано: \(createdBooking.id)")
        } catch {
            self.errorMessage = error.localizedDescription
            HapticService.shared.notification(.error)
            print("❌ Ошибка создания бронирования: \(error)")
        }
    }
    
    // MARK: - Update Booking
    func updateBooking(_ booking: BookingModel) async {
        do {
            try await bookingsService.updateBooking(booking)
            HapticService.shared.notification(.success)
            print("✅ Бронирование обновлено: \(booking.id)")
        } catch {
            self.errorMessage = error.localizedDescription
            HapticService.shared.notification(.error)
            print("❌ Ошибка обновления бронирования: \(error)")
        }
    }
    
    // MARK: - Delete Booking
    func deleteBooking(_ booking: BookingModel) async {
        do {
            try await bookingsService.deleteBooking(booking)
            HapticService.shared.notification(.success)
            print("✅ Бронирование удалено: \(booking.id)")
        } catch {
            self.errorMessage = error.localizedDescription
            HapticService.shared.notification(.error)
            print("❌ Ошибка удаления бронирования: \(error)")
        }
    }
    
    // MARK: - Get Analytics
    func getAnalytics() async -> BookingAnalytics? {
        do {
            let analytics = try await bookingsService.getBookingAnalytics(for: restaurantId)
            print("📊 Аналитика загружена: \(analytics.totalBookings) бронирований")
            return analytics
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Ошибка загрузки аналитики: \(error)")
            return nil
        }
    }
    
    // MARK: - Helper Methods
    func getBookingsForDate(_ date: Date) -> [BookingModel] {
        return bookings.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func getBookingsForTimeSlot(_ timeSlot: String, date: Date) -> [BookingModel] {
        return bookings.filter { 
            $0.timeSlot == timeSlot && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    func isTableAvailable(tableId: String, date: Date, timeSlot: String) -> Bool {
        let conflictingBookings = bookings.filter { booking in
            booking.tableId == tableId &&
            Calendar.current.isDate(booking.date, inSameDayAs: date) &&
            booking.timeSlot == timeSlot &&
            (booking.status == .confirmed || booking.status == .pending)
        }
        return conflictingBookings.isEmpty
    }
    
    // MARK: - Cleanup
    deinit {
        cancellables.removeAll()
        print("🧹 BookingsViewModel очищен")
    }
}
