import SwiftUI

struct RestaurantManagementView: View {
    @StateObject private var viewModel = RestaurantManagementViewModel()
    @State private var searchText = ""
    @State private var selectedFilter = "Все"
    @State private var showingNewRestaurant = false
    @State private var selectedRestaurant: Restaurant?
    
    private let filters = ["Все", "Активные", "На модерации", "Заблокированные"]
    
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
                
                VStack(spacing: 0) {
                    // Заголовок и поиск
                    headerSection
                    
                    // Фильтры
                    filterSection
                    
                    // Список ресторанов
                    restaurantsList
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadRestaurants()
        }
        .sheet(isPresented: $showingNewRestaurant) {
            NewRestaurantView()
        }
        .sheet(item: $selectedRestaurant) { restaurant in
            RestaurantDetailManagementView(restaurant: restaurant)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Управление ресторанами")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(viewModel.restaurants.count) заведений")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: { showingNewRestaurant = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("Добавить")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            // Поисковая строка
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                
                TextField("Поиск ресторанов...", text: $searchText)
                    .foregroundColor(.white)
                    .accentColor(.blue)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filters, id: \.self) { filter in
                    Button(action: { selectedFilter = filter }) {
                        Text(filter)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedFilter == filter ? .black : .white.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedFilter == filter ? .white : .clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Restaurants List
    private var restaurantsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredRestaurants, id: \.id) { restaurant in
                    RestaurantManagementCard(
                        restaurant: restaurant,
                        onTap: { selectedRestaurant = restaurant },
                        onToggleStatus: { viewModel.toggleRestaurantStatus(restaurant) },
                        onEdit: { selectedRestaurant = restaurant },
                        onDelete: { viewModel.deleteRestaurant(restaurant) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var filteredRestaurants: [Restaurant] {
        var restaurants = viewModel.restaurants
        
        // Фильтр по статусу
        if selectedFilter != "Все" {
            restaurants = restaurants.filter { restaurant in
                switch selectedFilter {
                case "Активные": return restaurant.status == .active
                case "На модерации": return restaurant.status == .pending
                case "Заблокированные": return restaurant.status == .suspended
                default: return true
                }
            }
        }
        
        // Поиск
        if !searchText.isEmpty {
            restaurants = restaurants.filter { restaurant in
                restaurant.name.localizedCaseInsensitiveContains(searchText) ||
                restaurant.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return restaurants
    }
}

// MARK: - Restaurant Management Card
struct RestaurantManagementCard: View {
    let restaurant: Restaurant
    let onTap: () -> Void
    let onToggleStatus: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Основная информация
            HStack(spacing: 16) {
                // Изображение ресторана
                AsyncImage(url: URL(string: restaurant.photos.first ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Image(systemName: "building.2.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.6))
                        )
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Информация
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(restaurant.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Статус
                        AdminStatusBadge(status: restaurant.status)
                    }
                    
                    Text(restaurant.cuisineType.displayName)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(restaurant.address)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                    
                    HStack {
                        // Рейтинг
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        // Подписка
                        Text(restaurant.subscriptionPlan.adminDisplayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(restaurant.subscriptionPlan.adminColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(restaurant.subscriptionPlan.adminColor.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
            
            // Действия
            HStack(spacing: 12) {
                // Переключить статус
                Button(action: onToggleStatus) {
                    HStack(spacing: 6) {
                        Image(systemName: restaurant.status == .active ? "pause.fill" : "play.fill")
                        Text(restaurant.status == .active ? "Приостановить" : "Активировать")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(restaurant.status == .active ? .orange : .green)
                    .cornerRadius(8)
                }
                
                // Редактировать
                Button(action: onEdit) {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                        Text("Изменить")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.blue)
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Удалить
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(.red)
                        .cornerRadius(8)
                }
            }
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
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Admin Status Badge
struct AdminStatusBadge: View {
    let status: RestaurantStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status.adminColor)
                .frame(width: 6, height: 6)
            
            Text(status.adminDisplayName)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(status.adminColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.adminColor.opacity(0.2))
        .cornerRadius(8)
    }
}

// MARK: - Supporting Views
struct NewRestaurantView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("Добавление нового ресторана")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                    
                    Text("Форма добавления ресторана будет здесь")
                        .foregroundColor(.white.opacity(0.7))
                        .padding()
                    
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
                    Button("Сохранить") { dismiss() }
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct RestaurantDetailManagementView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Управление рестораном")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text(restaurant.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Детальная информация и настройки ресторана")
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    RestaurantManagementView()
}
