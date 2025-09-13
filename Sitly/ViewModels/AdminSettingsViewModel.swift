import Foundation

@MainActor
class AdminSettingsViewModel: ObservableObject {
    // MARK: - System Settings
    @Published var isDeveloperModeEnabled = false
    @Published var isAutoUpdateEnabled = true
    @Published var isAnalyticsEnabled = true
    
    // MARK: - Security Settings
    @Published var isTwoFactorEnabled = true
    @Published var isAuditLogEnabled = true
    @Published var sessionTimeout: Double = 60 // minutes
    
    // MARK: - Notification Settings
    @Published var isPushNotificationsEnabled = true
    @Published var isEmailNotificationsEnabled = true
    @Published var isSMSNotificationsEnabled = false
    @Published var reportFrequency: Double = 7 // days
    
    // MARK: - System Status
    @Published var isMaintenanceModeEnabled = false
    @Published var lastBackupDate: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // MARK: - Initialization
    init() {
        loadSettings()
    }
    
    // MARK: - Public Methods
    func loadSettings() {
        isLoading = true
        
        // В реальном приложении здесь будет загрузка настроек из API или UserDefaults
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            self.loadStoredSettings()
        }
    }
    
    func saveSettings() {
        // В реальном приложении здесь будет сохранение настроек
        UserDefaults.standard.set(isDeveloperModeEnabled, forKey: "isDeveloperModeEnabled")
        UserDefaults.standard.set(isAutoUpdateEnabled, forKey: "isAutoUpdateEnabled")
        UserDefaults.standard.set(isAnalyticsEnabled, forKey: "isAnalyticsEnabled")
        UserDefaults.standard.set(isTwoFactorEnabled, forKey: "isTwoFactorEnabled")
        UserDefaults.standard.set(isAuditLogEnabled, forKey: "isAuditLogEnabled")
        UserDefaults.standard.set(sessionTimeout, forKey: "sessionTimeout")
        UserDefaults.standard.set(isPushNotificationsEnabled, forKey: "isPushNotificationsEnabled")
        UserDefaults.standard.set(isEmailNotificationsEnabled, forKey: "isEmailNotificationsEnabled")
        UserDefaults.standard.set(isSMSNotificationsEnabled, forKey: "isSMSNotificationsEnabled")
        UserDefaults.standard.set(reportFrequency, forKey: "reportFrequency")
        UserDefaults.standard.set(isMaintenanceModeEnabled, forKey: "isMaintenanceModeEnabled")
        
        showSuccessMessage("Настройки сохранены")
    }
    
    func clearCache() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isLoading = false
            self.showSuccessMessage("Кэш очищен успешно")
        }
    }
    
    func createBackup() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.isLoading = false
            self.lastBackupDate = Date()
            self.showSuccessMessage("Резервная копия создана")
        }
    }
    
    func runIntegrityCheck() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isLoading = false
            self.showSuccessMessage("Проверка целостности завершена. Ошибок не обнаружено")
        }
    }
    
    func resetSystemSettings() {
        // Сброс к заводским настройкам
        isDeveloperModeEnabled = false
        isAutoUpdateEnabled = true
        isAnalyticsEnabled = true
        isTwoFactorEnabled = true
        isAuditLogEnabled = true
        sessionTimeout = 60
        isPushNotificationsEnabled = true
        isEmailNotificationsEnabled = true
        isSMSNotificationsEnabled = false
        reportFrequency = 7
        isMaintenanceModeEnabled = false
        
        // Очистка UserDefaults
        let keys = [
            "isDeveloperModeEnabled", "isAutoUpdateEnabled", "isAnalyticsEnabled",
            "isTwoFactorEnabled", "isAuditLogEnabled", "sessionTimeout",
            "isPushNotificationsEnabled", "isEmailNotificationsEnabled", "isSMSNotificationsEnabled",
            "reportFrequency", "isMaintenanceModeEnabled"
        ]
        
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        showSuccessMessage("Настройки сброшены к заводским")
    }
    
    func toggleMaintenanceMode() {
        isMaintenanceModeEnabled.toggle()
        saveSettings()
        
        let message = isMaintenanceModeEnabled ? 
            "Режим обслуживания включен. Пользователи не могут получить доступ к платформе" :
            "Режим обслуживания выключен. Платформа доступна для пользователей"
        
        showSuccessMessage(message)
    }
    
    // MARK: - Private Methods
    private func loadStoredSettings() {
        isDeveloperModeEnabled = UserDefaults.standard.bool(forKey: "isDeveloperModeEnabled")
        isAutoUpdateEnabled = UserDefaults.standard.object(forKey: "isAutoUpdateEnabled") as? Bool ?? true
        isAnalyticsEnabled = UserDefaults.standard.object(forKey: "isAnalyticsEnabled") as? Bool ?? true
        isTwoFactorEnabled = UserDefaults.standard.object(forKey: "isTwoFactorEnabled") as? Bool ?? true
        isAuditLogEnabled = UserDefaults.standard.object(forKey: "isAuditLogEnabled") as? Bool ?? true
        sessionTimeout = UserDefaults.standard.object(forKey: "sessionTimeout") as? Double ?? 60
        isPushNotificationsEnabled = UserDefaults.standard.object(forKey: "isPushNotificationsEnabled") as? Bool ?? true
        isEmailNotificationsEnabled = UserDefaults.standard.object(forKey: "isEmailNotificationsEnabled") as? Bool ?? true
        isSMSNotificationsEnabled = UserDefaults.standard.bool(forKey: "isSMSNotificationsEnabled")
        reportFrequency = UserDefaults.standard.object(forKey: "reportFrequency") as? Double ?? 7
        isMaintenanceModeEnabled = UserDefaults.standard.bool(forKey: "isMaintenanceModeEnabled")
        
        // Загрузка даты последней резервной копии
        if let backupDate = UserDefaults.standard.object(forKey: "lastBackupDate") as? Date {
            lastBackupDate = backupDate
        }
    }
    
    private func showSuccessMessage(_ message: String) {
        successMessage = message
        
        // Автоматически скрыть сообщение через 3 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.successMessage = nil
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        
        // Автоматически скрыть сообщение через 5 секунд
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.errorMessage = nil
        }
    }
}
