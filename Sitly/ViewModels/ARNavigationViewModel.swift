import Foundation
import Combine
import AVFoundation
import Speech

@MainActor
class ARNavigationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var tables: [Table] = []
    @Published var isARReady = false
    @Published var searchQuery = ""
    @Published var selectedFilter: String?
    @Published var isVoiceNavigationActive = false
    @Published var voiceCommand = ""
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    var totalTables: Int {
        tables.count
    }
    
    var availableTables: Int {
        tables.filter { $0.isAvailable }.count
    }
    
    var averageWaitTime: String {
        // Вычисляем среднее время ожидания
        let waitTimes = tables.compactMap { table -> Int? in
            // В реальном приложении это будет из базы данных
            return Int.random(in: 5...45)
        }
        
        let average = waitTimes.isEmpty ? 0 : waitTimes.reduce(0, +) / waitTimes.count
        return "\(average) мин"
    }
    
    var filters: [String] {
        ["Все", "Свободные", "VIP", "У окна", "Терраса", "Приватные"]
    }
    
    var filteredTables: [Table] {
        var filtered = tables
        
        // Фильтр по поиску
        if !searchQuery.isEmpty {
            filtered = filtered.filter { table in
                "Стол \(table.number)".localizedCaseInsensitiveContains(searchQuery) ||
                table.location.displayName.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        // Фильтр по типу
        if let filter = selectedFilter, filter != "Все" {
            switch filter {
            case "Свободные":
                filtered = filtered.filter { $0.isAvailable }
            case "VIP":
                filtered = filtered.filter { $0.features.contains(.romantic) }
            case "У окна":
                filtered = filtered.filter { $0.location == .window }
            case "Терраса":
                filtered = filtered.filter { $0.location == .outdoor }
            case "Приватные":
                filtered = filtered.filter { $0.location == .private }
            default:
                break
            }
        }
        
        return filtered
    }
    
    // MARK: - Dependencies
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupSpeechRecognition()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupSpeechRecognition() {
        // Запрашиваем разрешение на распознавание речи
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.isARReady = true
                case .denied, .restricted, .notDetermined:
                    self?.errorMessage = "Разрешение на распознавание речи не предоставлено"
                @unknown default:
                    self?.errorMessage = "Неизвестная ошибка распознавания речи"
                }
            }
        }
    }
    
    private func setupBindings() {
        // Автоматический поиск при изменении запроса
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.searchTables()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    func loadRestaurantData(_ restaurant: Restaurant) {
        Task {
            // Загружаем столики ресторана
            tables = restaurant.tables
            
            // Если столиков нет, создаем моковые для демо
            if tables.isEmpty {
                tables = createMockTables()
            }
            
            // Инициализируем AR
            await initializeAR()
        }
    }
    
    private func createMockTables() -> [Table] {
        return [
            Table(
                id: "1",
                number: 1,
                capacity: 4,
                location: .indoor,
                features: [.romantic],
                isAvailable: true,
                price: 5000
            ),
            Table(
                id: "2",
                number: 2,
                capacity: 2,
                location: .window,
                features: [],
                isAvailable: true,
                price: 2000
            ),
            Table(
                id: "3",
                number: 3,
                capacity: 6,
                location: .outdoor,
                features: [],
                isAvailable: false,
                price: 3000
            ),
            Table(
                id: "4",
                number: 4,
                capacity: 8,
                location: .private,
                features: [],
                isAvailable: true,
                price: 8000
            ),
            Table(
                id: "5",
                number: 5,
                capacity: 4,
                location: .window,
                features: [.romantic],
                isAvailable: true,
                price: 4000
            )
        ]
    }
    
    private func initializeAR() async {
        // Имитация инициализации AR
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        DispatchQueue.main.async {
            self.isARReady = true
        }
    }
    
    // MARK: - Table Management
    func searchTables() {
        // Поиск уже реализован через computed property filteredTables
        // Здесь можно добавить дополнительную логику поиска
    }
    
    func selectFilter(_ filter: String) {
        selectedFilter = selectedFilter == filter ? nil : filter
    }
    
    func getTableById(_ id: String) -> Table? {
        return tables.first { $0.id == id }
    }
    
    func updateTableStatus(_ tableId: String, isAvailable: Bool) {
        if let index = tables.firstIndex(where: { $0.id == tableId }) {
            tables[index] = Table(
                id: tables[index].id,
                number: tables[index].number,
                capacity: tables[index].capacity,
                location: tables[index].location,
                features: tables[index].features,
                isAvailable: isAvailable,
                price: tables[index].price
            )
        }
    }
    
    // MARK: - Voice Navigation
    func startVoiceNavigation() {
        guard !isVoiceNavigationActive else {
            stopVoiceNavigation()
            return
        }
        
        startSpeechRecognition()
    }
    
    func stopVoiceNavigation() {
        stopSpeechRecognition()
    }
    
    private func startSpeechRecognition() {
        // Проверяем доступность
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Распознавание речи недоступно"
            return
        }
        
        // Настраиваем аудио сессию
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Ошибка настройки аудио: \(error.localizedDescription)"
            return
        }
        
        // Создаем запрос на распознавание
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Не удалось создать запрос на распознавание"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Настраиваем аудио движок
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // Запускаем аудио движок
        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            errorMessage = "Ошибка запуска аудио движка: \(error.localizedDescription)"
            return
        }
        
        // Запускаем распознавание
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self?.voiceCommand = result.bestTranscription.formattedString
                    self?.processVoiceCommand(result.bestTranscription.formattedString)
                }
                
                if error != nil || result?.isFinal == true {
                    self?.stopSpeechRecognition()
                }
            }
        }
        
        isVoiceNavigationActive = true
    }
    
    private func stopSpeechRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        isVoiceNavigationActive = false
        voiceCommand = ""
    }
    
    private func processVoiceCommand(_ command: String) {
        let lowercasedCommand = command.lowercased()
        
        // Команды навигации
        if lowercasedCommand.contains("показать") || lowercasedCommand.contains("найти") {
            if lowercasedCommand.contains("свободные") || lowercasedCommand.contains("свободный") {
                selectedFilter = "Свободные"
            } else if lowercasedCommand.contains("vip") || lowercasedCommand.contains("вип") {
                selectedFilter = "VIP"
            } else if lowercasedCommand.contains("окно") || lowercasedCommand.contains("окном") {
                selectedFilter = "У окна"
            } else if lowercasedCommand.contains("терраса") || lowercasedCommand.contains("террасу") {
                selectedFilter = "Терраса"
            } else if lowercasedCommand.contains("приватный") || lowercasedCommand.contains("приватные") {
                selectedFilter = "Приватные"
            }
        }
        
        // Команды поиска
        if lowercasedCommand.contains("столик") && lowercasedCommand.contains("мест") {
            if let seatsString = lowercasedCommand.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .compactMap({ Int($0) })
                .first {
                searchQuery = "\(seatsString) мест"
            }
        }
        
        // Команды статуса
        if lowercasedCommand.contains("статус") || lowercasedCommand.contains("информация") {
            // Показать информацию о выбранном столике
        }
        
        // Команды помощи
        if lowercasedCommand.contains("помощь") || lowercasedCommand.contains("команды") {
            showVoiceCommandsHelp()
        }
    }
    
    private func showVoiceCommandsHelp() {
        // Показываем список доступных голосовых команд
        let commands = [
            "Показать свободные столики",
            "Найти VIP столик",
            "Столик у окна",
            "Терраса",
            "Приватные залы",
            "Столик на 4 места",
            "Статус столика",
            "Помощь"
        ]
        
        // В реальном приложении это будет показано в UI
        print("Доступные голосовые команды:")
        commands.forEach { print("- \($0)") }
    }
    
    // MARK: - AR Features
    func toggleARMode() {
        // Переключение между AR и обычным режимом
        isARReady.toggle()
    }
    
    func calibrateAR() {
        // Калибровка AR-системы
        Task {
            // Имитация калибровки
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            DispatchQueue.main.async {
                self.isARReady = true
            }
        }
    }
    
    // MARK: - Analytics
    func getTableAnalytics() -> TableAnalytics {
        let totalBookings = tables.reduce(0) { $0 + ($1.isAvailable ? 0 : 1) }
        let revenue = tables.reduce(0.0) { $0 + $1.price }
        let popularFeatures = getPopularFeatures()
        
        return TableAnalytics(
            totalTables: totalTables,
            availableTables: availableTables,
            totalBookings: totalBookings,
            averageRevenue: revenue / Double(totalTables),
            popularFeatures: popularFeatures
        )
    }
    
    private func getPopularFeatures() -> [TableFeature] {
        let featureCounts = tables.flatMap { $0.features }
            .reduce(into: [TableFeature: Int]()) { counts, feature in
                counts[feature, default: 0] += 1
            }
        
        return featureCounts.sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }
    
    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
    }
    
    func retryOperation() {
        // Повторная попытка операции
        Task {
            await initializeAR()
        }
    }
}

