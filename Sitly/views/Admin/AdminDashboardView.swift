import SwiftUI
import Charts

struct AdminDashboardView: View {
    @StateObject private var viewModel = AdminDashboardViewModel()
    @State private var selectedTimeRange = "Сегодня"
    @State private var showingDetails = false
    @State private var animateCards = false
    
    private let timeRanges = ["Сегодня", "Неделя", "Месяц", "Год"]
    
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок админки
                        headerSection
                        
                        // Быстрая статистика
                        quickStatsSection
                        
                        // Графики и аналитика
                        analyticsSection
                        
                        // Управление платформой
                        managementSection
                        
                        // Последние действия
                        recentActivitySection
                        
                        // Системная информация
                        systemInfoSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadDashboardData()
            withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                animateCards = true
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Админ-панель")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .red.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Управление платформой Sitly")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Статус системы
                HStack(spacing: 8) {
                    Circle()
                        .fill(.green)
                        .frame(width: 12, height: 12)
                    
                    Text("Система работает")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
            }
            
            // Переключатель временного диапазона
            HStack {
                ForEach(timeRanges, id: \.self) { range in
                    Button(action: { selectedTimeRange = range }) {
                        Text(range)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(selectedTimeRange == range ? .black : .white.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedTimeRange == range ? .white : .clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                
                Spacer()
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 20)
    }
    
    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            AdminStatCard(
                title: "Всего ресторанов",
                value: "\(viewModel.totalRestaurants)",
                change: "+\(viewModel.newRestaurantsToday)",
                changeLabel: "сегодня",
                icon: "building.2.fill",
                color: .blue,
                isPositive: true
            )
            
            AdminStatCard(
                title: "Активных пользователей",
                value: "\(viewModel.activeUsers)",
                change: "+\(viewModel.newUsersToday)",
                changeLabel: "сегодня",
                icon: "person.3.fill",
                color: .green,
                isPositive: true
            )
            
            AdminStatCard(
                title: "Броней сегодня",
                value: "\(viewModel.todayBookings)",
                change: "+\(Int(viewModel.bookingGrowth))%",
                changeLabel: "к вчера",
                icon: "calendar.badge.plus",
                color: .orange,
                isPositive: viewModel.bookingGrowth > 0
            )
            
            AdminStatCard(
                title: "Доходы",
                value: "₽\(viewModel.todayRevenue.formatted())",
                change: "+\(Int(viewModel.revenueGrowth))%",
                changeLabel: "к вчера",
                icon: "rublesign.circle.fill",
                color: .purple,
                isPositive: viewModel.revenueGrowth > 0
            )
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateCards)
    }
    
    // MARK: - Analytics Section
    private var analyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Аналитика платформы")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                // График бронирований
                bookingsChartCard
                
                // География пользователей
                geographyCard
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 40)
        .animation(.easeOut(duration: 0.8).delay(0.4), value: animateCards)
    }
    
    private var bookingsChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Динамика бронирований")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("За последние 7 дней")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text("+24%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.2))
                    .cornerRadius(6)
            }
            
            // Простой график
            Chart(viewModel.weeklyBookingsData, id: \.day) { data in
                LineMark(
                    x: .value("День", data.day),
                    y: .value("Брони", data.bookings)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                AreaMark(
                    x: .value("День", data.day),
                    y: .value("Брони", data.bookings)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red.opacity(0.3), .orange.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.white.opacity(0.2))
                    AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.white.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.white.opacity(0.2))
                    AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.white.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.red.opacity(0.3), .orange.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    private var geographyCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("География пользователей")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(viewModel.cityStats, id: \.city) { stat in
                    HStack {
                        Text(stat.city)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(stat.users)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                        
                        // Прогресс бар
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(.white.opacity(0.2))
                                    .frame(height: 4)
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.red, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * stat.percentage, height: 4)
                            }
                        }
                        .frame(width: 60, height: 4)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Management Section
    private var managementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Управление")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                AdminActionCard(
                    title: "Рестораны",
                    subtitle: "Управление заведениями",
                    icon: "building.2.fill",
                    color: .blue,
                    action: { /* Navigate to restaurants */ }
                )
                
                AdminActionCard(
                    title: "Пользователи",
                    subtitle: "База пользователей",
                    icon: "person.3.fill",
                    color: .green,
                    action: { /* Navigate to users */ }
                )
                
                AdminActionCard(
                    title: "Модерация",
                    subtitle: "Отзывы и жалобы",
                    icon: "checkmark.shield.fill",
                    color: .orange,
                    action: { /* Navigate to moderation */ }
                )
                
                AdminActionCard(
                    title: "Настройки",
                    subtitle: "Конфигурация системы",
                    icon: "gearshape.fill",
                    color: .purple,
                    action: { /* Navigate to settings */ }
                )
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 50)
        .animation(.easeOut(duration: 0.8).delay(0.6), value: animateCards)
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Последняя активность")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(viewModel.recentActivities, id: \.id) { activity in
                    AdminActivityRow(activity: activity)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 60)
        .animation(.easeOut(duration: 0.8).delay(0.8), value: animateCards)
    }
    
    // MARK: - System Info Section
    private var systemInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Система")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                SystemInfoCard(title: "Версия", value: "2.1.0", icon: "app.badge")
                SystemInfoCard(title: "Сервер", value: "99.9%", icon: "server.rack")
                SystemInfoCard(title: "API", value: "≤50ms", icon: "speedometer")
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 70)
        .animation(.easeOut(duration: 0.8).delay(1.0), value: animateCards)
    }
}

// MARK: - Admin Stat Card
struct AdminStatCard: View {
    let title: String
    let value: String
    let change: String
    let changeLabel: String
    let icon: String
    let color: Color
    let isPositive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                        .font(.caption)
                    Text(change)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(isPositive ? .green : .red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((isPositive ? Color.green : Color.red).opacity(0.2))
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(changeLabel)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
            }
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

// MARK: - Admin Action Card
struct AdminActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
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

// MARK: - Admin Activity Row
struct AdminActivityRow: View {
    let activity: AdminActivity
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(activity.type.color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text(activity.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text(activity.timeAgo)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
    }
}

// MARK: - System Info Card
struct SystemInfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}


#Preview {
    AdminDashboardView()
}
