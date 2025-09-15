import Foundation

final class BookingRepository: BookingRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let storageService: StorageServiceProtocol
    
    init(networkService: NetworkServiceProtocol, storageService: StorageServiceProtocol) {
        self.networkService = networkService
        self.storageService = storageService
    }
    
    // MARK: - Booking Management
    
    func createBooking(_ booking: Booking) async throws -> Booking {
        // В реальном приложении здесь был бы API вызов
        // Пока что сохраняем локально
        
        // Генерируем уникальный ID для бронирования
        var newBooking = booking
        newBooking.id = UUID().uuidString        
        // Сохраняем в локальное хранилище
        try await storageService.save(newBooking, forKey: "booking_\(newBooking.id)")
        
        // Добавляем в список бронирований пользователя
        var userBookings = try await fetchUserBookings(userId: booking.clientId)
        userBookings.append(newBooking)
        try await storageService.save(userBookings, forKey: "user_bookings_\(booking.clientId)")
        
        // Добавляем в список бронирований ресторана
        var restaurantBookings = try await fetchRestaurantBookings(restaurantId: booking.restaurantId)
        restaurantBookings.append(newBooking)
        try await storageService.save(restaurantBookings, forKey: "restaurant_bookings_\(booking.restaurantId)")
        
        return newBooking
    }
    
    func fetchUserBookings(userId: String) async throws -> [Booking] {
        // Получаем из локального хранилища
        if let bookings: [Booking] = try? await storageService.load([Booking].self, forKey: "user_bookings_\(userId)") {
            return bookings
        }
        
        // Если нет сохраненных бронирований, возвращаем пустой массив
        return []
    }
    
    func fetchRestaurantBookings(restaurantId: String) async throws -> [Booking] {
        // Получаем из локального хранилища
        if let bookings: [Booking] = try? await storageService.load([Booking].self, forKey: "restaurant_bookings_\(restaurantId)") {
            return bookings
        }
        
        // Если нет сохраненных бронирований, возвращаем пустой массив
        return []
    }
    
    func updateBookingStatus(bookingId: String, status: BookingStatus) async throws -> Booking {
        // Получаем все бронирования пользователя
        let userBookings = try await getAllBookings()
        
        guard let bookingIndex = userBookings.firstIndex(where: { $0.id == bookingId }) else {
            throw RepositoryError.notFound
        }
        
        // Обновляем статус
        var updatedBooking = userBookings[bookingIndex]
        updatedBooking.status = status
        updatedBooking.updatedAt = Date()
        
        // Обновляем в локальном хранилище
        try await storageService.save(updatedBooking, forKey: "booking_\(bookingId)")
        
        // Обновляем в списках пользователя и ресторана
        try await updateBookingInLists(updatedBooking)
        
        return updatedBooking
    }
    
    func cancelBooking(bookingId: String) async throws -> Booking {
        // Отмена - это изменение статуса на cancelled
        return try await updateBookingStatus(bookingId: bookingId, status: .cancelled)
    }
    
    func checkAvailability(restaurantId: String, date: Date, time: String) async throws -> Bool {
        // Получаем все бронирования ресторана на указанную дату
        let restaurantBookings = try await fetchRestaurantBookings(restaurantId: restaurantId)
        
        let calendar = Calendar.current
        
        // Фильтруем бронирования на указанную дату и время
        let conflictingBookings = restaurantBookings.filter { booking in
            calendar.isDate(booking.date, inSameDayAs: date) && 
            booking.timeSlot.contains(time) &&
            (booking.status == .pending || booking.status == .confirmed)
        }
        
        // Предполагаем, что ресторан может обслужить максимум 50 гостей одновременно
        let maxCapacity = 50
        let totalGuests = conflictingBookings.reduce(0) { $0 + $1.guests }
        
        return totalGuests < maxCapacity
    }
    
    // MARK: - Private Methods
    
    private func getAllBookings() async throws -> [Booking] {
        // Получаем все ключи из хранилища
        // Вместо getAllKeys используем известные ключи или кэш
        // Упрощенная версия для MVP
        // В реальном приложении здесь была бы загрузка всех бронирований
        return []
    }
    
    private func updateBookingInLists(_ booking: Booking) async throws {
        // Обновляем в списке пользователя
        var userBookings = try await fetchUserBookings(userId: booking.clientId)
        if let index = userBookings.firstIndex(where: { $0.id == booking.id }) {
            userBookings[index] = booking
            try await storageService.save(userBookings, forKey: "user_bookings_\(booking.clientId)")
        }
        
        // Обновляем в списке ресторана
        var restaurantBookings = try await fetchRestaurantBookings(restaurantId: booking.restaurantId)
        if let index = restaurantBookings.firstIndex(where: { $0.id == booking.id }) {
            restaurantBookings[index] = booking
            try await storageService.save(restaurantBookings, forKey: "restaurant_bookings_\(booking.restaurantId)")
        }
    }
}
