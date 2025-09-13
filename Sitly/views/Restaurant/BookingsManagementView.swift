//
//  BookingsManagementView.swift
//  Sitly
//
//  Created by AI Assistant on 12.09.2025.
//

import SwiftUI
import Combine

struct BookingsManagementView: View {
    @StateObject private var viewModel = BookingsViewModel()
    @State private var selectedFilter: RestaurantBookingFilter = .all
    @State private var selectedBooking: BookingModel?
    @State private var showingFilters = false
    @State private var animateCards = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header с фильтрами
                        headerSection
                        
                        // Статистика быстрого обзора
                        quickStatsSection
                        
                        // Список бронирований или loading
                        if viewModel.isLoading && viewModel.bookings.isEmpty {
                            loadingView
                        } else {
                            bookingsListSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .background(Color.clear)
                .navigationBarHidden(true)
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                }
            }
        }
        .sheet(item: $selectedBooking) { booking in
            BookingDetailView(booking: booking, viewModel: viewModel)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                animateCards = true
            }
        }
        .refreshable {
            await viewModel.loadBookings()
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Бронирования")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(viewModel.filteredBookings.count) записей")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Фильтр кнопка
            Button(action: {
                showingFilters.toggle()
                HapticService.shared.buttonPress()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(.title3)
                    
                    Text(selectedFilter.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }
    
    private var quickStatsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            quickStatCard(
                title: "Сегодня",
                value: "\(viewModel.todayBookings)",
                color: .blue,
                icon: "calendar.circle.fill"
            )
            
            quickStatCard(
                title: "Ожидают",
                value: "\(viewModel.pendingBookings)",
                color: .orange,
                icon: "clock.fill"
            )
            
            quickStatCard(
                title: "Подтвержд.",
                value: "\(viewModel.confirmedBookings)",
                color: .green,
                icon: "checkmark.circle.fill"
            )
            
            quickStatCard(
                title: "Выручка",
                value: "₽\(Int(viewModel.totalRevenue))",
                color: .purple,
                icon: "rubble.circle.fill"
            )
        }
    }
    
    private func quickStatCard(title: String, value: String, color: Color, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(animateCards ? 1.0 : 0.8)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateCards)
    }
    
    private var bookingsListSection: some View {
        LazyVStack(spacing: 16) {
            // Фильтры
            if showingFilters {
                filtersSection
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
            
            // Бронирования
            ForEach(Array(viewModel.filteredBookings.enumerated()), id: \.element.id) { index, booking in
                bookingCard(booking: booking, index: index)
            }
            
            if viewModel.filteredBookings.isEmpty && !viewModel.isLoading {
                emptyStateView
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingFilters)
    }
    
    private var filtersSection: some View {
        VStack(spacing: 12) {
            Text("Фильтры")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(RestaurantBookingFilter.allCases, id: \.self) { filter in
                    filterButton(filter: filter)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func filterButton(filter: RestaurantBookingFilter) -> some View {
        Button(action: {
            selectedFilter = filter
            viewModel.filterBookings(by: filter)
            HapticService.shared.selection()
        }) {
            Text(filter.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(selectedFilter == filter ? .white : .white.opacity(0.7))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(selectedFilter == filter ? filter.color.opacity(0.3) : Color.white.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(
                                    selectedFilter == filter ? filter.color : Color.white.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                )
        }
    }
    
    private func bookingCard(booking: BookingModel, index: Int) -> some View {
        Button(action: {
            selectedBooking = booking
            HapticService.shared.selection()
        }) {
            VStack(spacing: 16) {
                // Хедер с клиентом и статусом
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(booking.clientName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(booking.clientPhone)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Статус бейдж
                    statusBadge(for: booking.status)
                }
                
                // Детали бронирования
                VStack(spacing: 8) {
                    // Дата и время
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(booking.formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(booking.timeSlot)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    
                    // Столик и гости
                    HStack {
                        Image(systemName: "table.furniture")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(booking.tableName)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "person.2")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("\(booking.guests) гостей")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                
                // Быстрые действия
                if booking.canBeConfirmed || booking.canBeCancelled {
                    HStack(spacing: 12) {
                        if booking.canBeConfirmed {
                            quickActionButton(
                                title: "Подтвердить",
                                icon: "checkmark.circle.fill",
                                color: .green
                            ) {
                                Task {
                                    await viewModel.updateBookingStatus(booking.id, status: .confirmed)
                                }
                            }
                        }
                        
                        if booking.canBeCancelled {
                            quickActionButton(
                                title: "Отменить",
                                icon: "xmark.circle.fill",
                                color: .red
                            ) {
                                Task {
                                    await viewModel.updateBookingStatus(booking.id, status: .cancelled)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Сумма
                        if booking.totalPrice > 0 {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("₽\(Int(booking.totalPrice))")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(booking.paymentStatus.displayName)
                                    .font(.caption2)
                                    .foregroundColor(booking.paymentStatus.color)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [booking.status.color.opacity(0.1), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(booking.status.color.opacity(0.3), lineWidth: 1)
                }
            )
            .scaleEffect(animateCards ? 1.0 : 0.8)
            .opacity(animateCards ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05), value: animateCards)
        }
    }
    
    private func statusBadge(for status: BookingStatus) -> some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption2)
            
            Text(status.displayName)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(status.color)
        )
    }
    
    private func quickActionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
            HapticService.shared.buttonPress()
        }) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(color.opacity(0.2))
                    .overlay(
                        Capsule()
                            .stroke(color, lineWidth: 1)
                    )
            )
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Загружаем бронирования...")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.4))
            
            VStack(spacing: 8) {
                Text("Нет бронирований")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Когда клиенты забронируют столики, они появятся здесь")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title)
                .foregroundColor(.orange)
            
            Text("Ошибка")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button("Повторить") {
                Task {
                    await viewModel.loadBookings()
                }
                viewModel.errorMessage = nil
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(24)
        .background(Color.black.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 40)
    }
}

// MARK: - Booking Filter
enum RestaurantBookingFilter: CaseIterable {
    case all
    case pending
    case confirmed
    case today
    case cancelled
    case completed
    
    var displayName: String {
        switch self {
        case .all: return "Все"
        case .pending: return "Ожидают"
        case .confirmed: return "Подтвержд."
        case .today: return "Сегодня"
        case .cancelled: return "Отменены"
        case .completed: return "Завершены"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .blue
        case .pending: return .orange
        case .confirmed: return .green
        case .today: return .purple
        case .cancelled: return .red
        case .completed: return .gray
        }
    }
}

#Preview {
    BookingsManagementView()
}
