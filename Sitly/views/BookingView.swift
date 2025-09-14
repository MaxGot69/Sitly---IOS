//
//  BookingView.swift
//  Sitly
//
//  Created by Maxim Gotovchenko on 30.06.2025.
//
import CoreLocation
import SwiftUI

struct BookingView: View {
    let restaurant: Restaurant
    @StateObject private var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var animateHeader = false
    @State private var animateContent = false
    @State private var showConfirmation = false
    @State private var showSuccess = false
    
                    init(restaurant: Restaurant) {
                    self.restaurant = restaurant
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
                    let tablesService = TablesService()
                    self._viewModel = StateObject(wrappedValue: BookingViewModel(
                        restaurant: restaurant,
                        bookingUseCase: bookingUseCase,
                        tablesService: tablesService
                    ))
                }
    
    var body: some View {
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
            
            if showSuccess {
                modernSuccessView
            } else if showConfirmation {
                modernConfirmationView
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Современный хедер ресторана
                        modernRestaurantHeader
                        
                        // Секция выбора даты
                        modernDateSelectionSection
                        
                        // Секция выбора времени
                        modernTimeSelectionSection
                        
                        // Секция количества гостей
                        modernGuestCountSection
                        
                        // Секция выбора столика
                        modernTableSelectionSection
                        
                        // Кнопка бронирования
                        modernBookingButton
                    }
                }
                .navigationBarHidden(true)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Современные компоненты
    
    private var modernRestaurantHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
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
                
                Spacer()
                
