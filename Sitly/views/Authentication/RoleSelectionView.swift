//
//  RoleSelectionView.swift
//  Sitly
//
//  Created by AI Assistant on 12.09.2025.
//

import SwiftUI

struct RoleSelectionView: View {
    @EnvironmentObject var appState: AppState
    @Binding var selectedRole: UserRole
    @Binding var showRoleSelection: Bool
    
    let email: String
    let password: String
    let name: String
    
    @State private var isRegistering = false
    @State private var errorMessage: String?
    @State private var showRestaurantOnboarding = false
    
    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.3, blue: 0.15),
                    Color(red: 0.1, green: 0.4, blue: 0.2),
                    Color(red: 0.05, green: 0.25, blue: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Заголовок
                VStack(spacing: 16) {
                    Text("Выберите роль")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Это поможет настроить приложение под ваши нужды")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Карточки ролей
                VStack(spacing: 20) {
                    // Клиент
                    RoleCard(
                        title: "Клиент",
                        subtitle: "Бронирование столиков",
                        icon: "person.fill",
                        features: [
                            "Поиск ресторанов",
                            "AI-рекомендации",
                            "Бронирование столиков",
                            "История заказов"
                        ],
                        gradient: LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        isSelected: selectedRole == .client
                    ) {
                        selectedRole = .client
                        HapticService.shared.selection()
                    }
                    
                    // Ресторан
                    RoleCard(
                        title: "Ресторан",
                        subtitle: "Управление рестораном",
                        icon: "building.2.fill",
                        features: [
                            "Управление бронированиями",
                            "Аналитика и отчеты",
                            "AI-помощник",
                            "Меню и столики"
                        ],
                        gradient: LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        isSelected: selectedRole == .restaurant
                    ) {
                        selectedRole = .restaurant
                        HapticService.shared.selection()
                    }
                }
                
                Spacer()
                
                // Кнопка продолжения
                Button(action: registerUser) {
                    HStack {
                        if isRegistering {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                        }
                        
                        Text(isRegistering ? "Создаем аккаунт..." : "Продолжить")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(isRegistering)
                .padding(.horizontal, 20)
                
                // Кнопка назад
                Button("Назад") {
                    showRoleSelection = false
                    HapticService.shared.buttonPress()
                }
                .foregroundColor(.white.opacity(0.7))
                .font(.body)
            }
            .padding(.top, 50)
            .padding(.bottom, 30)
        }
        .alert("Ошибка", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
        .fullScreenCover(isPresented: $showRestaurantOnboarding) {
            RestaurantOnboardingView()
                .environmentObject(appState)
        }
    }
    
    private func registerUser() {
        Task {
            isRegistering = true
            HapticService.shared.buttonPress()
            
            do {
                try await appState.register(
                    email: email,
                    password: password,
                    name: name,
                    role: selectedRole
                )
                
                // Если роль ресторан - показываем onboarding
                if selectedRole == .restaurant {
                    // Устанавливаем что онбординг не завершен
                    appState.hasCompletedOnboarding = false
                    showRestaurantOnboarding = true
                } else {
                    // Для клиентов сразу успешная авторизация
                    HapticService.shared.authSuccess()
                }
                
            } catch {
                print("🚨 Ошибка регистрации: \(error)")
                print("🚨 Подробности: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                HapticService.shared.authError()
            }
            
            isRegistering = false
        }
    }
}

// MARK: - Role Card Component
struct RoleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let features: [String]
    let gradient: LinearGradient
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Хедер карточки
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text(title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Индикатор выбора
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 24, height: 24)
                        
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                // Функции
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(feature)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding(20)
            .background(
                ZStack {
                    // Основной градиент
                    gradient
                        .opacity(isSelected ? 1.0 : 0.8)
                    
                    // Дополнительный слой для выбранной карточки
                    if isSelected {
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? Color.black.opacity(0.3) : Color.black.opacity(0.1),
                radius: isSelected ? 10 : 5,
                x: 0,
                y: isSelected ? 5 : 2
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}

#Preview {
    RoleSelectionView(
        selectedRole: .constant(.client),
        showRoleSelection: .constant(true),
        email: "test@example.com",
        password: "password",
        name: "Test User"
    )
    .environmentObject(AppState(
        userUseCase: DependencyContainer.shared.userUseCase,
        storageService: DependencyContainer.shared.storageService
    ))
}