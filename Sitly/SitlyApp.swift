//
//  SitlyApp.swift
//  Sitly
//
//  Created by Maxim Gotovchenko on 24.06.2025.
//

import SwiftUI
import Firebase

@main
struct SitlyApp: App {
    @StateObject private var appState = AppState(
        userUseCase: DependencyContainer.shared.userUseCase,
        storageService: DependencyContainer.shared.storageService
    )
    
    init() {
        print("🚀 SitlyApp: ИНИЦИАЛИЗАЦИЯ ПРИЛОЖЕНИЯ")
        FirebaseApp.configure()
        print("🔥 Firebase: НАСТРОЕН")
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isAuthenticated {
                    if let user = appState.currentUser {
                        switch user.role {
                        case .client:
                            ClientMainView()
                                .environmentObject(appState)
                        case .restaurant:
                            ModernRestaurantMainView()
                                .environmentObject(appState)
                        }
                    } else {
                        LoadingView()
                    }
                } else {
                    WelcomeView()
                        .environmentObject(appState)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Client Main View
struct ClientMainView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Главная страница
            RestaurantListView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }
                .tag(0)
            
            // Поиск
            Text("Поиск")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Поиск")
                }
                .tag(1)
            
            // Бронирования
            BookingHistoryView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Бронирования")
                }
                .tag(2)
            
            // Профиль
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
                .tag(3)
        }
        .accentColor(.orange)
    }
}

// MARK: - Restaurant Main View
struct RestaurantMainView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Дашборд
            RestaurantDashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Дашборд")
                }
                .tag(0)
            
            // Бронирования
            Text("Бронирования")
                .tabItem {
                    Image(systemName: "calendar.badge.plus")
                    Text("Бронирования")
                }
                .tag(1)
            
            // Меню
            Text("Меню")
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Меню")
                }
                .tag(2)
            
            // AI-помощник
            AIAssistantView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("AI-помощник")
                }
                .tag(3)
            
            // Профиль
            Text("Профиль")
                .tabItem {
                    Image(systemName: "building.2.fill")
                    Text("Профиль")
                }
                .tag(4)
        }
        .accentColor(.purple)
    }
}

// MARK: - Admin Main View
struct AdminMainView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Админ-панель
            AdminDashboardView()
                .tabItem {
                    Image(systemName: "shield.fill")
                    Text("Дашборд")
                }
                .tag(0)
            
            // Управление ресторанами
            RestaurantManagementView()
                .tabItem {
                    Image(systemName: "building.2.fill")
                    Text("Рестораны")
                }
                .tag(1)
            
            // Пользователи
            UserManagementView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Пользователи")
                }
                .tag(2)
            
            // Аналитика
            AdminAnalyticsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Аналитика")
                }
                .tag(3)
            
            // Настройки
            AdminSettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Настройки")
                }
                .tag(4)
        }
        .accentColor(.red)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
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
            
            VStack(spacing: 30) {
                // Логотип с анимацией
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple, .green],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(
                            .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    Image(systemName: "fork.knife")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                
                // Название приложения
                Text("Sitly")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Подзаголовок
                Text("Ваш идеальный столик")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                
                // Индикатор загрузки
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                // Статус загрузки
                Text("Загружаем...")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}


// MARK: - Preview
#Preview {
    let userUseCase = UserUseCase(repository: UserRepository(networkService: NetworkService(), storageService: StorageService()), storageService: StorageService())
    let storageService = StorageService()
    
    Text("Sitly App Preview")
        .environmentObject(AppState(userUseCase: userUseCase, storageService: storageService))
}

