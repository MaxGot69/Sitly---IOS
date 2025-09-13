import SwiftUI
import Charts

struct AdminAnalyticsView: View {
    @StateObject private var viewModel = AdminAnalyticsViewModel()
    @State private var selectedTimeframe = "Месяц"
    @State private var animateCharts = false
    
    private let timeframes = ["День", "Неделя", "Месяц", "Год"]
    
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
                        // Заголовок и фильтры
                        headerSection
                        
                        // Ключевые метрики
                        keyMetricsSection
                        
                        // Графики
                        chartsSection
                        
                        // Детальная аналитика
                        detailedAnalyticsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadAnalytics()
            withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
                animateCharts = true
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Аналитика")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Общая статистика платформы")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Экспорт отчета
                Button(action: { /* Export report */ }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                        Text("Отчет")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            // Временные фильтры
            HStack {
                ForEach(timeframes, id: \.self) { timeframe in
                    Button(action: { selectedTimeframe = timeframe }) {
                        Text(timeframe)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedTimeframe == timeframe ? .black : .white.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedTimeframe == timeframe ? .white : .clear)
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
    }
    
    // MARK: - Key Metrics Section
    private var keyMetricsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            MetricCard(
                title: "Общая выручка",
                value: "₽\(viewModel.totalRevenue.formatted())",
                change: "+\(Int(viewModel.revenueGrowth))%",
                icon: "rublesign.circle.fill",
                color: .green,
                isPositive: viewModel.revenueGrowth > 0
            )
            
            MetricCard(
                title: "Активных ресторанов",
                value: "\(viewModel.activeRestaurants)",
                change: "+\(viewModel.newRestaurantsCount)",
                icon: "building.2.fill",
                color: .blue,
                isPositive: true
            )
            
            MetricCard(
                title: "Броней за период",
                value: "\(viewModel.totalBookings.formatted())",
                change: "+\(Int(viewModel.bookingsGrowth))%",
                icon: "calendar.badge.plus",
                color: .orange,
                isPositive: viewModel.bookingsGrowth > 0
            )
            
            MetricCard(
                title: "Новых пользователей",
                value: "\(viewModel.newUsers)",
                change: "+\(Int(viewModel.userGrowth))%",
                icon: "person.3.fill",
                color: .purple,
                isPositive: viewModel.userGrowth > 0
            )
        }
        .opacity(animateCharts ? 1 : 0)
        .offset(y: animateCharts ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateCharts)
    }
    
    // MARK: - Charts Section
    private var chartsSection: some View {
        VStack(spacing: 16) {
            // График выручки
            revenueChartCard
            
            // График бронирований
            bookingsChartCard
            
            // Распределение по типам кухонь
            cuisineDistributionCard
        }
        .opacity(animateCharts ? 1 : 0)
        .offset(y: animateCharts ? 0 : 40)
        .animation(.easeOut(duration: 0.8).delay(0.4), value: animateCharts)
    }
    
    private var revenueChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Динамика выручки")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("За последние 30 дней")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text("+\(Int(viewModel.revenueGrowth))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.2))
                    .cornerRadius(6)
            }
            
            Chart(viewModel.revenueData, id: \.day) { data in
                LineMark(
                    x: .value("День", data.day),
                    y: .value("Выручка", data.revenue)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                AreaMark(
                    x: .value("День", data.day),
                    y: .value("Выручка", data.revenue)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green.opacity(0.3), .mint.opacity(0.1)],
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
                        .stroke(.green.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var bookingsChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Бронирования по дням недели")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Средние значения за месяц")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            
            Chart(viewModel.weeklyBookingsData, id: \.day) { data in
                BarMark(
                    x: .value("День", data.day),
                    y: .value("Брони", data.bookings)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(4)
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.white.opacity(0.2))
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
                        .stroke(.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var cuisineDistributionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Популярность типов кухонь")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(viewModel.cuisineStats, id: \.cuisine) { stat in
                    HStack {
                        Circle()
                            .fill(stat.color)
                            .frame(width: 12, height: 12)
                        
                        Text(stat.cuisine)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f%%", stat.percentage))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                        
                        // Прогресс бар
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(.white.opacity(0.2))
                                    .frame(height: 6)
                                
                                Rectangle()
                                    .fill(stat.color)
                                    .frame(width: geometry.size.width * (stat.percentage / 100), height: 6)
                            }
                        }
                        .frame(width: 80, height: 6)
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
    
    // MARK: - Detailed Analytics Section
    private var detailedAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Детальная аналитика")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                DetailedAnalyticCard(
                    title: "Средний чек",
                    value: "₽\(viewModel.averageCheck)",
                    subtitle: "на одно бронирование",
                    icon: "creditcard.fill",
                    color: .mint
                )
                
                DetailedAnalyticCard(
                    title: "Конверсия",
                    value: String(format: "%.1f%%", viewModel.conversionRate),
                    subtitle: "от просмотра к брони",
                    icon: "arrow.up.right.circle.fill",
                    color: .cyan
                )
                
                DetailedAnalyticCard(
                    title: "Время сессии",
                    value: "\(viewModel.averageSessionTime) мин",
                    subtitle: "среднее в приложении",
                    icon: "clock.fill",
                    color: .indigo
                )
                
                DetailedAnalyticCard(
                    title: "Отмены броней",
                    value: String(format: "%.1f%%", viewModel.cancellationRate),
                    subtitle: "от общего числа",
                    icon: "xmark.circle.fill",
                    color: .pink
                )
            }
        }
        .opacity(animateCharts ? 1 : 0)
        .offset(y: animateCharts ? 0 : 50)
        .animation(.easeOut(duration: 0.8).delay(0.6), value: animateCharts)
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String
    let change: String
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

// MARK: - Detailed Analytic Card
struct DetailedAnalyticCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.headline)
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
}

#Preview {
    AdminAnalyticsView()
}