// MARK: - Supporting Models

struct TableAnalytics {
    let totalTables: Int
    let availableTables: Int
    let totalBookings: Int
    let averageRevenue: Double
    let popularFeatures: [TableFeature]
}

// MARK: - Voice Commands
enum VoiceCommand: String, CaseIterable {
    case showAvailable = "показать свободные"
    case showVIP = "показать vip"
    case showWindow = "показать у окна"
    case showTerrace = "показать террасу"
    case showPrivate = "показать приватные"
    case findTable = "найти столик"
    case getStatus = "статус столика"
    case help = "помощь"
    
    var displayName: String {
        switch self {
        case .showAvailable: return "Показать свободные столики"
        case .showVIP: return "Показать VIP столики"
        case .showWindow: return "Показать столики у окна"
        case .showTerrace: return "Показать столики на террасе"
        case .showPrivate: return "Показать приватные залы"
        case .findTable: return "Найти столик"
        case .getStatus: return "Получить статус столика"
        case .help: return "Показать помощь"
        }
    }
    
    var description: String {
        switch self {
        case .showAvailable: return "Показывает все доступные столики"
        case .showVIP: return "Показывает VIP столики"
        case .showWindow: return "Показывает столики у окна"
        case .showTerrace: return "Показывает столики на террасе"
        case .showPrivate: return "Показывает приватные залы"
        case .findTable: return "Поиск столика по параметрам"
        case .getStatus: return "Информация о выбранном столике"
        case .help: return "Список доступных команд"
        }
    }
}
