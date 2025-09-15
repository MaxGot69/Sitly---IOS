//
//  BookingDetailView.swift
//  Sitly
//
//  Created by AI Assistant on 12.09.2025.
//

import SwiftUI

struct BookingDetailView: View {
    let booking: Booking
    @ObservedObject var viewModel: BookingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingStatusSheet = false
    @State private var selectedStatus: BookingStatus
    @State private var isUpdating = false
    
    init(booking: Booking, viewModel: BookingsViewModel) {
        self.booking = booking
        self.viewModel = viewModel
        self._selectedStatus = State(initialValue: booking.status)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                mainContent
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.1, green: 0.08, blue: 0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Позвонить") {
                        makePhoneCall()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .confirmationDialog("Изменить статус", isPresented: $showingStatusSheet) {
            ForEach(BookingStatus.allCases, id: \.self) { status in
                if status != booking.status {
                    Button(status.displayName) {
                        updateStatus(to: status)
                    }
                }
            }
            
            Button("Отмена", role: .cancel) { }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 24) {
            // Хедер с информацией о клиенте
            clientInfoSection
            
            // Детали бронирования
            bookingDetailsSection
            
            // Особые пожелания
            if let requests = booking.specialRequests, !requests.isEmpty {
                specialRequestsSection(requests: requests)
            }
            
            // Финансовая информация
            if booking.totalPrice > 0 {
                paymentSection
            }
            
            // Управление статусом
            statusManagementSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var clientInfoSection: some View {
        VStack(spacing: 16) {
            // Аватар и имя
            VStack(spacing: 12) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(booking.clientName.prefix(1).uppercased())
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(spacing: 4) {
                    Text(booking.clientName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(booking.clientEmail ?? "Не указан")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Контактная информация
            VStack(spacing: 8) {
                contactRow(icon: "phone.fill", text: booking.clientPhone, color: .green)
                contactRow(icon: "envelope.fill", text: booking.clientEmail ?? "Не указан", color: .blue)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func contactRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var bookingDetailsSection: some View {
        VStack(spacing: 16) {
            sectionHeader(title: "Детали бронирования", icon: "calendar.circle.fill")
            
            VStack(spacing: 12) {
                detailRow(
                    icon: "calendar",
                    title: "Дата",
                    value: formatDate(booking.date),
                    color: .orange
                )
                
                detailRow(
                    icon: "clock",
                    title: "Время",
                    value: booking.timeSlot,
                    color: .purple
                )
                
                detailRow(
                    icon: "table.furniture",
                    title: "Столик",
                    value: "Столик \(booking.tableId)",
                    color: .blue
                )
                
                detailRow(
                    icon: "person.2",
                    title: "Количество гостей",
                    value: "\(booking.guests) человек",
                    color: .green
                )
                
                detailRow(
                    icon: statusIcon(for: booking.status),
                    title: "Статус",
                    value: booking.status.displayName,
                    color: statusColor(for: booking.status)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func specialRequestsSection(requests: String) -> some View {
        VStack(spacing: 16) {
            sectionHeader(title: "Особые пожелания", icon: "text.bubble.fill")
            
            Text(requests)
                .font(.body)
                .foregroundColor(.white)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var paymentSection: some View {
        VStack(spacing: 16) {
            sectionHeader(title: "Оплата", icon: "creditcard.fill")
            
            VStack(spacing: 12) {
                detailRow(
                    icon: "rubble.circle.fill",
                    title: "Сумма",
                    value: "₽\(Int(booking.totalPrice))",
                    color: .yellow
                )
                
                detailRow(
                    icon: "checkmark.circle.fill",
                    title: "Статус оплаты",
                    value: booking.paymentStatus.displayName,
                    color: paymentStatusColor(for: booking.paymentStatus)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var statusManagementSection: some View {
        VStack(spacing: 16) {
            sectionHeader(title: "Управление", icon: "gear.circle.fill")
            statusButtonsSection
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var statusButtonsSection: some View {
        VStack(spacing: 12) {
            // Изменить статус
            Button(action: {
                showingStatusSheet = true
                HapticService.shared.buttonPress()
            }) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.title3)
                    
                    Text("Изменить статус")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .foregroundColor(.white)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.blue, lineWidth: 1)
                        )
                )
            }
            .disabled(isUpdating)
            
            // Быстрые действия
            if booking.status == .pending {
                HStack(spacing: 12) {
                    quickActionButton(
                        title: "Подтвердить",
                        icon: "checkmark.circle.fill",
                        color: .green
                    ) {
                        updateStatus(to: .confirmed)
                    }
                    
                    quickActionButton(
                        title: "Отменить",
                        icon: "xmark.circle.fill",
                        color: .red
                    ) {
                        updateStatus(to: .cancelled)
                    }
                }
            }
            
            // Удалить бронирование
            Button(action: {
                deleteBooking()
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .font(.title3)
                    
                    Text("Удалить бронирование")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.red, lineWidth: 1)
                        )
                )
            }
            .disabled(isUpdating)
        }
    }
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    private func detailRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private func quickActionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(color, lineWidth: 1)
                    )
            )
        }
        .disabled(isUpdating)
    }
    
    private func updateStatus(to status: BookingStatus) {
        isUpdating = true
        
        Task {
            await viewModel.updateBookingStatus(booking.id, status: status)
            
            await MainActor.run {
                isUpdating = false
                selectedStatus = status
                dismiss()
            }
        }
    }
    
    private func deleteBooking() {
        Task {
            await viewModel.deleteBooking(booking)
            
            await MainActor.run {
                dismiss()
            }
        }
    }
    
    private func makePhoneCall() {
        let phoneNumber = booking.clientPhone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        
        if let url = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    BookingDetailView(
        booking: Booking(
            restaurantId: "demo-restaurant",
            clientId: "client1",
            tableId: "table1",
            date: Date(),
            timeSlot: "18:00-20:00",
            guests: 2,
            status: BookingStatus.pending,
            specialRequests: "У окна, пожалуйста. Особые требования к обслуживанию.",
            totalPrice: 2500.0,
            paymentStatus: PaymentStatus.unpaid,
            clientName: "Анна Петрова",
            clientPhone: "+7 (999) 123-45-67",
            clientEmail: "anna@example.com",
            createdAt: Date(),
            updatedAt: Date()
        ),
        viewModel: BookingsViewModel()
    )
}

// MARK: - Helper Functions
extension BookingDetailView {
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func paymentStatusColor(for status: PaymentStatus) -> Color {
        switch status {
        case .unpaid: return .red
        case .paid: return .green
        case .pending: return .orange
        case .refunded: return .blue
        }
    }
    
    private func statusIcon(for status: BookingStatus) -> String {
        switch status {
        case .pending: return "clock.fill"
        case .confirmed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        case .completed: return "checkmark.seal.fill"
        case .noShow: return "person.crop.circle.badge.xmark"
        }
    }
    
    private func statusColor(for status: BookingStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .green
        case .cancelled: return .red
        case .completed: return .blue
        case .noShow: return .gray
        }
    }
}
