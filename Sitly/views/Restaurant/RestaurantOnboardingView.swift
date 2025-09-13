//
//  RestaurantOnboardingView.swift
//  Sitly
//
//  Created by AI Assistant on 12.09.2025.
//

import SwiftUI
import MapKit

struct RestaurantOnboardingView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = RestaurantOnboardingViewModel()
    @State private var currentStep = 0
    
    let totalSteps = 4
    
    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.08, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Прогресс бар
                progressBar
                
                // Контент шагов
                TabView(selection: $currentStep) {
                    // Шаг 1: Основная информация
                    BasicInfoStepView(viewModel: viewModel)
                        .tag(0)
                    
                    // Шаг 2: Местоположение
                    LocationStepView(viewModel: viewModel)
                        .tag(1)
                    
                    // Шаг 3: Часы работы
                    WorkingHoursStepView(viewModel: viewModel)
                        .tag(2)
                    
                    // Шаг 4: Завершение
                    CompletionStepView(viewModel: viewModel)
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Кнопки навигации
                navigationButtons
            }
        }
        .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var progressBar: some View {
        VStack(spacing: 16) {
            HStack {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(currentStep >= step ? .white : .white.opacity(0.3))
                        .frame(width: 12, height: 12)
                    
                    if step < totalSteps - 1 {
                        Rectangle()
                            .fill(currentStep > step ? .white : .white.opacity(0.3))
                            .frame(height: 2)
                    }
                }
            }
            .padding(.horizontal, 40)
            
            Text("Шаг \(currentStep + 1) из \(totalSteps)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            // Кнопка назад
            if currentStep > 0 {
                Button("Назад") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep -= 1
                    }
                    HapticService.shared.buttonPress()
                }
                .foregroundColor(.white.opacity(0.7))
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Spacer()
            }
            
            // Кнопка вперед/завершить
            Button(buttonTitle) {
                handleNextAction()
            }
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(viewModel.isLoading || !canProceed)
            .opacity(viewModel.isLoading || !canProceed ? 0.6 : 1.0)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    private var buttonTitle: String {
        if viewModel.isLoading {
            return "Создаем ресторан..."
        }
        return currentStep == totalSteps - 1 ? "Завершить" : "Далее"
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0: return !viewModel.restaurantName.isEmpty && !viewModel.description.isEmpty
        case 1: return !viewModel.address.isEmpty
        case 2: return true
        case 3: return true
        default: return false
        }
    }
    
    private func handleNextAction() {
        HapticService.shared.buttonPress()
        
        if currentStep == totalSteps - 1 {
            // Завершаем регистрацию
            Task {
                await viewModel.createRestaurant(userId: appState.currentUser?.id ?? "")
            }
        } else {
            // Переходим к следующему шагу
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        }
    }
}

