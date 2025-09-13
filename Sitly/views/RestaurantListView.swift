import SwiftUI
import MapKit

struct RestaurantListView: View {
    @StateObject private var viewModel: RestaurantListViewModel
    @State private var searchText = ""
    @State private var showMap = false
    @State private var selectedCuisine: String? = nil
    @State private var animateCards = false
    @State private var animateHeader = false
    
    private let cuisines = ["Все", "Итальянская", "Японская", "Русская", "Французская", "Азиатская"]
    
    init() {
        let container = DependencyContainer.shared
        
        self._viewModel = StateObject(wrappedValue: RestaurantListViewModel(
            restaurantUseCase: container.restaurantUseCase,
            locationUseCase: container.locationUseCase
        ))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Темный фон с градиентом
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.05, green: 0.05, blue: 0.08),
                        Color(red: 0.02, green: 0.02, blue: 0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Современный хедер
                    modernHeader
                    
                    // AI поисковая строка
                    aiSearchBar
                    
                    // Фильтры с неоморфизмом
                    modernFilterSection
                    
                    // AI Рекомендации
                    aiRecommendationsSection
                    
                    // Контент
                    if viewModel.isLoading {
                        modernLoadingView
                    } else if let errorMessage = viewModel.errorMessage {
                        modernErrorView(message: errorMessage)
                    } else if viewModel.restaurants.isEmpty {
                        modernEmptyStateView
                    } else {
                        if showMap {
                            modernMapView
                        } else {
                            modernRestaurantList
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
                                .onAppear {
                            Task {
                                await viewModel.loadRestaurants()
                                await viewModel.loadAIRecommendations()
                            }
                            startAnimations()
                        }
    }
    
    // MARK: - Современные компоненты
    
    private var modernHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Рестораны")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(animateHeader ? 1 : 0)
                        .offset(y: animateHeader ? 0 : 20)
                    
                    Text("Найди свой идеальный столик")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.mint.opacity(0.8), .green.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(animateHeader ? 1 : 0)
                        .offset(y: animateHeader ? 0 : 20)
                }
                
                Spacer()
                
                // Переключатель вида
                modernViewToggle
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateHeader)
    }
    
    private var modernViewToggle: some View {
        HStack(spacing: 8) {
            Button(action: { showMap = false }) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(showMap ? .gray : .white)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(showMap ? Color.clear : Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        showMap ? Color.clear : Color.white.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                    )
            }
            
            Button(action: { showMap = true }) {
                Image(systemName: "map")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(showMap ? .white : .gray)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(showMap ? Color.white.opacity(0.1) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        showMap ? Color.white.opacity(0.2) : Color.clear,
                                        lineWidth: 1
                                    )
                            )
                    )
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
    }
    
    private var modernSearchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
            
            TextField("Поиск ресторанов...", text: $searchText)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                                            .onChange(of: searchText) { _, _ in
                                Task {
                                    await viewModel.searchRestaurants()
                                }
                            }
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
                    private var modernFilterSection: some View {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(cuisines, id: \.self) { cuisine in
                                modernFilterButton(for: cuisine)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 16)
                }
                
                private func modernFilterButton(for cuisine: String) -> some View {
                    Button(action: {
                        selectedCuisine = cuisine == "Все" ? nil : cuisine
                        viewModel.filterByCuisine(selectedCuisine ?? "Все")
                    }) {
                        Text(cuisine)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(isCuisineSelected(cuisine) ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                                                                .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(
                                                isCuisineSelected(cuisine)
                                                ? AnyShapeStyle(LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing))
                                                : AnyShapeStyle(Color.clear)
                                            )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                isCuisineSelected(cuisine)
                                                ? Color.clear
                                                : Color.white.opacity(0.2),
                                                lineWidth: 1
                                            )
                                    )
                            )
                    }
                }
                
                private func isCuisineSelected(_ cuisine: String) -> Bool {
                    return selectedCuisine == cuisine || (cuisine == "Все" && selectedCuisine == nil)
                }
    
    private var modernRestaurantList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(viewModel.restaurants.enumerated()), id: \.element.id) { index, restaurant in
                    ModernRestaurantCard(restaurant: restaurant)
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 50)
                        .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: animateCards)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private var modernMapView: some View {
        Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.restaurants) { restaurant in
            MapAnnotation(coordinate: restaurant.coordinates) {
                VStack(spacing: 4) {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(colors: [.mint, .green], startPoint: .top, endPoint: .bottom)
                        )
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 32, height: 32)
                                .blur(radius: 5)
                        )
                        .shadow(color: .green.opacity(0.5), radius: 8, x: 0, y: 4)
                    
                    Text(restaurant.name)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.ultraThinMaterial)
                        )
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
    }
    
    private var modernLoadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .mint))
            
            Text("Загружаем рестораны...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func modernErrorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                )
            
            Text("Ошибка загрузки")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(message)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
                                    Button("Попробовать снова") {
                            Task {
                                await viewModel.loadRestaurants()
                            }
                        }
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing)
                    )
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
    
    private var modernEmptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(colors: [.mint.opacity(0.6), .green.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                )
            
            Text("Рестораны не найдены")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Попробуйте изменить параметры поиска")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.8)) {
            animateHeader = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.8)) {
                animateCards = true
            }
        }
    }
    
    // MARK: - AI Components
    
    private var aiSearchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(
                    LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                )
            
            TextField("Найди романтичное место до 3000₽ рядом", text: $searchText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                        .onChange(of: searchText) { newValue in
                    if newValue.count > 3 {
                        HapticService.shared.selection()
                        Task {
                            await viewModel.smartSearch(query: newValue)
                        }
                    } else if newValue.isEmpty {
                        Task {
                            await viewModel.loadRestaurants()
                        }
                    }
                }
            
            if !searchText.isEmpty {
                Button(action: { 
                    searchText = ""
                    Task {
                        await viewModel.loadRestaurants()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    private var aiRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                    )
                
                Text("AI рекомендует для вас")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                if viewModel.isLoadingAI {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                }
            }
            .padding(.horizontal, 20)
            
            if !viewModel.aiRecommendations.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(viewModel.aiRecommendations) { restaurant in
                            AIRecommendationCard(restaurant: restaurant)
                                .frame(width: 280)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            } else if !viewModel.isLoadingAI {
                Text("Загружаем персональные рекомендации...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.4), value: animateCards)
    }
    
    // modernErrorView уже определена выше
}

// MARK: - AI Recommendation Card
struct AIRecommendationCard: View {
    let restaurant: Restaurant
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Фото ресторана
            AsyncImage(url: URL(string: restaurant.photos.first ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .pink.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "fork.knife")
                            .font(.system(size: 24))
                            .foregroundColor(.purple.opacity(0.6))
                    )
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 8) {
                // AI Badge
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 12))
                        .foregroundColor(.purple)
                    
                    Text("AI РЕКОМЕНДУЕТ")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.purple)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                Text(restaurant.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(restaurant.cuisineType.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.purple.opacity(0.8))
                
                Text(restaurant.priceRange.range)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(colors: [.purple.opacity(0.4), .pink.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            HapticService.shared.aiRecommendation()
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                // Здесь будет навигация к деталям ресторана
            }
        }
    }
}

