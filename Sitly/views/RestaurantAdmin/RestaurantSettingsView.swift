import SwiftUI

struct RestaurantSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isOpen = true
    @State private var autoConfirmBookings = false
    @State private var maxAdvanceBookingDays = 30
    @State private var minBookingNotice = 2
    @State private var allowCancellations = true
    @State private var cancellationDeadline = 24
    
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
                            Text("Настройки ресторана")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Управляйте параметрами работы")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 20) {
                            // Основные настройки
                            SettingsSection(title: "Основные настройки") {
                                VStack(spacing: 16) {
                                    SettingsToggle(
                                        title: "Ресторан открыт",
                                        subtitle: "Принимать новые бронирования",
                                        isOn: $isOpen,
                                        icon: "toggle.on",
                                        color: .green
                                    )
                                    
                                    SettingsToggle(
                                        title: "Автоподтверждение",
                                        subtitle: "Автоматически подтверждать бронирования",
                                        isOn: $autoConfirmBookings,
                                        icon: "checkmark.circle",
                                        color: .blue
                                    )
                                    
                                    SettingsToggle(
                                        title: "Разрешить отмены",
                                        subtitle: "Гости могут отменять бронирования",
                                        isOn: $allowCancellations,
                                        icon: "xmark.circle",
                                        color: .orange
                                    )
                                }
                            }
                            
                            // Настройки бронирований
                            SettingsSection(title: "Настройки бронирований") {
                                VStack(spacing: 16) {
                                    SettingsStepper(
                                        title: "Максимум дней вперед",
                                        subtitle: "За сколько дней можно бронировать",
                                        value: $maxAdvanceBookingDays,
                                        range: 1...90
                                    )
                                    
                                    SettingsStepper(
                                        title: "Минимальное уведомление",
                                        subtitle: "За сколько часов нужно бронировать",
                                        value: $minBookingNotice,
                                        range: 1...48
                                    )
                                    
                                    SettingsStepper(
                                        title: "Дедлайн отмены",
                                        subtitle: "За сколько часов можно отменить",
                                        value: $cancellationDeadline,
                                        range: 1...72
                                    )
                                }
                            }
                            
                            // Уведомления
                            SettingsSection(title: "Уведомления") {
                                VStack(spacing: 16) {
                                    SettingsToggle(
                                        title: "Push-уведомления",
                                        subtitle: "Получать уведомления о новых бронях",
                                        isOn: .constant(true),
                                        icon: "bell.fill",
                                        color: .blue
                                    )
                                    
                                    SettingsToggle(
                                        title: "Email-уведомления",
                                        subtitle: "Получать уведомления на email",
                                        isOn: .constant(true),
                                        icon: "envelope.fill",
                                        color: .green
                                    )
                                    
                                    SettingsToggle(
                                        title: "SMS-уведомления",
                                        subtitle: "Получать уведомления по SMS",
                                        isOn: .constant(false),
                                        icon: "message.fill",
                                        color: .orange
                                    )
                                }
                            }
                            
                            // AI настройки
                            SettingsSection(title: "AI-помощник") {
                                VStack(spacing: 16) {
                                    SettingsToggle(
                                        title: "AI-рекомендации",
                                        subtitle: "Получать рекомендации по оптимизации",
                                        isOn: .constant(true),
                                        icon: "brain.head.profile",
                                        color: .purple
                                    )
                                    
                                    SettingsToggle(
                                        title: "Автоанализ",
                                        subtitle: "Автоматически анализировать данные",
                                        isOn: .constant(true),
                                        icon: "chart.line.uptrend.xyaxis",
                                        color: .cyan
                                    )
                                    
                                    SettingsToggle(
                                        title: "Предсказания",
                                        subtitle: "Предсказывать отмены бронирований",
                                        isOn: .constant(true),
                                        icon: "crystal.ball",
                                        color: .indigo
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Кнопка сохранения
                        Button(action: saveSettings) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                
                                Text("Сохранить настройки")
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сброс") {
                        resetSettings()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
    
    private func saveSettings() {
        // Сохранение настроек в Firebase
        print("💾 Сохранение настроек ресторана...")
        dismiss()
    }
    
    private func resetSettings() {
        isOpen = true
        autoConfirmBookings = false
        maxAdvanceBookingDays = 30
        minBookingNotice = 2
        allowCancellations = true
        cancellationDeadline = 24
    }
}


struct SettingsStepper: View {
    let title: String
    let subtitle: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: { if value > range.lowerBound { value -= 1 } }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(value <= range.lowerBound)
                    
                    Text("\(value)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(minWidth: 40)
                    
                    Button(action: { if value < range.upperBound { value += 1 } }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(value >= range.upperBound)
                }
            }
        }
    }
}

#Preview {
    RestaurantSettingsView()
        .preferredColorScheme(.dark)
}
