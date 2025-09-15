import Foundation

final class BookingUseCase: BookingUseCaseProtocol {
    private let repository: BookingRepositoryProtocol
    private let restaurantRepository: RestaurantRepositoryProtocol
    
    init(repository: BookingRepositoryProtocol, restaurantRepository: RestaurantRepositoryProtocol) {
        self.repository = repository
        self.restaurantRepository = restaurantRepository
    }
    
    // MARK: - Booking Methods
    
    func createBooking(
        restaurantId: String,
        userId: String,
        date: Date,
        time: String,
        guestCount: Int,
        tableType: TableType,
        specialRequests: String?,
        contactPhone: String
    ) async throws -> Booking {
        // Валидация данных бронирования
        guard date > Date() else {
            throw UseCaseError.businessLogicError("Дата бронирования должна быть в будущем")
        }
        
        guard guestCount > 0 && guestCount <= 20 else {
            throw UseCaseError.businessLogicError("Количество гостей должно быть от 1 до 20")
        }
        
        guard isValidTime(time) else {
            throw UseCaseError.businessLogicError("Некорректное время бронирования")
        }
        
        // Проверяем доступность
        let isAvailable = try await checkAvailability(
            restaurantId: restaurantId,
            date: date,
            time: time
        )
        
        guard isAvailable else {
            throw UseCaseError.businessLogicError("К сожалению, на это время нет свободных столов")
        }
        
        // Проверяем, что ресторан существует
        let restaurant = try await restaurantRepository.fetchRestaurant(by: restaurantId)
        guard restaurant.isOpen else {
            throw UseCaseError.businessLogicError("Ресторан закрыт")
        }
        
        // Проверяем рабочее время
        guard isWithinWorkingHours(restaurant: restaurant, date: date, time: time) else {
            throw UseCaseError.businessLogicError("Выбранное время вне рабочего времени ресторана")
        }
        
        // Создаем бронирование
        let booking = Booking(
            restaurantId: restaurantId,
            clientId: userId,
            tableId: "auto-assigned",
            date: date,
            timeSlot: "\(time)-\(time)",
            guests: guestCount,
            status: .pending,
            specialRequests: specialRequests,
            totalPrice: 0.0,
            paymentStatus: .unpaid,
            clientName: "Клиент",
            clientPhone: contactPhone,
            clientEmail: "client@example.com",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            let createdBooking = try await repository.createBooking(booking)
            
            // В реальном приложении здесь можно добавить:
            // - Отправку уведомления пользователю
            // - Отправку уведомления ресторану
            // - Обновление статистики
            
            return createdBooking
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    func getUserBookings(userId: String) async throws -> [Booking] {
        do {
            let bookings = try await repository.fetchUserBookings(userId: userId)
            
            // Сортируем по дате (ближайшие сначала)
            return bookings.sorted { $0.date < $1.date }
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    func getRestaurantBookings(restaurantId: String) async throws -> [Booking] {
        do {
            let bookings = try await repository.fetchRestaurantBookings(restaurantId: restaurantId)
            
            // Сортируем по дате (ближайшие сначала)
            return bookings.sorted { $0.date < $1.date }
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    func updateBookingStatus(bookingId: String, status: BookingStatus) async throws -> Booking {
        do {
            let updatedBooking = try await repository.updateBookingStatus(bookingId: bookingId, status: status)
            
            // В реальном приложении здесь можно добавить:
            // - Отправку уведомления пользователю об изменении статуса
            // - Логирование изменений
            // - Обновление статистики
            
            return updatedBooking
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    func cancelBooking(bookingId: String) async throws -> Booking {
        do {
            let cancelledBooking = try await repository.cancelBooking(bookingId: bookingId)
            
            // В реальном приложении здесь можно добавить:
            // - Отправку уведомления пользователю об отмене
            // - Отправку уведомления ресторану
            // - Обновление статистики
            // - Возврат средств (если была предоплата)
            
            return cancelledBooking
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    func checkAvailability(restaurantId: String, date: Date, time: String) async throws -> Bool {
        do {
            return try await repository.checkAvailability(restaurantId: restaurantId, date: date, time: time)
        } catch {
            throw UseCaseError.repositoryError(.networkError(error))
        }
    }
    
    // MARK: - Additional Booking Methods
    
    func getUpcomingBookings(userId: String) async throws -> [Booking] {
        let allBookings = try await getUserBookings(userId: userId)
        
        // Фильтруем только предстоящие бронирования
        let upcomingBookings = allBookings.filter { booking in
            booking.date > Date() && 
            (booking.status == .pending || booking.status == .confirmed)
        }
        
        return upcomingBookings.sorted { $0.date < $1.date }
    }
    
    func getPastBookings(userId: String) async throws -> [Booking] {
        let allBookings = try await getUserBookings(userId: userId)
        
        // Фильтруем только завершенные бронирования
        let pastBookings = allBookings.filter { booking in
            booking.date < Date() || 
            (booking.status == .completed || booking.status == .cancelled)
        }
        
        return pastBookings.sorted { $0.date > $1.date }
    }
    
    func getBookingsByStatus(userId: String, status: BookingStatus) async throws -> [Booking] {
        let allBookings = try await getUserBookings(userId: userId)
        return allBookings.filter { $0.status == status }
    }
    
    func getBookingsForDate(userId: String, date: Date) async throws -> [Booking] {
        let allBookings = try await getUserBookings(userId: userId)
        
        let calendar = Calendar.current
        return allBookings.filter { booking in
            calendar.isDate(booking.date, inSameDayAs: date)
        }
    }
    
    // MARK: - Business Logic Methods
    
    func canModifyBooking(_ booking: Booking) -> Bool {
        // Проверяем, можно ли изменить бронирование
        guard booking.status == .pending || booking.status == .confirmed else { return false }
        
        // Проверяем, не слишком ли близко время бронирования
        let timeUntilBooking = booking.date.timeIntervalSince(Date())
        let minimumModificationTime: TimeInterval = 3600 // 1 час
        
        return timeUntilBooking > minimumModificationTime
    }
    
    func getAvailableTimeSlots(restaurantId: String, date: Date) async throws -> [String] {
        // В реальном приложении здесь была бы логика получения доступных временных слотов
        // Пока что возвращаем стандартные времена
        let standardTimes = [
            "12:00", "12:30", "13:00", "13:30", "14:00", "14:30",
            "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00"
        ]
        
        // Фильтруем доступные времена
        var availableTimes: [String] = []
        
        for time in standardTimes {
            let isAvailable = try await checkAvailability(
                restaurantId: restaurantId,
                date: date,
                time: time
            )
            
            if isAvailable {
                availableTimes.append(time)
            }
        }
        
        return availableTimes
    }
    
    func getAvailableTableTypes(restaurantId: String, date: Date, time: String) async throws -> [TableType] {
        // В реальном приложении здесь была бы логика получения доступных типов столов
        // Пока что возвращаем все типы
        return TableType.allCases
    }
    
    // MARK: - Private Helper Methods
    
    private func isValidTime(_ time: String) -> Bool {
        let timeRegex = "^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$"
        let timePredicate = NSPredicate(format: "SELF MATCHES %@", timeRegex)
        return timePredicate.evaluate(with: time)
    }
    
    private func isWithinWorkingHours(restaurant: Restaurant, date: Date, time: String) -> Bool {
        // Простая проверка рабочего времени
        // В реальном приложении здесь была бы сложная логика парсинга workHours
        let hour = Int(time.split(separator: ":")[0]) ?? 0
        return hour >= 10 && hour <= 23
    }
    
    private func calculateBookingDuration(guestCount: Int) -> TimeInterval {
        // Расчет продолжительности бронирования на основе количества гостей
        let baseDuration: TimeInterval = 7200 // 2 часа базово
        
        if guestCount <= 2 {
            return baseDuration
        } else if guestCount <= 4 {
            return baseDuration + 1800 // +30 минут
        } else if guestCount <= 6 {
            return baseDuration + 3600 // +1 час
        } else {
            return baseDuration + 5400 // +1.5 часа
        }
    }
}
