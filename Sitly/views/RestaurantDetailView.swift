import SwiftUI
import CoreLocation

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @StateObject private var viewModel: RestaurantDetailViewModel
    @State private var selectedTab = 0
    @State private var animateHeader = false
    @State private var animateContent = false
    @State private var showBooking = false
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        let reviewUseCase = ReviewUseCase(
            repository: ReviewRepository(
                networkService: NetworkService(),
                storageService: StorageService()
            ),
            restaurantRepository: RestaurantRepository(
                networkService: NetworkService(),
                storageService: StorageService(),
                cacheService: CacheService(storageService: StorageService())
            )
        )
        let bookingUseCase = BookingUseCase(
            repository: BookingRepository(
                networkService: NetworkService(),
                storageService: StorageService()
            ),
            restaurantRepository: RestaurantRepository(
                networkService: NetworkService(),
                storageService: StorageService(),
                cacheService: CacheService(storageService: StorageService())
            )
        )
        
        self._viewModel = StateObject(wrappedValue: RestaurantDetailViewModel(
            restaurant: restaurant,
            reviewUseCase: reviewUseCase,
            bookingUseCase: bookingUseCase
        ))
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 0) {
                    modernHeaderSection
                    modernInfoSection
                    modernBookingButtonSection
                    modernTabContentSection
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            startAnimations()
        }
        .fullScreenCover(isPresented: $showBooking) {
            BookingView(restaurant: restaurant)
        }
    }
    
    private var backgroundGradient: some View {
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
    }
    
    private var modernHeaderSection: some View {
        ZStack {
            headerImage
            headerOverlay
            headerIndicators
            headerButtons
        }
        .frame(height: 300)
        .animation(.easeOut(duration: 0.8), value: animateHeader)
    }
    
    private var headerImage: some View {
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
        .frame(height: 300)
        .clipped()
        .offset(y: animateHeader ? 0 : -20)
    }
    
    private var headerOverlay: some View {
        LinearGradient(
            colors: [
                .black.opacity(0.7),
                .black.opacity(0.3),
                .clear,
                .black.opacity(0.8)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 300)
    }
    
    private var headerIndicators: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                ForEach(0..<min(restaurant.photos.count, 5), id: \.self) { index in
                    Circle()
                        .fill(index == 0 ? .white : .white.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    private var headerButtons: some View {
        VStack {
            HStack {
                backButton
                Spacer()
                heartButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            Spacer()
        }
    }
    
    private var backButton: some View {
        Button(action: {}) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
    }
    
    private var heartButton: some View {
        Button(action: {}) {
            Image(systemName: "heart")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
    }
    
    private var modernInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                restaurantInfo
                Spacer()
                ratingInfo
            }
            VStack(spacing: 12) {
                modernDetailRow(icon: "location.fill", title: "Адрес", value: restaurant.address)
                modernDetailRow(icon: "clock.fill", title: "Часы работы", value: "Ежедневно 09:00-22:00")
                modernDetailRow(icon: "creditcard.fill", title: "Средний чек", value: "от \(restaurant.priceRange.displayName) ₽")
                modernDetailRow(icon: "chair.lounge.fill", title: "Доступные столики", value: "\(restaurant.tables.count) мест")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
    }
    
    private var restaurantInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(restaurant.name)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
            
            Text(restaurant.cuisineType.displayName)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing)
                )
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
        }
    }
    
    private var ratingInfo: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)
                
                Text(String(format: "%.1f", restaurant.rating))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text("\(viewModel.reviews.count) отзывов")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
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
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    private func modernDetailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.mint)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var modernBookingButtonSection: some View {
        VStack(spacing: 16) {
            Button(action: { showBooking = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Забронировать столик")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing)
                        )
                        .shadow(color: .green.opacity(0.3), radius: 15, x: 0, y: 8)
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    private var modernTabContentSection: some View {
        VStack(spacing: 20) {
            modernTabBar
            TabView(selection: $selectedTab) {
                ModernMenuSection(restaurant: restaurant)
                    .tag(0)
                
                ModernReviewsSection(reviews: viewModel.reviews)
                    .tag(1)
                
                ModernPhotosSection(photos: restaurant.photos)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .padding(.top, 20)
    }
    
    private var modernTabBar: some View {
        HStack(spacing: 0) {
            ForEach(["Меню", "Отзывы", "Фото"], id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = ["Меню", "Отзывы", "Фото"].firstIndex(of: tab) ?? 0
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(tab)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(selectedTab == ["Меню", "Отзывы", "Фото"].firstIndex(of: tab) ? .white : .gray)
                        
                        Rectangle()
                            .fill(selectedTab == ["Меню", "Отзывы", "Фото"].firstIndex(of: tab) ? Color.mint : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.8)) {
            animateHeader = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.8)) {
                animateContent = true
            }
        }
    }
}

// MARK: - Современные секции

struct ModernMenuSection: View {
    let restaurant: Restaurant
    @State private var animateDishes = false
    
    private let dishes = [
        ("Паста Карбонара", "Классическая итальянская паста с беконом и сливочным соусом", "1200 ₽", "🍝"),
        ("Стейк Рибай", "Сочный стейк из мраморной говядины с овощами гриль", "2800 ₽", "🥩"),
        ("Тирамису", "Нежный десерт с кофе и маскарпоне", "450 ₽", "🍰"),
        ("Маргарита", "Традиционная пицца с томатами и моцареллой", "850 ₽", "🍕")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Популярные блюда")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            LazyVStack(spacing: 16) {
                ForEach(Array(dishes.enumerated()), id: \.offset) { index, dish in
                    ModernDishCard(
                        name: dish.0,
                        description: dish.1,
                        price: dish.2,
                        emoji: dish.3
                    )
                    .opacity(animateDishes ? 1 : 0)
                    .offset(y: animateDishes ? 0 : 30)
                    .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: animateDishes)
                }
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateDishes = true
            }
        }
    }
}

