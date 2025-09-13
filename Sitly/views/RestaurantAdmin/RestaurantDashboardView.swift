import SwiftUI
import Charts

struct RestaurantDashboardView: View {
    @StateObject private var viewModel = RestaurantDashboardViewModel()
    @State private var selectedTab = 0
    @State private var showingProfile = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок с анимацией
                        headerSection
                        
                        // Быстрые действия
                        quickActionsSection
                        
                        // Статистика сегодня
                        todayStatsSection
                        
                        // AI-аналитика
                        aiAnalyticsSection
                        
                        // Ближайшие брони
                        upcomingBookingsSection
                        
                        // Графики и тренды
                        chartsSection
                        
                        // Уведомления
                        notificationsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadDashboardData()
        }
        .sheet(isPresented: $showingProfile) {
            Text("Профиль ресторана")
                .font(.title)
                .padding()
        }
        .sheet(isPresented: $showingSettings) {
            Text("Настройки ресторана")
                .font(.title)
                .padding()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Добро пожаловать!")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(viewModel.restaurant?.name ?? "Ресторан")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Профиль ресторана
            Button(action: { showingProfile = true }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "building.2.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(ScaleButtonStyle())
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
                                colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Быстрые действия")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                QuickActionCard(
                    title: "Подтвердить все",
                    subtitle: "\(viewModel.pendingBookingsCount) броней",
                    icon: "checkmark.circle.fill",
                    color: .green,
                    action: { viewModel.confirmAllBookings() }
                )
                
                QuickActionCard(
                    title: "Новое бронирование",
                    subtitle: "Создать вручную",
                    icon: "plus.circle.fill",
                    color: .blue,
                    action: { viewModel.createManualBooking() }
                )
                
                QuickActionCard(
                    title: "Изменить статус",
                    subtitle: "Открыто/Закрыто",
                    icon: "toggle.on",
                    color: .orange,
                    action: { viewModel.toggleRestaurantStatus() }
                )
                
                QuickActionCard(
                    title: "AI-помощник",
                    subtitle: "Получить советы",
                    icon: "brain.head.profile",
                    color: .purple,
                    action: { viewModel.openAIAssistant() }
                )
            }
        }
    }
    
    // MARK: - Today Stats Section
    private var todayStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Сегодня в цифрах")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                DashboardStatCard(
                    title: "Новых броней",
                    value: "\(viewModel.todayStats.newBookings)",
                    change: "+\(viewModel.todayStats.newBookingsChange)%",
                    isPositive: viewModel.todayStats.newBookingsChange >= 0,
                    icon: "calendar.badge.plus",
                    color: .blue
                )
                
                DashboardStatCard(
                    title: "Подтверждено",
                    value: "\(viewModel.todayStats.confirmedBookings)",
                    change: "\(viewModel.todayStats.confirmationRate)%",
                    isPositive: true,
                    icon: "checkmark.shield.fill",
                    color: .green
                )
                
                DashboardStatCard(
                    title: "Ожидает",
                    value: "\(viewModel.todayStats.pendingBookings)",
                    change: "Требует внимания",
                    isPositive: false,
                    icon: "clock.fill",
                    color: .orange
                )
                
                DashboardStatCard(
                    title: "Выручка",
                    value: "₽\(viewModel.todayStats.revenue)",
                    change: "+\(viewModel.todayStats.revenueChange)%",
                    isPositive: viewModel.todayStats.revenueChange >= 0,
                    icon: "rublesign.circle.fill",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - AI Analytics Section
    private var aiAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("AI-аналитика")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.purple)
            }
            
            VStack(spacing: 16) {
                // AI-рекомендации
                DashboardAICard(
                    title: "Оптимизация столиков",
                    description: "AI рекомендует переместить VIP-столики ближе к окну для увеличения выручки на 15%",
                    confidence: 0.87,
                    action: { viewModel.applyAIRecommendation() }
                )
                
                DashboardAICard(
                    title: "Предсказание отмен",
                    description: "Высокий риск отмены для брони в 21:00 (гость часто отменяет)",
                    confidence: 0.73,
                    action: { viewModel.handleCancellationRisk() }
                )
                
                DashboardAICard(
                    title: "Персонализация меню",
                    description: "Создать специальное меню для вегетарианцев может увеличить средний чек",
                    confidence: 0.91,
                    action: { viewModel.createPersonalizedMenu() }
                )
            }
        }
    }
    
    // MARK: - Upcoming Bookings Section
    private var upcomingBookingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Ближайшие брони")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Все") {
                    // Переход к полному списку
                }
                .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.upcomingBookings) { booking in
                        UpcomingBookingCard(booking: booking) {
                            viewModel.handleBookingAction(booking)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Charts Section
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Аналитика и тренды")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 20) {
                // График загруженности по времени
                ChartCard(
                    title: "Загруженность по времени",
                    chart: {
                        Chart(viewModel.hourlyLoadData) { data in
                            LineMark(
                                x: .value("Время", data.hour),
                                y: .value("Загруженность", data.load)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            
                            AreaMark(
                                x: .value("Время", data.hour),
                                y: .value("Загруженность", data.load)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { _ in
                                AxisGridLine()
                                    .foregroundStyle(.white.opacity(0.2))
                                AxisTick()
                                    .foregroundStyle(.white.opacity(0.5))
                                AxisValueLabel()
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                        .chartXAxis {
                            AxisMarks { _ in
                                AxisGridLine()
                                    .foregroundStyle(.white.opacity(0.2))
                                AxisTick()
                                    .foregroundStyle(.white.opacity(0.5))
                                AxisValueLabel()
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                        .frame(height: 200)
                    }
                )
                
                // Популярные столики
                ChartCard(
                    title: "Популярные столики",
                    chart: {
                        Chart(viewModel.popularTablesData) { data in
                            BarMark(
                                x: .value("Столик", data.tableName),
                                y: .value("Брони", data.bookingCount)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .cornerRadius(8)
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { _ in
                                AxisGridLine()
                                    .foregroundStyle(.white.opacity(0.2))
                                AxisTick()
                                    .foregroundStyle(.white.opacity(0.5))
                                AxisValueLabel()
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                        .frame(height: 150)
                    }
                )
            }
        }
    }
    
    // MARK: - Notifications Section
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Уведомления")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(viewModel.notifications) { notification in
                    NotificationCard(notification: notification) {
                        viewModel.handleNotification(notification)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct DashboardStatCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(change)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isPositive ? .green : .orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isPositive ? .green.opacity(0.2) : .orange.opacity(0.2))
                    )
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct DashboardAICard: View {
    let title: String
    let description: String
    let confidence: Double
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(confidence * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.purple.opacity(0.2))
                    )
            }
            
            Text(description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(3)
            
            Button("Применить") {
                action()
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.purple)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.purple.opacity(0.2))
            )
            .buttonStyle(ScaleButtonStyle())
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
}

struct UpcomingBookingCard: View {
    let booking: Booking
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.timeSlot)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(booking.guests) гостей")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: action) {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            HStack {
                Button("Подтвердить") {
                    // Подтвердить бронь
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.green)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.green.opacity(0.2))
                )
                
                Button("Отклонить") {
                    // Отклонить бронь
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.red)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.red.opacity(0.2))
                )
            }
        }
        .padding(16)
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    let chart: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            chart()
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
    }
}

struct NotificationCard: View {
    let notification: Notification
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: notification.icon)
                .font(.title3)
                .foregroundColor(notification.color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(notification.message)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(notification.timeAgo)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(notification.color.opacity(0.3), lineWidth: 1)
                )
        )
        .onTapGesture {
            action()
        }
    }
}

// MARK: - Button Styles


// MARK: - Preview
#Preview {
    RestaurantDashboardView()
        .preferredColorScheme(.dark)
}
