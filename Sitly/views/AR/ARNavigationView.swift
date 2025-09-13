import SwiftUI
import ARKit
import RealityKit
import CoreLocation

struct ARNavigationView: View {
    let restaurant: Restaurant
    @StateObject private var viewModel = ARNavigationViewModel()
    @State private var showingARScene = false
    @State private var selectedTable: Table?
    @State private var showingTableInfo = false
    
    var body: some View {
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
            
            VStack(spacing: 0) {
                // Заголовок AR
                arHeader
                
                if showingARScene {
                    // AR-сцена
                    ARSceneView(
                        restaurant: restaurant,
                        selectedTable: $selectedTable,
                        showingTableInfo: $showingTableInfo
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // 3D-карта ресторана
                    restaurant3DMap
                }
                
                // Панель управления
                controlPanel
            }
        }
        .onAppear {
            viewModel.loadRestaurantData(restaurant)
        }
        .sheet(isPresented: $showingTableInfo) {
            if let table = selectedTable {
                TableInfoView(table: table)
            }
        }
    }
    
    // MARK: - AR Header
    private var arHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("AR-навигация")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Исследуйте \(restaurant.name) в дополненной реальности")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Статус AR
            HStack(spacing: 8) {
                Circle()
                    .fill(viewModel.isARReady ? .green : .orange)
                    .frame(width: 8, height: 8)
                
                Text(viewModel.isARReady ? "AR готов" : "Инициализация...")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.purple.opacity(0.5), .blue.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Restaurant 3D Map
    private var restaurant3DMap: some View {
        ZStack {
            // 3D-карта ресторана
            Restaurant3DMapView(
                restaurant: restaurant,
                tables: viewModel.tables,
                selectedTable: $selectedTable
            )
            
            // Информационные панели
            VStack {
                HStack {
                    // Легенда
                    legendPanel
                    
                    Spacer()
                    
                    // Быстрые действия
                    quickActionsPanel
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Статистика
                statisticsPanel
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Legend Panel
    private var legendPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Легенда")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                LegendItem(
                    icon: "circle.fill",
                    color: .green,
                    text: "Свободно"
                )
                
                LegendItem(
                    icon: "circle.fill",
                    color: .red,
                    text: "Занято"
                )
                
                LegendItem(
                    icon: "circle.fill",
                    color: .orange,
                    text: "Забронировано"
                )
                
                LegendItem(
                    icon: "star.fill",
                    color: .yellow,
                    text: "VIP-столик"
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Quick Actions Panel
    private var quickActionsPanel: some View {
        VStack(spacing: 12) {
            Button(action: {
                withAnimation(.spring()) {
                    showingARScene.toggle()
                }
            }) {
                VStack(spacing: 8) {
                    Image(systemName: showingARScene ? "eye.slash.fill" : "camera.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text(showingARScene ? "2D карта" : "AR режим")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .frame(width: 80, height: 80)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            }
            .buttonStyle(ScaleButtonStyle())
            
            Button(action: {
                viewModel.startVoiceNavigation()
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "mic.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Голос")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .frame(width: 80, height: 80)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
    
    // MARK: - Statistics Panel
    private var statisticsPanel: some View {
        HStack(spacing: 20) {
            StatisticItem(
                icon: "table.furniture",
                value: "\(viewModel.totalTables)",
                label: "Всего столиков"
            )
            
            StatisticItem(
                icon: "checkmark.circle.fill",
                value: "\(viewModel.availableTables)",
                label: "Свободно"
            )
            
            StatisticItem(
                icon: "clock.fill",
                value: "\(viewModel.averageWaitTime)",
                label: "Среднее время ожидания"
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Control Panel
    private var controlPanel: some View {
        VStack(spacing: 16) {
            // Поиск столика
            HStack(spacing: 12) {
                TextField("Найти столик...", text: $viewModel.searchQuery)
                    .textFieldStyle(ModernTextFieldStyle())
                
                Button(action: {
                    viewModel.searchTables()
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.blue)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 20)
            
            // Фильтры
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.filters, id: \.self) { filter in
                        FilterChip(
                            title: filter,
                            isSelected: viewModel.selectedFilter == filter,
                            action: {
                                viewModel.selectFilter(filter)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .stroke(.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Supporting Views

struct LegendItem: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct StatisticItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// FilterChip уже определен в BookingHistoryView

// MARK: - AR Scene View
struct ARSceneView: UIViewRepresentable {
    let restaurant: Restaurant
    @Binding var selectedTable: Table?
    @Binding var showingTableInfo: Bool
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        
        // Настройка AR-сессии
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        arView.session.run(configuration)
        
        // Добавляем AR-содержимое
        setupARContent(arView)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Обновление AR-содержимого
    }
    
    private func setupARContent(_ arView: ARView) {
        // Здесь будет настройка AR-моделей ресторана
        // В реальном приложении это будут 3D-модели столиков, стен и т.д.
    }
}

// MARK: - Restaurant 3D Map View
struct Restaurant3DMapView: View {
    let restaurant: Restaurant
    let tables: [Table]
    @Binding var selectedTable: Table?
    
    var body: some View {
        ZStack {
            // 3D-карта ресторана
            GeometryReader { geometry in
                ZStack {
                    // Фоновая сетка
                    GridPattern()
                    
                    // Столики
                    ForEach(tables) { table in
                        Table3DView(
                            table: table,
                            isSelected: selectedTable?.id == table.id
                        ) {
                            selectedTable = table
                        }
                    }
                    
                    // Стены и перегородки
                    WallsView()
                    
                    // Декор
                    DecorView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - 3D Table View
struct Table3DView: View {
    let table: Table
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 3D-столик
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: tableColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: tableWidth, height: tableHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected ? .white : .clear,
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: tableShadowColor,
                        radius: isHovered ? 10 : 5,
                        x: 0,
                        y: isHovered ? 5 : 2
                    )
                    .scaleEffect(isHovered ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isHovered)
                
                // Информация о столике
                VStack(spacing: 4) {
                    Text("\(table.capacity)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("мест")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
        .position(tablePosition)
    }
    
    private var tableColors: [Color] {
        if table.isAvailable {
            return [.green, .green.opacity(0.8)]
        } else {
            return [.red, .red.opacity(0.8)]
        }
    }
    
    private var tableShadowColor: Color {
        if table.isAvailable {
            return .green.opacity(0.3)
        } else {
            return .red.opacity(0.3)
        }
    }
    
    private var tableWidth: CGFloat {
        switch table.capacity {
        case 1...2: return 40
        case 3...4: return 60
        case 5...6: return 80
        default: return 100
        }
    }
    
    private var tableHeight: CGFloat {
        switch table.capacity {
        case 1...2: return 40
        case 3...4: return 60
        case 5...6: return 80
        default: return 100
        }
    }
    
    private var tablePosition: CGPoint {
        // Позиция столика на карте
        // В реальном приложении это будет вычисляться на основе координат
        return CGPoint(x: 100, y: 100)
    }
}

// MARK: - Grid Pattern
struct GridPattern: View {
    var body: some View {
        Canvas { context, size in
            let gridSize: CGFloat = 20
            let rows = Int(size.height / gridSize)
            let cols = Int(size.width / gridSize)
            
            for row in 0...rows {
                let y = CGFloat(row) * gridSize
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    },
                    with: .color(.white.opacity(0.1)),
                    lineWidth: 0.5
                )
            }
            
            for col in 0...cols {
                let x = CGFloat(col) * gridSize
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    },
                    with: .color(.white.opacity(0.1)),
                    lineWidth: 0.5
                )
            }
        }
    }
}

// MARK: - Walls View
struct WallsView: View {
    var body: some View {
        // Стены ресторана
        // В реальном приложении это будут 3D-модели стен
        Rectangle()
            .fill(.clear)
            .overlay(
                Rectangle()
                    .stroke(.white.opacity(0.2), lineWidth: 2)
            )
    }
}

// MARK: - Decor View
struct DecorView: View {
    var body: some View {
        // Декор ресторана
        // В реальном приложении это будут 3D-модели декора
        EmptyView()
    }
}

// MARK: - Table Info View
struct TableInfoView: View {
    let table: Table
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.1, green: 0.1, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Заголовок
                Text("Информация о столике")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Детали столика
                VStack(spacing: 16) {
                    InfoRow(title: "Номер", value: "\(table.number)")
                    InfoRow(title: "Особенности", value: table.features.map { $0.displayName }.joined(separator: ", "))
                    InfoRow(title: "Мест", value: "\(table.capacity)")
                    InfoRow(title: "Расположение", value: table.location.displayName)
                    InfoRow(title: "Статус", value: table.isAvailable ? "Свободен" : "Занят")
                    
                    InfoRow(title: "Цена", value: "₽\(table.price)")
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
                
                // Особенности
                if !table.features.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Особенности")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(table.features, id: \.self) { feature in
                                Text(feature.displayName)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.blue.opacity(0.2))
                                    )
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.purple.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                Spacer()
                
                // Кнопка закрытия
                Button("Закрыть") {
                    dismiss()
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.blue)
                )
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}



// MARK: - Preview
#Preview {
    ARNavigationView(restaurant: Restaurant(
        id: "preview_1",
        name: "Le Petit Bistrot",
        description: "Уютный французский ресторан с традиционной кухней",
        cuisineType: .european,
        address: "ул. Тверская, 15",
        coordinates: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176),
        phoneNumber: "+7 (495) 123-45-67",
        website: "https://lepetitbistrot.ru",
        rating: 4.8,
        reviewCount: 156,
        priceRange: .high,
        workingHours: WorkingHours(),
        photos: ["restaurant1_1", "restaurant1_2"],
        isOpen: true,
        isVerified: true,
        ownerId: "owner1",
        subscriptionPlan: .premium,
        status: .active,
        features: [.wifi, .parking, .outdoorSeating, .`private`],
        tables: [],
        menu: Menu(),
        analytics: RestaurantAnalytics(),
        settings: RestaurantSettings()
    ))
        .preferredColorScheme(.dark)
}
