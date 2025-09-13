import SwiftUI

struct AdminSettingsView: View {
    @StateObject private var viewModel = AdminSettingsViewModel()
    @State private var showingResetConfirmation = false
    @State private var showingBackupOptions = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Градиентный фон
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.02, blue: 0.1),
                        Color(red: 0.15, green: 0.05, blue: 0.2),
                        Color(red: 0.2, green: 0.1, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок
                        headerSection
                        
                        // Системные настройки
                        systemSettingsSection
                        
                        // Безопасность
                        securitySection
                        
                        // Уведомления
                        notificationsSection
                        
                        // Обслуживание
                        maintenanceSection
                        
                        // Опасная зона
                        dangerZoneSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadSettings()
        }
        .alert("Подтверждение сброса", isPresented: $showingResetConfirmation) {
            Button("Отмена", role: .cancel) { }
            Button("Сбросить", role: .destructive) {
                viewModel.resetSystemSettings()
            }
        } message: {
            Text("Это действие нельзя отменить. Все настройки будут сброшены к заводским.")
        }
        .sheet(isPresented: $showingBackupOptions) {
            BackupOptionsView()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Настройки системы")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Конфигурация платформы Sitly")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Статус системы
            HStack(spacing: 8) {
                Circle()
                    .fill(.green)
                    .frame(width: 10, height: 10)
                
                Text("Система работает")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
        }
    }
    
    // MARK: - System Settings Section
    private var systemSettingsSection: some View {
        SettingsSection(title: "Системные настройки") {
            VStack(spacing: 16) {
                SettingsToggle(
                    title: "Режим разработчика",
                    subtitle: "Показывать отладочную информацию",
                    isOn: $viewModel.isDeveloperModeEnabled,
                    icon: "hammer.fill",
                    color: .blue
                )
                
                SettingsToggle(
                    title: "Автообновления",
                    subtitle: "Автоматически обновлять приложение",
                    isOn: $viewModel.isAutoUpdateEnabled,
                    icon: "arrow.clockwise",
                    color: .green
                )
                
                SettingsToggle(
                    title: "Сбор аналитики",
                    subtitle: "Собирать данные для улучшения сервиса",
                    isOn: $viewModel.isAnalyticsEnabled,
                    icon: "chart.bar.fill",
                    color: .orange
                )
                
                SettingsNavigationRow(
                    title: "API настройки",
                    subtitle: "Конфигурация внешних сервисов",
                    icon: "link",
                    color: .purple,
                    action: { /* Navigate to API settings */ }
                )
            }
        }
    }
    
    // MARK: - Security Section
    private var securitySection: some View {
        SettingsSection(title: "Безопасность") {
            VStack(spacing: 16) {
                SettingsToggle(
                    title: "Двухфакторная аутентификация",
                    subtitle: "Дополнительная защита для админов",
                    isOn: $viewModel.isTwoFactorEnabled,
                    icon: "lock.shield.fill",
                    color: .red
                )
                
                SettingsToggle(
                    title: "Логирование действий",
                    subtitle: "Записывать все действия администраторов",
                    isOn: $viewModel.isAuditLogEnabled,
                    icon: "doc.text.fill",
                    color: .blue
                )
                
                SettingsSlider(
                    title: "Время сессии",
                    subtitle: "Автоматический выход через (мин)",
                    value: $viewModel.sessionTimeout,
                    range: 15...120,
                    step: 15,
                    icon: "clock.fill",
                    color: .cyan
                )
                
                SettingsNavigationRow(
                    title: "Журнал безопасности",
                    subtitle: "Просмотр событий безопасности",
                    icon: "eye.fill",
                    color: .indigo,
                    action: { /* Navigate to security log */ }
                )
            }
        }
    }
    
    // MARK: - Notifications Section
    private var notificationsSection: some View {
        SettingsSection(title: "Уведомления") {
            VStack(spacing: 16) {
                SettingsToggle(
                    title: "Push уведомления",
                    subtitle: "Отправлять push уведомления пользователям",
                    isOn: $viewModel.isPushNotificationsEnabled,
                    icon: "bell.fill",
                    color: .orange
                )
                
                SettingsToggle(
                    title: "Email рассылка",
                    subtitle: "Отправлять email уведомления",
                    isOn: $viewModel.isEmailNotificationsEnabled,
                    icon: "envelope.fill",
                    color: .blue
                )
                
                SettingsToggle(
                    title: "SMS уведомления",
                    subtitle: "Отправлять SMS о важных событиях",
                    isOn: $viewModel.isSMSNotificationsEnabled,
                    icon: "message.fill",
                    color: .green
                )
                
                SettingsSlider(
                    title: "Частота отчетов",
                    subtitle: "Автоматические отчеты каждые (дней)",
                    value: $viewModel.reportFrequency,
                    range: 1...30,
                    step: 1,
                    icon: "calendar.circle.fill",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Maintenance Section
    private var maintenanceSection: some View {
        SettingsSection(title: "Обслуживание") {
            VStack(spacing: 16) {
                SettingsActionRow(
                    title: "Очистка кэша",
                    subtitle: "Удалить временные файлы",
                    icon: "trash.fill",
                    color: .yellow,
                    action: { viewModel.clearCache() }
                )
                
                SettingsActionRow(
                    title: "Создать резервную копию",
                    subtitle: "Экспорт данных и настроек",
                    icon: "externaldrive.fill",
                    color: .blue,
                    action: { showingBackupOptions = true }
                )
                
                SettingsActionRow(
                    title: "Проверка целостности",
                    subtitle: "Проверить базу данных на ошибки",
                    icon: "checkmark.shield.fill",
                    color: .green,
                    action: { viewModel.runIntegrityCheck() }
                )
                
                SettingsNavigationRow(
                    title: "Техническая информация",
                    subtitle: "Версии, лицензии, системные данные",
                    icon: "info.circle.fill",
                    color: .gray,
                    action: { /* Navigate to system info */ }
                )
            }
        }
    }
    
    // MARK: - Danger Zone Section
    private var dangerZoneSection: some View {
        SettingsSection(title: "Опасная зона") {
            VStack(spacing: 16) {
                SettingsActionRow(
                    title: "Сбросить настройки",
                    subtitle: "Вернуть все настройки к заводским",
                    icon: "arrow.counterclockwise",
                    color: .red,
                    action: { showingResetConfirmation = true }
                )
                
                SettingsActionRow(
                    title: "Режим обслуживания",
                    subtitle: "Временно отключить доступ к платформе",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange,
                    action: { viewModel.toggleMaintenanceMode() }
                )
            }
        }
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
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
            
            VStack(spacing: 0) {
                content
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Settings Toggle
struct SettingsToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(color)
        }
    }
}

// MARK: - Settings Slider
struct SettingsSlider: View {
    let title: String
    let subtitle: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(subtitle): \(Int(value))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            
            Slider(value: $value, in: range, step: step)
                .tint(color)
        }
    }
}

// MARK: - Settings Navigation Row
struct SettingsNavigationRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Action Row
struct SettingsActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Backup Options View
struct BackupOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Опции резервного копирования")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                    
                    Text("Выберите данные для экспорта")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Экспорт") { dismiss() }
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

#Preview {
    AdminSettingsView()
}
