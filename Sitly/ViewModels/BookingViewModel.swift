import Foundation
import SwiftUI

@MainActor
final class BookingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedDate = Date()
    @Published var selectedTime = ""
    @Published var guestCount = 2
    @Published var selectedTable = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showConfirmation = false
    @Published var showSuccess = false
    @Published var isBooking = false
    
    // MARK: - Private Properties
    private let restaurant: Restaurant
    private let bookingUseCase: BookingUseCaseProtocol
    
    // MARK: - Computed Properties
    var availableTimes: [String] {
        return ["12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00"]
    }
    
    var availableTables: [String] {
        return ["Столик у окна", "VIP-столик", "Столик в центре", "Балкон", "Терраса"]
    }
    
    // MARK: - Initialization
    init(restaurant: Restaurant, bookingUseCase: BookingUseCaseProtocol) {
        self.restaurant = restaurant
        self.bookingUseCase = bookingUseCase
    }
    
    // MARK: - Public Methods
    
    func createBooking() async {
        guard !selectedTime.isEmpty else {
            errorMessage = "Выберите время"
            return
        }
        
        guard !selectedTable.isEmpty else {
            errorMessage = "Выберите тип столика"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Проверяем доступность
            let isAvailable = try await bookingUseCase.checkAvailability(
                restaurantId: restaurant.id,
                date: selectedDate,
                time: selectedTime
            )
            
            guard isAvailable else {
                errorMessage = "Выбранное время недоступно. Попробуйте другое время."
                isLoading = false
                return
            }
            
            // Создаём бронирование
            _ = try await bookingUseCase.createBooking(
                restaurantId: restaurant.id,
                userId: "current-user-id", // В реальном приложении здесь был бы ID текущего пользователя
                date: selectedDate,
                time: selectedTime,
                guestCount: guestCount,
                tableType: TableType(rawValue: selectedTable) ?? .standard,
                specialRequests: nil,
                contactPhone: "+7 (999) 123-45-67" // Временно
            )
            
            isLoading = false
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func incrementGuestCount() {
        if guestCount < 10 {
            guestCount += 1
        }
    }
    
    func decrementGuestCount() {
        if guestCount > 1 {
            guestCount -= 1
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    func formatTime(_ time: String) -> String {
        return time
    }
} 