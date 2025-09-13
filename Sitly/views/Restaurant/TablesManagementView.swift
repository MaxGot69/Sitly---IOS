//
//  TablesManagementView.swift
//  Sitly
//
//  Created by AI Assistant on 12.09.2025.
//

import SwiftUI
import Combine

struct TablesManagementView: View {
    @StateObject private var viewModel = TablesViewModel()
    @State private var showingAddTable = false
    @State private var selectedTable: TableModel?
    @State private var animateCards = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header с кнопкой добавления
                        headerSection
                        
                        // Статистика столиков
                        statsSection
                        
                        // Список столиков или loading
                        if viewModel.isLoading && viewModel.tables.isEmpty {
                            loadingView
                        } else {
                            tablesGridSection
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
        .sheet(isPresented: $showingAddTable) {
            AddTableSheet(viewModel: viewModel)
        }
        .sheet(item: $selectedTable) { table in
            EditTableSheet(table: table, viewModel: viewModel)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                animateCards = true
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Загружаем столики...")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, minHeight: 200)
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
                    await viewModel.loadTables()
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
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Управление столиками")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(viewModel.tables.count) столиков")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {
                showingAddTable = true
                HapticService.shared.buttonPress()
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
    }
    
    private var statsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            statCard(
                title: "Свободные",
                value: "\(viewModel.availableTables)",
                color: .green,
                icon: "checkmark.circle.fill"
            )
            
            statCard(
                title: "Занятые", 
                value: "\(viewModel.occupiedTables)",
                color: .orange,
                icon: "person.2.fill"
            )
            
            statCard(
                title: "Резерв",
                value: "\(viewModel.reservedTables)", 
                color: .purple,
                icon: "calendar.circle.fill"
            )
        }
    }
    
    private func statCard(title: String, value: String, color: Color, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
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
        .scaleEffect(animateCards ? 1.0 : 0.8)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateCards)
    }
    
    private var tablesGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(Array(viewModel.tables.enumerated()), id: \.element.id) { index, table in
                tableCard(table: table, index: index)
            }
        }
    }
    
    private func tableCard(table: TableModel, index: Int) -> some View {
        Button(action: {
            selectedTable = table
            HapticService.shared.selection()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(table.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("\(table.capacity) мест")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    statusBadge(for: table.status)
                }
                
                HStack {
                    Image(systemName: table.type.icon)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(table.type.displayName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    if table.isVIP {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
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
                                colors: [table.status.color.opacity(0.1), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(table.status.color.opacity(0.3), lineWidth: 1)
                }
            )
            .scaleEffect(animateCards ? 1.0 : 0.8)
            .opacity(animateCards ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateCards)
        }
    }
    
    private func statusBadge(for status: TableModel.TableStatusType) -> some View {
        Button(action: {
            // Показываем меню быстрого изменения статуса
            HapticService.shared.selection()
        }) {
            Text(status.displayName)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(status.color)
                )
        }
    }
}

// MARK: - Table Models
struct TableModel: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var capacity: Int
    var type: TableTypeEnum
    var status: TableStatusType
    var isVIP: Bool
    var position: TablePosition?
    
    enum TableTypeEnum: String, CaseIterable, Codable {
        case indoor = "indoor"
        case outdoor = "outdoor"
        case bar = "bar"
        case vip = "vip"
        
        var displayName: String {
            switch self {
            case .indoor: return "В зале"
            case .outdoor: return "Терраса"
            case .bar: return "Бар"
            case .vip: return "VIP"
            }
        }
        
        var icon: String {
            switch self {
            case .indoor: return "house.fill"
            case .outdoor: return "tree.fill"
            case .bar: return "wineglass.fill"
            case .vip: return "crown.fill"
            }
        }
    }
    
    enum TableStatusType: String, CaseIterable, Codable {
        case available = "available"
        case occupied = "occupied"
        case reserved = "reserved"
        case cleaning = "cleaning"
        case maintenance = "maintenance"
        
        var displayName: String {
            switch self {
            case .available: return "Свободен"
            case .occupied: return "Занят"
            case .reserved: return "Резерв"
            case .cleaning: return "Уборка"
            case .maintenance: return "Ремонт"
            }
        }
        
        var color: Color {
            switch self {
            case .available: return .green
            case .occupied: return .red
            case .reserved: return .purple
            case .cleaning: return .orange
            case .maintenance: return .gray
            }
        }
    }
}

struct TablePosition: Codable {
    let x: Double
    let y: Double
}

