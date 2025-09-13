import SwiftUI

struct AchievementsView: View {
    @State private var showingAchievementDetail = false
    
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
            
            ScrollView {
                VStack(spacing: 24) {
                    // Заголовок с прогрессом
                    headerSection
                    
                    // Статистика пользователя
                    userStatsSection
                    
                    // Заглушка для будущих секций
                    placeholderSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .onAppear {
            // Здесь будет загрузка данных
        }
        .sheet(isPresented: $showingAchievementDetail) {
            Text("Детали достижения")
                .font(.title)
                .padding()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Заголовок
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Достижения")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Разблокируйте достижения и получайте бонусы")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Уровень пользователя
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue, .green],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    VStack(spacing: 2) {
                        Text("5")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("LVL")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            
            // Прогресс уровня
            VStack(spacing: 8) {
                HStack {
                    Text("Прогресс до следующего уровня")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("150 / 200 XP")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                // Прогресс-бар
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue, .green],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * 0.75,
                                height: 8
                            )
                            .animation(.easeInOut(duration: 1.0), value: 0.75)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.purple.opacity(0.5), .blue.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // MARK: - User Stats Section
    private var userStatsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
            StatCard(
                title: "Достижений",
                value: "12",
                icon: "trophy.fill"
            )
            
            StatCard(
                title: "Выполнено",
                value: "8",
                icon: "star.fill"
            )
            
            StatCard(
                title: "Завершено",
                value: "67%",
                icon: "percent"
            )
        }
    }
    
    // MARK: - Placeholder Section
    private var placeholderSection: some View {
        VStack(spacing: 16) {
            Text("Достижения")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Здесь будут отображаться достижения пользователя")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    AchievementsView()
}
