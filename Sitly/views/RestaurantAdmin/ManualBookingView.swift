import SwiftUI

struct ManualBookingView: View {
    let restaurant: Restaurant?
    let onBookingCreated: (Booking) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var guestName = ""
    @State private var guestPhone = ""
    @State private var guestCount = 2
    @State private var selectedDate = Date()
    @State private var selectedTime = "19:00"
    @State private var specialRequests = ""
    @State private var selectedTableType = "VIP-столик"
    
    private let timeSlots = ["12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00"]
    private let tableTypes = ["VIP-столик", "У окна", "Терраса", "Центр", "Барная стойка"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Градиентный фон
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.1),
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.15, green: 0.15, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок
                        VStack(spacing: 8) {
                            Text("Новое бронирование")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Создайте бронирование вручную")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 20) {
                            // Информация о госте
                            BookingFormSection(title: "Информация о госте") {
                                VStack(spacing: 16) {
                                    ModernTextField(
                                        title: "Имя гостя",
                                        text: $guestName,
                                        placeholder: "Введите имя"
                                    )
                                    
                                    ModernTextField(
                                        title: "Телефон",
                                        text: $guestPhone,
                                        placeholder: "+7 (999) 123-45-67"
                                    )
                                    
                                    ModernTextField(
                                        title: "Особые пожелания",
                                        text: $specialRequests,
                                        placeholder: "Аллергии, предпочтения..."
                                    )
                                }
                            }
                            
                            // Детали бронирования
                            BookingFormSection(title: "Детали бронирования") {
                                VStack(spacing: 16) {
                                    // Количество гостей
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Количество гостей")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        HStack {
                                            Button(action: { if guestCount > 1 { guestCount -= 1 } }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.blue)
                                            }
                                            
                                            Text("\(guestCount)")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .frame(minWidth: 40)
                                            
                                            Button(action: { if guestCount < 20 { guestCount += 1 } }) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                    
                                    // Дата
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Дата")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                                            .datePickerStyle(CompactDatePickerStyle())
                                            .colorScheme(.dark)
                                    }
                                    
                                    // Время
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Время")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Picker("Время", selection: $selectedTime) {
                                            ForEach(timeSlots, id: \.self) { time in
                                                Text(time).tag(time)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .foregroundColor(.white)
                                    }
                                    
                                    // Тип столика
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Тип столика")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Picker("Тип столика", selection: $selectedTableType) {
                                            ForEach(tableTypes, id: \.self) { type in
                                                Text(type).tag(type)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Кнопка создания
                        Button(action: createBooking) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                
                                Text("Создать бронирование")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .disabled(guestName.isEmpty || guestPhone.isEmpty)
                        .opacity(guestName.isEmpty || guestPhone.isEmpty ? 0.6 : 1.0)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func createBooking() {
        let booking = Booking(
            id: UUID().uuidString,
            restaurantId: restaurant?.id ?? "",
            clientId: "manual_\(UUID().uuidString)",
            tableId: "table_\(UUID().uuidString)",
            date: selectedDate,
            timeSlot: selectedTime,
            guests: guestCount,
            status: BookingStatus.pending,
            specialRequests: specialRequests.isEmpty ? nil : specialRequests,
            totalPrice: 0.0,
            paymentStatus: PaymentStatus.unpaid,
            clientName: guestName,
            clientPhone: guestPhone,
            clientEmail: "manual@example.com",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        onBookingCreated(booking)
        dismiss()
    }
}

struct BookingFormSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct ModernTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                )
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ManualBookingView(restaurant: nil) { _ in }
        .preferredColorScheme(.dark)
}