                Text("Бронирование")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "questionmark.circle")
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
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Информация о ресторане
            HStack(spacing: 16) {
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
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(restaurant.cuisineType.displayName)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing)
                        )
                    
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("•")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Text("\(restaurant.tables.count) столиков")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
        .opacity(animateHeader ? 1 : 0)
        .offset(y: animateHeader ? 0 : 20)
        .animation(.easeOut(duration: 0.8), value: animateHeader)
    }
    
    private var modernDateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Выберите дату")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                                    ForEach(0..<7, id: \.self) { index in
                    let date = Calendar.current.date(byAdding: .day, value: index, to: Date()) ?? Date()
                    Button(action: {
                        viewModel.selectedDate = date
                    }) {
                        VStack(spacing: 8) {
                            Text(date.dayOfWeek)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(viewModel.selectedDate == date ? .black : .gray)
                            
                            Text(date.day)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(viewModel.selectedDate == date ? .black : .white)
                            
                            Text(date.month)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(viewModel.selectedDate == date ? .black : .gray)
                        }
                        .frame(width: 60, height: 80)
                        .background(dateSelectionBackground(for: date))
                        .overlay(dateSelectionOverlay(for: date))
                    }
                }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 24)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
    }
    
    private var modernTimeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Выберите время")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(viewModel.availableTimes, id: \.self) { time in
                    Button(action: {
                        viewModel.selectedTime = time
                    }) {
                        Text(time)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(viewModel.selectedTime == time ? .black : .white)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(timeSelectionBackground(for: time))
                            .overlay(timeSelectionOverlay(for: time))
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 24)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.4), value: animateContent)
    }
    
    private var modernGuestCountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Количество гостей")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            HStack {
                Button(action: {
                    if viewModel.guestCount > 1 {
                        viewModel.guestCount -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("\(viewModel.guestCount)")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("гостей")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    if viewModel.guestCount < 10 {
                        viewModel.guestCount += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
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
            .padding(.horizontal, 20)
        }
        .padding(.top, 24)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.6), value: animateContent)
    }
    
    private var modernTableSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Выберите столик")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Group {
                if viewModel.isLoadingTables {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .mint))
                        Text("Загружаем столики...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .frame(height: 100)
                } else if viewModel.availableTables.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "table.furniture")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                        Text("Нет доступных столиков")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .frame(height: 100)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ForEach(viewModel.availableTables, id: \.id) { table in
                            Button(action: {
                                viewModel.selectedTable = table.name
                            }) {
                                VStack(spacing: 12) {
                                    Image(systemName: getTableIcon(for: table.type.rawValue))
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(viewModel.selectedTable == table.name ? .black : .mint)
                                    
                                    VStack(spacing: 4) {
                                        Text(table.name)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(viewModel.selectedTable == table.name ? .black : .white)
                                        
                                        Text("\(table.capacity) мест")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(viewModel.selectedTable == table.name ? .black.opacity(0.7) : .gray)
                                    }
                                }
                                .frame(height: 100)
                                .frame(maxWidth: .infinity)
                                .background(tableSelectionBackground(for: table.name))
                                .overlay(tableSelectionOverlay(for: table.name))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 24)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.8), value: animateContent)
    }
    
    private var modernBookingButton: some View {
        VStack(spacing: 16) {
            Button(action: {
                showConfirmation = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "calendar.badge.checkmark")
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
            .padding(.top, 32)
            .padding(.bottom, 20)
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(1.0), value: animateContent)
    }
    
    private var modernConfirmationView: some View {
        VStack(spacing: 24) {
            // Иконка подтверждения
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.mint, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("Подтвердите бронирование")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Проверьте детали вашего заказа")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            // Детали бронирования
            VStack(spacing: 16) {
                modernBookingDetailRow(title: "Ресторан", value: restaurant.name)
                                                modernBookingDetailRow(title: "Дата", value: viewModel.selectedDate.formatted())
                modernBookingDetailRow(title: "Время", value: viewModel.selectedTime)
                modernBookingDetailRow(title: "Гости", value: "\(viewModel.guestCount) человек")
                modernBookingDetailRow(title: "Столик", value: viewModel.selectedTable)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            
            // Кнопки
            HStack(spacing: 16) {
                Button("Отмена") {
                    showConfirmation = false
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                
                Button("Подтвердить") {
                    // Создаем бронирование
                    Task {
                        await viewModel.createBooking()
                        showConfirmation = false
                        showSuccess = true
                    }
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing)
                        )
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
    }
    
    private var modernSuccessView: some View {
        VStack(spacing: 32) {
            // Анимированная иконка успеха
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.mint, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(showSuccess ? 1.0 : 0.5)
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showSuccess)
            
            VStack(spacing: 12) {
                Text("Бронирование подтверждено!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                                                Text("Ваш столик забронирован на \(viewModel.selectedTime) в \(restaurant.name)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Номер бронирования
            VStack(spacing: 8) {
                Text("Номер бронирования")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Text("#\(Int.random(in: 10000...99999))")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing)
                    )
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            
            Button("Вернуться к ресторанам") {
                dismiss()
            }
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing)
                    )
            )
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 40)
    }
    
    private func modernBookingDetailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
    }
    
    private func getTableIcon(for type: String) -> String {
        switch type {
        case "window": return "window.vertical"
        case "garden": return "leaf.fill"
        case "bar": return "wineglass.fill"
        case "private": return "lock.shield"
        default: return "table.furniture"
        }
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
    
    // MARK: - Helper Functions
    
    private func dateSelectionBackground(for date: Date) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                viewModel.selectedDate == date 
                ? AnyShapeStyle(LinearGradient(colors: [.mint, .green], startPoint: .top, endPoint: .bottom))
                : AnyShapeStyle(Color.clear)
            )
    }
    
    private func dateSelectionOverlay(for date: Date) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(
                viewModel.selectedDate == date 
                ? Color.clear 
                : Color.white.opacity(0.2),
                lineWidth: 1
            )
    }
    
    private func timeSelectionBackground(for time: String) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                viewModel.selectedTime == time 
                ? AnyShapeStyle(LinearGradient(colors: [.mint, .green], startPoint: .leading, endPoint: .trailing))
                : AnyShapeStyle(Color.clear)
            )
    }
    
    private func timeSelectionOverlay(for time: String) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(
                viewModel.selectedTime == time 
                ? Color.clear 
                : Color.white.opacity(0.2),
                lineWidth: 1
            )
    }
    
    private func tableSelectionBackground(for table: String) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                viewModel.selectedTable == table 
                ? AnyShapeStyle(LinearGradient(colors: [.mint, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
                : AnyShapeStyle(Color.clear)
            )
    }
    
    private func tableSelectionOverlay(for table: String) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                viewModel.selectedTable == table 
                ? Color.clear 
                : Color.white.opacity(0.2),
                lineWidth: 1
            )
    }
}

// MARK: - Расширения для даты

extension Date {
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEE"
        return formatter.string(from: self).capitalized
    }
    
    var day: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
    
    var month: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "MMM"
        return formatter.string(from: self).capitalized
    }
    
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}

#Preview {
    BookingView(restaurant: Restaurant(
        id: "preview-pushkin",
        name: "Pushkin",
        description: "Это культовое заведение, известное своим роскошным интерьером в стиле дворянской усадьбы XIX века и изысканной русской кухней.",
        cuisineType: .russian,
        address: "Тверской бул., 26А, Москва",
        coordinates: CLLocationCoordinate2D(latitude: 55.7652, longitude: 37.6041),
        phoneNumber: "+7 (495) 123-45-67",
        ownerId: "preview-owner"
    ))
    .injectDependencies()
}