// MARK: - Современная карточка ресторана

struct ModernRestaurantCard: View {
    let restaurant: Restaurant
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
            VStack(alignment: .leading, spacing: 0) {
                // Изображение с неоморфизмом
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: restaurant.photos.first ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.gray.opacity(0.3), .gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .frame(height: 200)
                    .clipped()
                    
                    // Рейтинг
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(12)
                }
                
                // Информация
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(restaurant.name)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Text(restaurant.cuisineType.displayName)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing)
                                )
                        }
                        
                        Spacer()
                        
                        // Цена
                        Text("₽₽₽")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 12) {
                        // Расстояние
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.mint)
                            
                            Text("2.3 км")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        
                        // Время
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.mint)
                            
                            Text("25 мин")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Статус
                        Text("Открыто")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.green.opacity(0.2))
                            )
                    }
                }
                .padding(16)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Restaurant Map View

struct RestaurantMapView: View {
    let restaurants: [Restaurant]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173), // Москва
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: restaurants) { restaurant in
            MapAnnotation(coordinate: restaurant.coordinates) {
                VStack(spacing: 4) {
                    // Кастомная аннотация
                    ZStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 40, height: 40)
                            .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "fork.knife")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Название ресторана
                    Text(restaurant.name)
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            // Центрируем карту на ресторанах, если они есть
            if let firstRestaurant = restaurants.first {
                region.center = firstRestaurant.coordinates
            }
        }
    }
}

#Preview {
    RestaurantListView()
        .injectDependencies()
}