struct ModernDishCard: View {
    let name: String
    let description: String
    let price: String
    let emoji: String
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 32))
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(price)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing)
                )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
}

struct ModernReviewsSection: View {
    let reviews: [Review]
    @State private var animateReviews = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Отзывы")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            if reviews.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "message.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(colors: [.mint.opacity(0.6), .green.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                        )
                    
                    Text("Отзывов пока нет")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Будьте первым, кто оставит отзыв")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(Array(reviews.enumerated()), id: \.element.id) { index, review in
                        ModernReviewCard(review: review)
                            .opacity(animateReviews ? 1 : 0)
                            .offset(y: animateReviews ? 0 : 30)
                            .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: animateReviews)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateReviews = true
            }
        }
    }
}

struct ModernReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            reviewHeader
            reviewText
        }
        .padding(16)
        .background(reviewBackground)
    }
    
    private var reviewHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Пользователь")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                reviewStars
            }
            
            Spacer()
            
            Text(review.createdAt, style: .date)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
    }
    
    private var reviewStars: some View {
        HStack(spacing: 4) {
                                    ForEach(0..<5, id: \.self) { index in
                            Image(systemName: index < Int(review.rating) ? "star.fill" : "star")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                        }
        }
    }
    
    private var reviewText: some View {
        Text(review.text)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(.white.opacity(0.9))
            .lineLimit(3)
    }
    
    private var reviewBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

struct ModernPhotosSection: View {
    let photos: [String]
    @State private var animatePhotos = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Фотографии")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                    AsyncImage(url: URL(string: photo)) { image in
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
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .opacity(animatePhotos ? 1 : 0)
                    .offset(y: animatePhotos ? 0 : 30)
                    .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: animatePhotos)
                }
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatePhotos = true
            }
        }
    }
}

#Preview {
    NavigationView {
        RestaurantDetailView(restaurant: Restaurant(
            id: "preview-pushkin",
            name: "Pushkin",
            description: "Это культовое заведение, известное своим роскошным интерьером в стиле дворянской усадьбы XIX века и изысканной русской кухней.",
            cuisineType: .russian,
            address: "Тверской бул., 26А, Москва",
            coordinates: CLLocationCoordinate2D(latitude: 55.7652, longitude: 37.6041),
            phoneNumber: "+7 (495) 123-45-67",
            ownerId: "preview-owner"
        ))
    }
    .injectDependencies()
} 