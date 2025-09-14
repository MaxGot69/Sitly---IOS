import Foundation
import SwiftUI
import Combine

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
    @Published var availableTables: [TableModel] = []
    @Published var isLoadingTables = false
    
    // MARK: - Private Properties
    private let restaurant: Restaurant
    private let bookingUseCase: BookingUseCaseProtocol
    private let tablesService: TablesServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var availableTimes: [String] {
        return ["12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00"]
    }
    
    var availableTableNames: [String] {
        return availableTables.map { $0.name }
    }
    
    // MARK: - Initialization
    init(restaurant: Restaurant, bookingUseCase: BookingUseCaseProtocol, tablesService: TablesServiceProtocol = TablesService()) {
        self.restaurant = restaurant
        self.bookingUseCase = bookingUseCase
        self.tablesService = tablesService
        
        setupBindings()
        loadTables()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Подписываемся на изменения столиков в реальном времени
        tablesService.observeTables(for: restaurant.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Ошибка загрузки столиков: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] tables in
                    self?.availableTables = tables.filter { $0.status == .available }
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadTables() {
        Task {
            await loadTablesAsync()
        }
    }
    
    private func loadTablesAsync() async {
        isLoadingTables = true
        errorMessage = nil
        
        do {
            let tables = try await tablesService.fetchTables(for: restaurant.id)
            availableTables = tables.filter { $0.status == .available }
            print("✅ Загружено столиков: \(availableTables.count)")
        } catch {
            errorMessage = "Ошибка загрузки столиков: \(error.localizedDescription)"
            print("❌ Ошибка загрузки столиков: \(error)")
        }
        
        isLoadingTables = false
    }
    
    // MARK: - Public Methods
    
    func createBooking() async {
        guard !selectedTime.isEmpty else {
            errorMessage = "Выберите время"
            return
        }
        
        guard !selectedTable.isEmpty else {
            errorMessage = "Выберите столик"
            return
        }
        
        // Находим выбранный столик
        guard let selectedTableModel = availableTables.first(where: { $0.name == selectedTable }) else {
            errorMessage = "Выбранный столик недоступен"
            return
        }
        
        // Проверяем вместимость столика
        guard selectedTableModel.capacity >= guestCount else {
            errorMessage = "Столик вмещает максимум \(selectedTableModel.capacity) гостей"
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
            
            // Создаём бронирование с реальным ID столика
            _ = try await bookingUseCase.createBooking(
                restaurantId: restaurant.id,
                userId: "current-user-id", // В реальном приложении здесь был бы ID текущего пользователя
                date: selectedDate,
                time: selectedTime,
                guestCount: guestCount,
                tableType: convertTableType(selectedTableModel.type),
                specialRequests: nil,
                contactPhone: "+7 (999) 123-45-67" // Временно
            )
            
            isLoading = false
            showSuccess = true
            print("✅ Бронирование создано для столика: \(selectedTableModel.name)")
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("❌ Ошибка создания бронирования: \(error)")
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
    
    // MARK: - Private Helper Methods
    private func convertTableType(_ tableType: TableModel.TableTypeEnum) -> TableType {
        switch tableType {
        case .indoor:
            return .indoor
        case .outdoor:
            return .outdoor
        case .bar:
            return .bar
        case .vip:
            return .vip
        }
    }
} 