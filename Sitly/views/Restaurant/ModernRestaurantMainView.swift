//
//  ModernRestaurantMainView.swift
//  Sitly
//
//  Created by AI Assistant on 12.09.2025.
//

import SwiftUI
import FirebaseFirestore
import Combine
import CoreLocation

extension Foundation.Notification.Name {
    static let restaurantCreated = Foundation.Notification.Name("restaurantCreated")
}

struct ModernRestaurantMainView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var tabOffset: CGFloat = 0
    @State private var isGlowing = false
    @State private var restaurantName = "Ресторан"
    @State private var restaurantInfo: RestaurantModel? = nil
    
    var body: some View {
        ZStack {
            // Современный градиентный фон 2026
            backgroundGradient
            
            VStack(spacing: 0) {
                // Современный заголовок с эффектом стекла
                modernHeader
                
                // Основной контент
                TabView(selection: $selectedTab) {
                    // Dashboard 2026
                    ModernDashboardView(selectedTab: $selectedTab)
                        .tag(0)
                    
                    // Управление столиками
                    TablesManagementView()
                        .tag(1)
                    
                    // Бронирования
                    ModernBookingsView()
                        .tag(2)
                    
                    // AI Помощник
                    ModernAIAssistantView()
                        .tag(3)
                    
                    // Профиль ресторана
                    ModernRestaurantProfileView(restaurantName: restaurantName, restaurantInfo: restaurantInfo)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Кастомная таб-бар 2026
                modernTabBar
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isGlowing.toggle()
            }
            
            // Загружаем название ресторана и данные
            loadRestaurantName()
            loadRestaurantInfo()
        }
        .onChange(of: appState.currentUser?.id) { _, _ in
            // Обновляем название и данные при смене пользователя
            loadRestaurantName()
            loadRestaurantInfo()
        }
        .onReceive(NotificationCenter.default.publisher(for: Foundation.Notification.Name.restaurantCreated)) { _ in
            // Обновляем название и данные после создания ресторана
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                loadRestaurantName()
                loadRestaurantInfo()
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadRestaurantName() {
        Task {
            guard let userId = appState.currentUser?.id else { return }
            
            do {
                print("🔍 Загружаем название ресторана для пользователя: \(userId)")
                
                // Загружаем напрямую из Firestore (как сохраняется)
                let db = Firestore.firestore()
                let snapshot = try await db.collection("restaurants")
                    .whereField("ownerId", isEqualTo: userId)
                    .getDocuments()
                
                print("📊 Найдено документов в Firestore: \(snapshot.documents.count)")
                
                if let firstDoc = snapshot.documents.first {
                    do {
                            let restaurantData = try firstDoc.data(as: RestaurantModel.self)
                        print("✅ Найден ресторан в Firestore: \(restaurantData.name)")
                        await MainActor.run {
                            restaurantName = restaurantData.name
                        }
                    } catch {
                        print("❌ Ошибка парсинга ресторана: \(error)")
                    }
                } else {
                    print("❌ Ресторан не найден в Firestore для пользователя")
                }
            } catch {
                print("❌ Ошибка загрузки названия ресторана: \(error)")
            }
        }
    }
    
    private func loadRestaurantInfo() {
        Task {
            do {
                print("🔍 Загружаем информацию о ресторане для пользователя: \(appState.currentUser?.id ?? "НЕТ ID")")
                
                // Загружаем напрямую из Firestore (как сохраняется)
                let db = Firestore.firestore()
                let snapshot = try await db.collection("restaurants")
                    .whereField("ownerId", isEqualTo: appState.currentUser?.id ?? "")
                    .getDocuments()
                
                print("📊 Найдено документов в Firestore: \(snapshot.documents.count)")
                
                // Дополнительная отладка
                for (index, doc) in snapshot.documents.enumerated() {
                    print("📄 Документ \(index): \(doc.documentID)")
                    print("📄 Данные: \(doc.data())")
                }
                
                await MainActor.run {
                    if let firstDoc = snapshot.documents.first {
                        do {
                            // Парсим данные вручную из нового формата
                            let data = firstDoc.data()
                            let restaurantData = RestaurantModel(
                                id: data["id"] as? String ?? "",
                                name: data["name"] as? String ?? "",
                                description: data["description"] as? String ?? "",
                                cuisineType: CuisineType(rawValue: data["cuisineType"] as? String ?? "european") ?? .european,
                                address: data["address"] as? String ?? "",
                                coordinates: CLLocationCoordinate2D(
                                    latitude: data["latitude"] as? Double ?? 0.0,
                                    longitude: data["longitude"] as? Double ?? 0.0
                                ),
                                phoneNumber: data["phoneNumber"] as? String ?? "",
                                priceRange: PriceRange(rawValue: data["priceRange"] as? String ?? "medium") ?? .medium,
                                workingHours: WorkingHours(), // Упрощаем для тестирования
                                ownerId: data["ownerId"] as? String ?? "",
                                status: RestaurantStatus(rawValue: data["status"] as? String ?? "pending") ?? .pending
                            )
                            print("✅ Найден ресторан в Firestore: \(restaurantData.name)")
                            print("✅ Данные ресторана: \(restaurantData)")
                            restaurantInfo = restaurantData
                        } catch {
                            print("❌ Ошибка парсинга ресторана: \(error)")
                            print("❌ Сырые данные документа: \(firstDoc.data())")
                            restaurantInfo = nil
                        }
                    } else {
                        print("❌ Ресторан не найден в Firestore для пользователя")
                        restaurantInfo = nil
                    }
                }
            } catch {
                print("❌ Ошибка загрузки информации о ресторане: \(error)")
                await MainActor.run {
                    restaurantInfo = nil
                }
            }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            // Основной градиент
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.08, blue: 0.2),
                    Color(red: 0.15, green: 0.1, blue: 0.25),
                    Color(red: 0.08, green: 0.12, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Динамические блики
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.purple.opacity(isGlowing ? 0.3 : 0.1),
                            Color.clear
                        ],
                        center: .topTrailing,
                        startRadius: 50,
                        endRadius: 300
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: 150, y: -200)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isGlowing)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.blue.opacity(isGlowing ? 0.2 : 0.05),
                            Color.clear
                        ],
                        center: .bottomLeading,
                        startRadius: 30,
                        endRadius: 250
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: -100, y: 150)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isGlowing)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Header
    private var modernHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Добро пожаловать!")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(restaurantName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .purple.opacity(0.8), .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            Spacer()
            
            
            // Уведомления
            Button(action: {
                HapticService.shared.buttonPress()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                    
                    // Бейдж уведомлений
                    Circle()
                        .fill(Color.red)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Text("3")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                        .offset(x: 15, y: -15)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Modern Tab Bar
    private var modernTabBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<5) { index in
                tabBarItem(for: index)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Glassmorphism эффект
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear,
                                        Color.purple.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                // Плавающий индикатор
                HStack {
                    ForEach(0..<5) { index in
                        if index == selectedTab {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 40, height: 4)
                                .offset(y: -28)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTab)
                        } else {
                            Color.clear.frame(width: 40, height: 4)
                        }
                        
                        if index < 4 {
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 30)
            }
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 34)
    }
    
    private func tabBarItem(for index: Int) -> some View {
        let tabItems = [
            ("chart.bar.fill", "Дашборд"),
            ("tablecells.fill", "Столики"),
            ("calendar.badge.plus", "Брони"),
            ("brain.head.profile", "AI"),
            ("building.2.fill", "Профиль")
        ]
        
        let isSelected = selectedTab == index
        
        return Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                selectedTab = index
            }
            HapticService.shared.selection()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                    }
                    
                    Image(systemName: tabItems[index].0)
                        .font(.system(size: isSelected ? 20 : 18, weight: .medium))
                        .foregroundStyle(
                            isSelected ? 
                            LinearGradient(
                                colors: [.white, .purple.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            ) :
                            LinearGradient(
                                colors: [.white.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                
                Text(tabItems[index].1)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                    .scaleEffect(isSelected ? 1.0 : 0.9)
            }
            .frame(maxWidth: .infinity)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Modern Dashboard View
struct ModernDashboardView: View {
    @Binding var selectedTab: Int
    @State private var animateCards = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Быстрые действия 2026
                modernQuickActions
                
                // Статистика с AI
                modernStatsSection
                
                // AI-аналитика
                modernAIAnalytics
                
                // Уведомления и алерты
                modernNotifications
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                animateCards = true
            }
        }
    }
    
    private var modernQuickActions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Быстрые действия")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                quickActionCard(
                    title: "Подтвердить все",
                    subtitle: "0 броней",
                    icon: "checkmark.circle.fill",
                    gradient: [.green, .mint],
                    index: 0,
                    action: {
                        // Переключиться на таб бронирований
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            self.selectedTab = 2
                        }
                    }
                )
                
                quickActionCard(
                    title: "Новое\nбронирование",
                    subtitle: "Создать вручную",
                    icon: "plus.circle.fill",
                    gradient: [.blue, .cyan],
                    index: 1,
                    action: {
                        // Переключиться на таб бронирований
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            self.selectedTab = 2
                        }
                    }
                )
                
                quickActionCard(
                    title: "Изменить статус",
                    subtitle: "Открыто/Закрыто",
                    icon: "power.circle.fill",
                    gradient: [.orange, .yellow],
                    index: 2,
                    action: {
                        // Переключиться на таб профиля для изменения статуса
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            self.selectedTab = 4
                        }
                    }
                )
                
                quickActionCard(
                    title: "AI-помощник",
                    subtitle: "Получить советы",
                    icon: "brain.head.profile",
                    gradient: [.purple, .pink],
                    index: 3,
                    action: {
                        // Переключиться на таб AI
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            self.selectedTab = 3
                        }
                    }
                )
            }
        }
    }
    
    private func quickActionCard(title: String, subtitle: String, icon: String, gradient: [Color], index: Int, action: @escaping () -> Void = {}) -> some View {
        Button(action: {
            HapticService.shared.buttonPress()
            action()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(16)
            .frame(height: 120)
            .background(
                ZStack {
                    // Glassmorphism
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.3))
                    
                    // Градиент оверлей
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(0.1) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Обводка
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.clear,
                                    gradient.first?.opacity(0.3) ?? Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .scaleEffect(animateCards ? 1.0 : 0.8)
            .opacity(animateCards ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateCards)
        }
    }
    
    private var modernStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Сегодня в цифрах")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                statCard(title: "Новых броней", value: "0", change: "+0%", color: .blue, index: 4)
                statCard(title: "Подтверждено", value: "0", change: "0%", color: .green, index: 5)
                statCard(title: "Ожидает", value: "0", change: "", color: .orange, index: 6)
                statCard(title: "Выручка", value: "₽0", change: "+0%", color: .purple, index: 7)
            }
        }
    }
    
    private func statCard(title: String, value: String, change: String, color: Color, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                if !change.isEmpty {
                    Text(change)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(change.hasPrefix("+") ? .green : .red)
                }
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.3))
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.1), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
        )
        .scaleEffect(animateCards ? 1.0 : 0.8)
        .opacity(animateCards ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateCards)
    }
    
    private var modernAIAnalytics: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI-аналитика")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                aiRecommendationCard(
                    title: "Оптимизация столиков",
                    description: "AI рекомендует переместить VIP-столики ближе к окну для увеличения выручки на 15%",
                    confidence: "87%",
                    action: "Применить"
                )
                
                aiRecommendationCard(
                    title: "Предсказание отмен",
                    description: "Высокий риск отмены для брони в 21:00 (гость часто отменяет)",
                    confidence: "73%",
                    action: "Применить"
                )
            }
        }
    }
    
    private func aiRecommendationCard(title: String, description: String, confidence: String, action: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(confidence)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.purple.opacity(0.2))
                    )
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(nil)
            
            Button(action: {
                HapticService.shared.buttonPress()
            }) {
                Text(action)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
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
                            colors: [.purple.opacity(0.1), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
    }
    
    private var modernNotifications: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Уведомления")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                notificationCard(
                    title: "Новое бронирование",
                    description: "Столик на 4 персоны забронирован на 19:00",
                    time: "in 0 sec",
                    icon: "calendar.badge.plus",
                    color: .blue
                )
                
                notificationCard(
                    title: "Отмена брони",
                    description: "Бронирование на 20:30 отменено",
                    time: "1 hr ago",
                    icon: "xmark.circle",
                    color: .red
                )
                
                notificationCard(
                    title: "AI-рекомендация",
                    description: "Оптимизация столиков может увеличить выручку на 15%",
                    time: "2 hr ago",
                    icon: "brain.head.profile",
                    color: .purple
                )
            }
        }
    }
    
    private func notificationCard(title: String, description: String, time: String, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(time)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Placeholder Views для других табов
struct ModernBookingsView: View {
    var body: some View {
        BookingsManagementView()    }
}

struct ModernAIAssistantView: View {
    var body: some View {
        AIAssistantView()
    }
}

struct ModernRestaurantProfileView: View {
    let restaurantName: String
    let restaurantInfo: RestaurantModel?
    @EnvironmentObject var appState: AppState
    @State private var showingLogoutAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Заголовок профиля
                profileHeader
                
                // Информация о ресторане
                restaurantInfoSection
                
                // Настройки
                settingsSection
                
                // Кнопка выхода
                logoutSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
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
        .alert("Выйти из аккаунта", isPresented: $showingLogoutAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Выйти", role: .destructive) {
                appState.logout()
            }
        } message: {
            Text("Вы уверены, что хотите выйти из аккаунта?")
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Аватар ресторана
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.8), .blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "building.2")
                        .font(.title)
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 4) {
                Text("Профиль ресторана")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(restaurantName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .purple.opacity(0.8), .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Управление настройками")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var restaurantInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Информация о ресторане")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                infoRow(title: "Название", value: restaurantInfo?.name ?? "Не указано")
                infoRow(title: "Кухня", value: restaurantInfo?.cuisineType.displayName ?? "Не указано")
                infoRow(title: "Адрес", value: restaurantInfo?.address ?? "Не указано")
                infoRow(title: "Телефон", value: restaurantInfo?.phoneNumber ?? "Не указано")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Настройки")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                settingsRow(icon: "bell.fill", title: "Уведомления", color: .orange)
                settingsRow(icon: "location.fill", title: "Геолокация", color: .green)
                settingsRow(icon: "paintbrush.fill", title: "Тема приложения", color: .purple)
                settingsRow(icon: "questionmark.circle.fill", title: "Помощь", color: .blue)
                settingsRow(icon: "gear", title: "Общие настройки", color: .gray)
                settingsRow(icon: "creditcard", title: "Платежи", color: .green)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var logoutSection: some View {
        Button(action: {
            HapticService.shared.buttonPress()
            showingLogoutAlert = true
        }) {
            HStack {
                Image(systemName: "power")
                    .font(.title3)
                
                Text("Выйти из аккаунта")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.red, lineWidth: 1)
                    )
            )
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
    
    private func settingsRow(icon: String, title: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.vertical, 4)
    }
    
}

#Preview {
    ModernRestaurantMainView()
        .environmentObject(AppState(
            userUseCase: DependencyContainer.shared.userUseCase,
            storageService: DependencyContainer.shared.storageService
        ))
}
