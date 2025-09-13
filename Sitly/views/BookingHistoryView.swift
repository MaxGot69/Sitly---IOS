import SwiftUI

struct BookingHistoryView: View {
    @StateObject private var viewModel: BookingHistoryViewModel
    @State private var animateContent = false
    @State private var selectedFilter: BookingFilter = .all
    
    init() {
        let container = DependencyContainer.shared
        self._viewModel = StateObject(wrappedValue: BookingHistoryViewModel(
            bookingUseCase: container.bookingUseCase,
            restaurantUseCase: container.restaurantUseCase
        ))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Темный фон с градиентом
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.05, green: 0.05, blue: 0.08),
                        Color(red: 0.02, green: 0.02, blue: 0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Заголовок
                    headerSection
                    
                    // Фильтры
                    filterSection
                    
                    // Контент
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.filteredBookingModels.isEmpty {
                        emptyStateView
                    } else {
                        bookingsListView
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            startAnimations()
            Task {
                await viewModel.loadBookingModels()
            }
        }
        .refreshable {
            await viewModel.refreshBookingModels()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Мои бронирования")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                
                Spacer()
                
                // Статистика
                if !viewModel.bookings.isEmpty {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(viewModel.bookings.count)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("всего броней")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .animation(.easeOut(duration: 0.8).delay(0.1), value: animateContent)
    }
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(BookingFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.displayName,
                        isSelected: selectedFilter == filter,
                        action: {
                            selectedFilter = filter
                            viewModel.filterBookingModels(by: filter)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.easeOut(duration: 0.8).delay(0.3), value: animateContent)
    }
    
    // MARK: - Content Views
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ForEach(0..<3, id: \.self) { _ in
                BookingCardSkeleton()
            }
        }
        .padding(.horizontal, 20)
        .frame(maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange.opacity(0.6), .pink.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            VStack(spacing: 12) {
                Text(selectedFilter == .all ? "Пока нет бронирований" : "Нет бронирований в этой категории")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(selectedFilter == .all ? 
                     "Найдите идеальный ресторан и забронируйте столик" :
                     "Попробуйте изменить фильтр или создать новое бронирование")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if selectedFilter == .all {
                Button("Найти ресторан") {
                    // Навигация к списку ресторанов
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing))
                )
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 40)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.5), value: animateContent)
    }
    
    private var bookingsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(viewModel.filteredBookingModels.enumerated()), id: \.element.id) { index, booking in
                    BookingCard(booking: booking, restaurant: viewModel.getRestaurant(for: booking))
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1 + 0.5), value: animateContent)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Helper Methods
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.8)) {
            animateContent = true
        }
    }
}

// MARK: - Supporting Views

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? 
                              LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing) :
                              LinearGradient(colors: [.clear, .clear], startPoint: .leading, endPoint: .trailing)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
}

struct BookingCard: View {
    let booking: BookingModel
    let restaurant: Restaurant?
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок с рестораном
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant?.name ?? "Неизвестный ресторан")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(restaurant?.cuisineType.displayName ?? "Кухня")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Статус
                StatusBadge(status: booking.status)
            }
            
            // Детали бронирования
            VStack(spacing: 12) {
                BookingModelDetailRow(
                    icon: "calendar",
                    title: "Дата",
                    value: formatDate(booking.date)
                )
                
                BookingModelDetailRow(
                    icon: "clock",
                    title: "Время",
                    value: booking.timeSlot
                )
                
                BookingModelDetailRow(
                    icon: "person.2",
                    title: "Гостей",
                    value: "\(booking.guests) чел."
                )
                
                BookingModelDetailRow(
                    icon: "chair.lounge",
                    title: "Столик",
                    value: booking.tableName
                )
            }
            
            // Специальные пожелания
            if let requests = booking.specialRequests, !requests.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Пожелания:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Text(requests)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.05))
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                // Здесь будет навигация к деталям бронирования
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

struct BookingModelDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.orange)
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

struct StatusBadge: View {
    let status: BookingStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(status.statusGradient)
            )
    }
}

struct BookingCardSkeleton: View {
    @State private var animateGradient = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    SkeletonLine(width: 150, height: 18)
                    SkeletonLine(width: 100, height: 14)
                }
                
                Spacer()
                
                SkeletonLine(width: 80, height: 24, cornerRadius: 12)
            }
            
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack {
                        SkeletonLine(width: 20, height: 14)
                        SkeletonLine(width: 60, height: 14)
                        Spacer()
                        SkeletonLine(width: 80, height: 14)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct SkeletonLine: View {
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    @State private var animateGradient = false
    
    init(width: CGFloat, height: CGFloat, cornerRadius: CGFloat = 4) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [.gray.opacity(0.3), .gray.opacity(0.1), .gray.opacity(0.3)],
                    startPoint: animateGradient ? .leading : .trailing,
                    endPoint: animateGradient ? .trailing : .leading
                )
            )
            .frame(width: width, height: height)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: animateGradient)
            .onAppear { animateGradient.toggle() }
    }
}

// MARK: - Enums and Models

enum BookingFilter: CaseIterable {
    case all
    case upcoming
    case completed
    case cancelled
    
    var displayName: String {
        switch self {
        case .all: return "Все"
        case .upcoming: return "Предстоящие"
        case .completed: return "Завершенные"
        case .cancelled: return "Отмененные"
        }
    }
}

extension BookingStatus {
    var statusGradient: LinearGradient {
        switch self {
        case .pending:
            return LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
        case .confirmed:
            return LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
        case .completed:
            return LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
        case .cancelled:
            return LinearGradient(colors: [.red, .pink], startPoint: .leading, endPoint: .trailing)
        case .noShow:
            return LinearGradient(colors: [.red.opacity(0.8), .orange], startPoint: .leading, endPoint: .trailing)
        }
    }
}

// MARK: - BookingHistoryViewModel

@MainActor
class BookingHistoryViewModel: ObservableObject {
    @Published var bookings: [BookingModel] = []
    @Published var filteredBookingModels: [BookingModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let bookingUseCase: BookingUseCaseProtocol
    private let restaurantUseCase: RestaurantUseCaseProtocol
    private var restaurants: [Restaurant] = []
    
    init(bookingUseCase: BookingUseCaseProtocol, restaurantUseCase: RestaurantUseCaseProtocol) {
        self.bookingUseCase = bookingUseCase
        self.restaurantUseCase = restaurantUseCase
    }
    
    func loadBookingModels() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Загружаем рестораны для отображения названий
            restaurants = try await restaurantUseCase.getRestaurants()
            
            // Здесь будет загрузка реальных бронирований
            // Пока используем демо данные
            bookings = getMockBookingModels()
            filteredBookingModels = bookings
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refreshBookingModels() async {
        await loadBookingModels()
    }
    
    func filterBookingModels(by filter: BookingFilter) {
        switch filter {
        case .all:
            filteredBookingModels = bookings
        case .upcoming:
            filteredBookingModels = bookings.filter { booking in
                booking.date > Date() && (booking.status == .pending || booking.status == .confirmed)
            }
        case .completed:
            filteredBookingModels = bookings.filter { $0.status == .completed }
        case .cancelled:
            filteredBookingModels = bookings.filter { $0.status == .cancelled }
        }
    }
    
    func getRestaurant(for booking: BookingModel) -> Restaurant? {
        // Restaurant.id и booking.restaurantId оба String
        return restaurants.first { $0.id == booking.restaurantId }
    }
    
    private func getMockBookingModels() -> [BookingModel] {
        // Моки отключены. Используем реальные данные из UseCase.
        return []
    }
}

#Preview {
    BookingHistoryView()
}
