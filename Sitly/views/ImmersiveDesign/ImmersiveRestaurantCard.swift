import SwiftUI
import CoreLocation

struct ImmersiveRestaurantCard: View {
    let restaurant: Restaurant
    @State private var isPressed = false
    @State private var dragOffset = CGSize.zero
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Основная карточка с неоморфизмом
            mainCard
            
            // 3D-эффекты и параллакс
            parallaxElements
            
            // Световые эффекты
            lightEffects
            
            // Интерактивные элементы
            interactiveElements
        }
        .frame(height: 280)
        .scaleEffect(scale)
        .rotation3DEffect(
            .degrees(rotationAngle),
            axis: (x: dragOffset.height / 20, y: -dragOffset.width / 20, z: 0)
        )
        .offset(dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    handleDrag(value)
                }
                .onEnded { _ in
                    animateToRest()
                }
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isPressed.toggle()
                scale = isPressed ? 0.95 : 1.0
            }
        }
        .onAppear {
            startAmbientAnimation()
        }
    }
    
    // MARK: - Main Card
    private var mainCard: some View {
        VStack(spacing: 0) {
            // Изображение ресторана с параллаксом
            ZStack {
                // Фоновое изображение
                AsyncImage(url: URL(string: restaurant.photos.first ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .frame(height: 160)
                .clipped()
                .overlay(
                    // Градиентный оверлей
                    LinearGradient(
                        colors: [
                            .clear,
                            .black.opacity(0.3),
                            .black.opacity(0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Рейтинг с неоморфизмом
                VStack {
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [.yellow, .orange],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(
                                    color: .yellow.opacity(0.3),
                                    radius: 10,
                                    x: 0,
                                    y: 0
                                )
                            
                            VStack(spacing: 2) {
                                Text(String(format: "%.1f", restaurant.rating))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                            }
                        }
                        .offset(x: -10, y: 10)
                    }
                    
                    Spacer()
                }
                
                // Статус ресторана
                VStack {
                    HStack {
                        ZStack {
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .frame(width: 80, height: 30)
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            restaurant.isOpen ? .green : .red,
                                            lineWidth: 1
                                        )
                                )
                                .shadow(
                                    color: restaurant.isOpen ? .green.opacity(0.3) : .red.opacity(0.3),
                                    radius: 8,
                                    x: 0,
                                    y: 0
                                )
                            
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(restaurant.isOpen ? .green : .red)
                                    .frame(width: 6, height: 6)
                                
                                Text(restaurant.isOpen ? "Открыто" : "Закрыто")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        .offset(x: 10, y: 10)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
            
            // Информация о ресторане
            VStack(alignment: .leading, spacing: 12) {
                // Название и кухня
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(restaurant.cuisineType.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.green.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(.green.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        
                        Text(restaurant.priceRange.range)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                // Дополнительная информация
                HStack(spacing: 16) {
                    // Расстояние
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("2.3 км")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Время в пути
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text("25 мин")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Особенности
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        
                        Text("\(restaurant.features.prefix(2).map { $0.displayName }.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .purple.opacity(0.5),
                                    .blue.opacity(0.5),
                                    .green.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: .purple.opacity(0.3),
            radius: 20,
            x: 0,
            y: 10
        )
    }
    
    // MARK: - Parallax Elements
    private var parallaxElements: some View {
        ZStack {
            // Плавающие иконки
            ForEach(0..<3) { index in
                Image(systemName: ["leaf.fill", "sparkles", "heart.fill"][index])
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.3))
                    .offset(
                        x: CGFloat(index * 20) + dragOffset.width * 0.1,
                        y: CGFloat(index * -15) + dragOffset.height * 0.1
                    )
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: dragOffset)
            }
            
            // Градиентные круги
            ForEach(0..<2) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .purple.opacity(0.2),
                                .blue.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat(60 + index * 40))
                    .blur(radius: 20)
                    .offset(
                        x: CGFloat(index * 30) + dragOffset.width * 0.05,
                        y: CGFloat(index * -20) + dragOffset.height * 0.05
                    )
            }
        }
    }
    
    // MARK: - Light Effects
    private var lightEffects: some View {
        ZStack {
            // Свечение по краям
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            .purple.opacity(glowIntensity * 0.3),
                            .blue.opacity(glowIntensity * 0.3),
                            .green.opacity(glowIntensity * 0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blur(radius: 30)
                .scaleEffect(1.1)
            
            // Точечные источники света
            ForEach(0..<4) { index in
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 4, height: 4)
                    .blur(radius: 2)
                    .offset(
                        x: CGFloat(index * 40 - 60) + dragOffset.width * 0.02,
                        y: CGFloat(index * 20 - 40) + dragOffset.height * 0.02
                    )
            }
        }
    }
    
    // MARK: - Interactive Elements
    private var interactiveElements: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                // Кнопка "Забронировать" с неоморфизмом
                Button(action: {
                    // Действие бронирования
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.caption)
                        
                        Text("Забронировать")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .shadow(
                        color: .green.opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .offset(x: -16, y: -16)
            }
        }
    }
    
    // MARK: - Gesture Handling
    private func handleDrag(_ value: DragGesture.Value) {
        dragOffset = value.translation
        
        // Вычисляем угол поворота
        rotationAngle = Double(dragOffset.width / 10)
        
        // Вычисляем масштаб
        let dragDistance = sqrt(dragOffset.width * dragOffset.width + dragOffset.height * dragOffset.height)
        scale = 1.0 + dragDistance / 1000
        
        // Вычисляем интенсивность свечения
        glowIntensity = min(dragDistance / 200, 1.0)
    }
    
    private func animateToRest() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            dragOffset = .zero
            rotationAngle = 0
            scale = 1.0
            glowIntensity = 0.0
        }
    }
    
    // MARK: - Ambient Animation
    private func startAmbientAnimation() {
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            glowIntensity = 0.3
        }
    }
}



// MARK: - Preview
#Preview {
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
        
        // Моковый ресторан для превью
        let mockRestaurant = Restaurant(
            id: "1",
            name: "White Rabbit",
            description: "Элитный ресторан европейской кухни",
            cuisineType: .european,
            address: "Смоленская пл., 3, Москва",
            coordinates: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176),
            phoneNumber: "+7 (495) 123-45-67",
            rating: 4.8,
            reviewCount: 1250,
            priceRange: .high,
            workingHours: WorkingHours(),
            photos: [],
            isOpen: true,
            isVerified: true,
            ownerId: "owner1"
        )
        
        ImmersiveRestaurantCard(restaurant: mockRestaurant)
            .padding(.horizontal, 20)
    }
    .preferredColorScheme(.dark)
}