// MARK: - Basic Info Step
struct BasicInfoStepView: View {
    @ObservedObject var viewModel: RestaurantOnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Основная информация")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Расскажите о вашем ресторане")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                VStack(spacing: 20) {
                    // Название ресторана
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Название ресторана")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        TextField("Введите название", text: $viewModel.restaurantName)
                            .textFieldStyle(OnboardingTextFieldStyle())
                    }
                    
                    // Описание
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Описание")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        TextField("Краткое описание ресторана", text: $viewModel.description, axis: .vertical)
                            .textFieldStyle(OnboardingTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    // Тип кухни
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Тип кухни")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(CuisineType.allCases, id: \.self) { cuisine in
                                cuisineButton(cuisine: cuisine)
                            }
                        }
                    }
                    
                    // Ценовая категория
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ценовая категория")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(PriceRange.allCases, id: \.self) { price in
                                priceButton(priceRange: price)
                            }
                        }
                    }
                    
                    // Телефон
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Телефон")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        TextField("+7 (999) 123-45-67", text: $viewModel.phoneNumber)
                            .textFieldStyle(OnboardingTextFieldStyle())
                            .keyboardType(.phonePad)
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func cuisineButton(cuisine: CuisineType) -> some View {
        Button(action: {
            viewModel.selectedCuisine = cuisine
            HapticService.shared.selection()
        }) {
            Text(cuisine.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(viewModel.selectedCuisine == cuisine ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(viewModel.selectedCuisine == cuisine ? 
                              Color.blue.opacity(0.3) : Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    viewModel.selectedCuisine == cuisine ? .blue : Color.white.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                )
        }
    }
    
    private func priceButton(priceRange: PriceRange) -> some View {
        Button(action: {
            viewModel.selectedPriceRange = priceRange
            HapticService.shared.selection()
        }) {
            VStack(spacing: 4) {
                Text(priceRange.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(viewModel.selectedPriceRange == priceRange ? .white : .white.opacity(0.7))
                
                Text(priceRange.range)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(viewModel.selectedPriceRange == priceRange ? 
                          Color.purple.opacity(0.3) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                viewModel.selectedPriceRange == priceRange ? .purple : Color.white.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
}

// MARK: - Location Step
struct LocationStepView: View {
    @ObservedObject var viewModel: RestaurantOnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Местоположение")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Укажите адрес вашего ресторана")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                VStack(spacing: 20) {
                    // Адрес
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Адрес")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        TextField("Улица, дом, офис/квартира", text: $viewModel.address)
                            .textFieldStyle(OnboardingTextFieldStyle())
                    }
                    
                    // Город
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Город")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        TextField("Москва", text: $viewModel.city)
                            .textFieldStyle(OnboardingTextFieldStyle())
                    }
                    
                    // Карта (placeholder)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Местоположение на карте")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "map.fill")
                                        .font(.title)
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    Text("Карта будет добавлена")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            )
                            .frame(height: 200)
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Working Hours Step
struct WorkingHoursStepView: View {
    @ObservedObject var viewModel: RestaurantOnboardingViewModel
    
    let weekdays = [
        ("Понедельник", "monday"),
        ("Вторник", "tuesday"),
        ("Среда", "wednesday"),
        ("Четверг", "thursday"),
        ("Пятница", "friday"),
        ("Суббота", "saturday"),
        ("Воскресенье", "sunday")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Часы работы")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Установите график работы ресторана")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                VStack(spacing: 16) {
                    ForEach(weekdays, id: \.1) { day in
                        workingHourRow(day: day)
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func workingHourRow(day: (String, String)) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(day.0)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Toggle("", isOn: Binding(
                    get: { viewModel.workingHours[day.1]?.isOpen ?? true },
                    set: { isOpen in
                        viewModel.updateWorkingHours(day: day.1, isOpen: isOpen)
                    }
                ))
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            
            if viewModel.workingHours[day.1]?.isOpen ?? true {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Открытие")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Button(viewModel.workingHours[day.1]?.openTime ?? "09:00") {
                            // TODO: Time picker
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Закрытие")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Button(viewModel.workingHours[day.1]?.closeTime ?? "22:00") {
                            // TODO: Time picker
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Completion Step
struct CompletionStepView: View {
    @ObservedObject var viewModel: RestaurantOnboardingViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Иконка успеха
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(spacing: 12) {
                    Text("Почти готово!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Сейчас создадим ваш ресторан и настроим админ-панель")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            
            // Резюме
            VStack(spacing: 16) {
                summaryRow(title: "Название", value: viewModel.restaurantName)
                summaryRow(title: "Кухня", value: viewModel.selectedCuisine.displayName)
                summaryRow(title: "Адрес", value: viewModel.fullAddress)
                summaryRow(title: "Телефон", value: viewModel.phoneNumber)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private func summaryRow(title: String, value: String) -> some View {
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
}

// MARK: - Text Field Style
struct OnboardingTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .foregroundColor(.white)
    }
}

#Preview {
    RestaurantOnboardingView()
        .environmentObject(AppState(
            userUseCase: DependencyContainer.shared.userUseCase,
            storageService: DependencyContainer.shared.storageService
        ))
}
