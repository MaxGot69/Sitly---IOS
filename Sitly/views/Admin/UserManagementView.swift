import SwiftUI

struct UserManagementView: View {
    @StateObject private var viewModel = UserManagementViewModel()
    @State private var searchText = ""
    @State private var selectedRole = "Все"
    @State private var showingUserDetail = false
    @State private var selectedUser: User?
    
    private let roles = ["Все", "Клиенты", "Рестораны", "Админы"]
    
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
                
                VStack(spacing: 0) {
                    // Заголовок и поиск
                    headerSection
                    
                    // Фильтры по ролям
                    roleFilterSection
                    
                    // Список пользователей
                    usersList
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadUsers()
        }
        .sheet(item: $selectedUser) { user in
            UserDetailView(user: user)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Управление пользователями")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(viewModel.users.count) пользователей")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Экспорт данных
                Button(action: { /* Export users */ }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Экспорт")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.purple, .purple.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            // Поисковая строка
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                
                TextField("Поиск пользователей...", text: $searchText)
                    .foregroundColor(.white)
                    .accentColor(.purple)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Role Filter Section
    private var roleFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(roles, id: \.self) { role in
                    Button(action: { selectedRole = role }) {
                        Text(role)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedRole == role ? .black : .white.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedRole == role ? .white : .clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Users List
    private var usersList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredUsers, id: \.id) { user in
                    UserManagementCard(
                        user: user,
                        onTap: { selectedUser = user },
                        onToggleStatus: { viewModel.toggleUserStatus(user) },
                        onDelete: { viewModel.deleteUser(user) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var filteredUsers: [User] {
        var users = viewModel.users
        
        // Фильтр по роли
        if selectedRole != "Все" {
            users = users.filter { user in
                switch selectedRole {
                case "Клиенты": return user.role == .client
                case "Рестораны": return user.role == .restaurant
                case "Админы": return user.role == .restaurant
                default: return true
                }
            }
        }
        
        // Поиск
        if !searchText.isEmpty {
            users = users.filter { user in
                user.name.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return users
    }
}

// MARK: - User Management Card
struct UserManagementCard: View {
    let user: User
    let onTap: () -> Void
    let onToggleStatus: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                // Аватар пользователя
                AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Text(String(user.name.prefix(1)).uppercased())
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
                // Информация о пользователе
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(user.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Роль
                        AdminRoleBadge(role: user.role)
                    }
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack {
                        // Дата регистрации
                        Text("Регистрация: \(user.createdAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        // Статус верификации
                        HStack(spacing: 4) {
                            Circle()
                                .fill(user.isVerified ? .green : .red)
                                .frame(width: 6, height: 6)
                            
                            Text(user.isVerified ? "Верифицирован" : "Не верифицирован")
                                .font(.caption)
                                .foregroundColor(user.isVerified ? .green : .red)
                        }
                    }
                }
            }
            
            // Статистика пользователя
            if let stats = getUserStats(for: user) {
                HStack(spacing: 20) {
                    StatItem(title: "Броней", value: "\(stats.bookings)")
                    StatItem(title: "Отзывов", value: "\(stats.reviews)")
                    StatItem(title: "Последняя активность", value: stats.lastActivity)
                }
            }
            
            // Действия
            HStack(spacing: 12) {
                // Переключить статус
                Button(action: onToggleStatus) {
                    HStack(spacing: 6) {
                        Image(systemName: user.isVerified ? "xmark.circle.fill" : "checkmark.circle.fill")
                        Text(user.isVerified ? "Снять верификацию" : "Верифицировать")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(user.isVerified ? .orange : .green)
                    .cornerRadius(8)
                }
                
                // Отправить сообщение
                Button(action: { /* Send message */ }) {
                    HStack(spacing: 6) {
                        Image(systemName: "message")
                        Text("Сообщение")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.blue)
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Удалить
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(.red)
                        .cornerRadius(8)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .onTapGesture(perform: onTap)
    }
    
    private func getUserStats(for user: User) -> UserStats? {
        // В реальном приложении здесь будет загрузка статистики из API
        return UserStats(
            bookings: Int.random(in: 0...50),
            reviews: Int.random(in: 0...20),
            lastActivity: ["Сегодня", "Вчера", "2 дня назад", "Неделю назад"].randomElement() ?? "Давно"
        )
    }
}

// MARK: - Admin Role Badge
struct AdminRoleBadge: View {
    let role: UserRole
    
    var body: some View {
        Text(role.adminDisplayName)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(role.adminColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(role.adminColor.opacity(0.2))
            .cornerRadius(8)
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - User Detail View
struct UserDetailView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Профиль пользователя")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text(user.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Детальная информация о пользователе")
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Supporting Models
struct UserStats {
    let bookings: Int
    let reviews: Int
    let lastActivity: String
}

// MARK: - Extensions
extension UserRole {
    var adminDisplayName: String {
        switch self {
        case .client: return "Клиент"
        case .restaurant: return "Ресторан"
        // Удаляем случай .admin - теперь только CLIENT и RESTAURANT
        }
    }
    
    var adminColor: Color {
        switch self {
        case .client: return .blue
        case .restaurant: return .green
        // Удаляем случай .admin - теперь только CLIENT и RESTAURANT
        }
    }
}

#Preview {
    UserManagementView()
}
