import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: ProfileViewModel
    @State private var animateContent = false
    @State private var showEditProfile = false
    @State private var showSettings = false
    
    init() {
        let container = DependencyContainer.shared
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(
            userUseCase: container.userUseCase
        ))
    }
    
    var body: some View {
        NavigationStack {
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Профиль пользователя
                        profileHeaderSection
                        
                        // Статистика
                        statisticsSection
                        
                        // Меню действий
                        menuSection
                        
                        // Настройки
                        settingsSection
                        
                        // Кнопка выхода
                        logoutSection
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            startAnimations()
            Task {
                await viewModel.loadUserData()
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(user: appState.currentUser)
        }
    }
    
    // MARK: - Profile Header Section
    
    private var profileHeaderSection: some View {
        VStack(spacing: 20) {
            // Аватар
            profileAvatar
            
            // Информация о пользователе
            if let user = appState.currentUser {
                VStack(spacing: 8) {
                    Text(user.name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    Text(user.email)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    // Верификация
                    if user.isVerified {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                            
                            Text("Верифицирован")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.green)
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    }
                }
            }
            
            // Кнопка редактирования
            Button(action: { showEditProfile = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                    
                    Text("Редактировать профиль")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 30)
        }
        .padding(.horizontal, 20)
        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
    }
    
    private var profileAvatar: some View {
        ZStack {
            // Градиентный фон
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple, .pink, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
            
            // Аватар или инициалы
            if let imageUrl = appState.currentUser?.profileImageURL,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    userInitials
                }
                .frame(width: 110, height: 110)
                .clipShape(Circle())
            } else {
                userInitials
            }
        }
        .scaleEffect(animateContent ? 1 : 0.8)
        .opacity(animateContent ? 1 : 0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1), value: animateContent)
    }
    
    private var userInitials: some View {
        Text(getInitials())
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundColor(.white)
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(title: "Бронирований", value: "\(viewModel.bookingsCount)", icon: "calendar")
            StatCard(title: "Любимых", value: "\(viewModel.favoritesCount)", icon: "heart.fill")
            StatCard(title: "Отзывов", value: "\(viewModel.reviewsCount)", icon: "star.fill")
        }
        .padding(.horizontal, 20)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.4), value: animateContent)
    }
    
    // MARK: - Menu Section
    
    private var menuSection: some View {
        VStack(spacing: 16) {
            MenuRow(icon: "calendar.badge.plus", title: "Мои бронирования", subtitle: "История и активные брони") {
                // Навигация к бронированиям
            }
            
            MenuRow(icon: "heart.fill", title: "Избранное", subtitle: "Любимые рестораны") {
                // Навигация к избранному
            }
            
            MenuRow(icon: "star.fill", title: "Мои отзывы", subtitle: "Оценки и комментарии") {
                // Навигация к отзывам
            }
            
            MenuRow(icon: "gift.fill", title: "Акции и скидки", subtitle: "Специальные предложения") {
                // Навигация к промо
            }
        }
        .padding(.horizontal, 20)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.6), value: animateContent)
    }
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Настройки")
            
            MenuRow(icon: "bell.fill", title: "Уведомления", subtitle: "Push и email уведомления") {
                // Навигация к настройкам уведомлений
            }
            
            MenuRow(icon: "location.fill", title: "Геолокация", subtitle: "Доступ к местоположению") {
                // Навигация к настройкам геолокации
            }
            
            MenuRow(icon: "paintbrush.fill", title: "Тема приложения", subtitle: "Светлая или темная тема") {
                // Навигация к настройкам темы
            }
            
            MenuRow(icon: "questionmark.circle.fill", title: "Помощь", subtitle: "FAQ и поддержка") {
                // Навигация к помощи
            }
        }
        .padding(.horizontal, 20)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.8), value: animateContent)
    }
    
    // MARK: - Logout Section
    
    private var logoutSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                appState.logout()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.right.square.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                    
                    Text("Выйти из аккаунта")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // Версия приложения
            Text("Версия 1.0.0 (MVP)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray.opacity(0.6))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(1.0), value: animateContent)
    }
    
    // MARK: - Helper Methods
    
    private func getInitials() -> String {
        guard let user = appState.currentUser else { return "?" }
        let names = user.name.components(separatedBy: " ")
        if names.count >= 2 {
            return String(names[0].prefix(1)) + String(names[1].prefix(1))
        } else {
            return String(user.name.prefix(2))
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.8)) {
            animateContent = true
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(
                    LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
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
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                action()
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

// MARK: - Profile ViewModel

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var bookingsCount = 0
    @Published var favoritesCount = 0
    @Published var reviewsCount = 0
    @Published var isLoading = false
    
    private let userUseCase: UserUseCaseProtocol
    
    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
    }
    
    func loadUserData() async {
        isLoading = true
        
        // Здесь будет загрузка реальных данных
        // Пока используем демо данные
        await MainActor.run {
            self.bookingsCount = 5
            self.favoritesCount = 12
            self.reviewsCount = 8
            self.isLoading = false
        }
    }
}

// MARK: - Edit Profile View Placeholder

struct EditProfileView: View {
    let user: User?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("Редактирование профиля")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text("Здесь будет форма редактирования")
                        .foregroundColor(.gray)
                        .padding(.top)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                Button("Закрыть") {
                    dismiss()
                }
                .foregroundColor(.white)
                .padding()
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState(
            userUseCase: UserUseCase(
                repository: UserRepository(
                    networkService: NetworkService(),
                    storageService: StorageService()
                ),
                storageService: StorageService()
            ),
            storageService: StorageService()
        ))
}