// MARK: - Tables ViewModel
class TablesViewModel: ObservableObject {
    @Published var tables: [TableModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let tablesService: TablesServiceProtocol
    private let restaurantId: String
    private var cancellables = Set<AnyCancellable>()
    
    init(restaurantId: String = "demo-restaurant", tablesService: TablesServiceProtocol? = nil) {
        self.restaurantId = restaurantId
        self.tablesService = tablesService ?? MockTablesService() // Используем Mock для разработки
        
        setupRealTimeObserver()
        
        Task {
            await loadTables()
        }
    }
    
    var availableTables: Int {
        tables.filter { $0.status == .available }.count
    }
    
    var occupiedTables: Int {
        tables.filter { $0.status == .occupied }.count
    }
    
    var reservedTables: Int {
        tables.filter { $0.status == .reserved }.count
    }
    
    // MARK: - Real-time Observer
    private func setupRealTimeObserver() {
        tablesService.observeTables(for: restaurantId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                        print("❌ Ошибка наблюдения за столиками: \(error)")
                    }
                },
                receiveValue: { tables in
                    self.tables = tables
                    self.isLoading = false
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Load Tables
    @MainActor
    func loadTables() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedTables = try await tablesService.fetchTables(for: restaurantId)
                self.tables = fetchedTables
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                print("❌ Ошибка загрузки столиков: \(error)")
            }
        }
    }
    
    // MARK: - Add Table
    @MainActor
    func addTable(_ table: TableModel) {
        Task {
            do {
                let createdTable = try await tablesService.createTable(table, for: restaurantId)
                HapticService.shared.notification(.success)
                print("✅ Столик добавлен: \(createdTable.name)")
            } catch {
                self.errorMessage = error.localizedDescription
                HapticService.shared.notification(.error)
                print("❌ Ошибка добавления столика: \(error)")
            }
        }
    }
    
    // MARK: - Update Table
    @MainActor
    func updateTable(_ table: TableModel) {
        Task {
            do {
                try await tablesService.updateTable(table, for: restaurantId)
                HapticService.shared.notification(.success)
                print("✅ Столик обновлен: \(table.name)")
            } catch {
                self.errorMessage = error.localizedDescription
                HapticService.shared.notification(.error)
                print("❌ Ошибка обновления столика: \(error)")
            }
        }
    }
    
    // MARK: - Delete Table
    @MainActor
    func deleteTable(_ table: TableModel) {
        Task {
            do {
                try await tablesService.deleteTable(table, for: restaurantId)
                HapticService.shared.notification(.success)
                print("✅ Столик удален: \(table.name)")
            } catch {
                self.errorMessage = error.localizedDescription
                HapticService.shared.notification(.error)
                print("❌ Ошибка удаления столика: \(error)")
            }
        }
    }
    
    // MARK: - Update Table Status
    @MainActor
    func updateTableStatus(_ tableId: String, status: TableModel.TableStatusType) {
        Task {
            do {
                try await tablesService.updateTableStatus(tableId, status: status, for: restaurantId)
                HapticService.shared.selection()
                print("✅ Статус столика обновлен")
            } catch {
                self.errorMessage = error.localizedDescription
                HapticService.shared.notification(.error)
                print("❌ Ошибка обновления статуса: \(error)")
            }
        }
    }
}

// MARK: - Add Table Sheet
struct AddTableSheet: View {
    @ObservedObject var viewModel: TablesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var capacity = 2
    @State private var selectedType: TableModel.TableTypeEnum = .indoor
    @State private var isVIP = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("Новый столик")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Сохранить") {
                        saveTable()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Название
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Название")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            TextField("Название столика", text: $name)
                                .textFieldStyle(SimpleTextFieldStyle())
                        }
                        
                        // Вместимость
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Вместимость")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            Stepper(value: $capacity, in: 1...20) {
                                Text("\(capacity) мест")
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // VIP переключатель
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("VIP столик")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                
                                Text("Премиум обслуживание")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $isVIP)
                                .toggleStyle(SwitchToggleStyle(tint: .yellow))
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
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
        }
    }
    
    private func saveTable() {
        let table = TableModel(
            name: name.isEmpty ? "Стол \(viewModel.tables.count + 1)" : name,
            capacity: capacity,
            type: selectedType,
            status: .available,
            isVIP: isVIP
        )
        
        viewModel.addTable(table)
        dismiss()
    }
}

// MARK: - Edit Table Sheet
struct EditTableSheet: View {
    let table: TableModel
    @ObservedObject var viewModel: TablesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var selectedStatus: TableModel.TableStatusType
    
    init(table: TableModel, viewModel: TablesViewModel) {
        self.table = table
        self.viewModel = viewModel
        self._name = State(initialValue: table.name)
        self._selectedStatus = State(initialValue: table.status)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("Редактировать")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Сохранить") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Название
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Название")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            TextField("Название столика", text: $name)
                                .textFieldStyle(SimpleTextFieldStyle())
                        }
                        
                        // Статус столика
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Статус")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(TableModel.TableStatusType.allCases, id: \.self) { status in
                                    statusCard(status: status)
                                }
                            }
                        }
                        
                        // Кнопка удаления
                        Button(action: {
                            deleteTable()
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Удалить столик")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.red.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.red, lineWidth: 1)
                                    )
                            )
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
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
        }
    }
    
    private func statusCard(status: TableModel.TableStatusType) -> some View {
        Button(action: {
            selectedStatus = status
            HapticService.shared.selection()
        }) {
            VStack(spacing: 8) {
                Circle()
                    .fill(status.color)
                    .frame(width: 20, height: 20)
                
                Text(status.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(selectedStatus == status ? .white : .white.opacity(0.6))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedStatus == status ? status.color.opacity(0.3) : Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                selectedStatus == status ? status.color : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
    
    private func saveChanges() {
        var updatedTable = table
        updatedTable.name = name
        updatedTable.status = selectedStatus
        
        viewModel.updateTable(updatedTable)
        dismiss()
    }
    
    private func deleteTable() {
        viewModel.deleteTable(table)
        dismiss()
    }
}

// MARK: - Simple Text Field Style
struct SimpleTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .foregroundColor(.white)
    }
}

#Preview {
    TablesManagementView()
}
