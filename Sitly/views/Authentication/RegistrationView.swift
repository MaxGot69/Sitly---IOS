import SwiftUI

struct RegistrationView: View {
    @StateObject private var viewModel: RegistrationViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var animate = false
    @State private var selectedRole: UserRole = .client
    @State private var showRoleSelection = false
    
    init() {
        let container = DependencyContainer.shared
        self._viewModel = StateObject(wrappedValue: RegistrationViewModel(userUseCase: container.userUseCase))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Фон с градиентом
                LinearGradient(
                    colors: [Color.black, Color.green.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(edges: .all)
                
                // Эффект стекла
                Color.black.opacity(0.3)
                    .blur(radius: 30)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer().frame(height: 60)
                        
                        // Логотип
                        Image(systemName: "person.badge.plus")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(
                                LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: .green.opacity(0.7), radius: 10, x: 0, y: 0)
                            .opacity(animate ? 1 : 0)
                            .scaleEffect(animate ? 1 : 0.8)
                        
                        // Заголовок
                        VStack(spacing: 8) {
                            Text("Создать аккаунт")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .opacity(animate ? 1 : 0)
                                .offset(y: animate ? 0 : 20)
                            
                            Text("Присоединяйтесь к Sitly")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                                .opacity(animate ? 1 : 0)
                                .offset(y: animate ? 0 : 20)
                        }
                        
                        // Форма регистрации
                        VStack(spacing: 20) {
                            // Имя
                            modernTextField(
                                text: $name,
                                placeholder: "Ваше имя",
                                icon: "person.fill"
                            )
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 30)
                            
                            // Email
                            modernTextField(
                                text: $email,
                                placeholder: "Email",
                                icon: "envelope.fill",
                                keyboardType: .emailAddress
                            )
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 30)
                            
                            // Пароль
                            modernSecureField(
                                text: $password,
                                placeholder: "Пароль",
                                icon: "lock.fill",
                                showPassword: $showPassword
                            )
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 30)
                            
                            // Подтверждение пароля
                            modernSecureField(
                                text: $confirmPassword,
                                placeholder: "Подтвердите пароль",
                                icon: "lock.shield.fill",
                                showPassword: $showConfirmPassword
                            )
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 30)
                        }
                        .padding(.horizontal, 32)
                        
                        // Кнопка регистрации
                        Button(action: register) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                            } else {
                                Text("Создать аккаунт")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(18)
                        .shadow(color: .green.opacity(0.5), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 32)
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 30)
                        
                        // Кнопка входа
                        HStack(spacing: 4) {
                            Text("Уже есть аккаунт?")
                                .foregroundColor(.gray)
                            
                            Button("Войти") {
                                dismiss()
                            }
                            .foregroundColor(.mint)
                        }
                        .font(.system(size: 14, weight: .medium))
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 30)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            startAnimations()
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
        .fullScreenCover(isPresented: $showRoleSelection) {
            RoleSelectionView(
                selectedRole: $selectedRole,
                showRoleSelection: $showRoleSelection,
                email: email,
                password: password,
                name: name
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func register() {
        // Валидация
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            viewModel.errorMessage = "Введите ваше имя"
            return
        }
        
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            viewModel.errorMessage = "Введите email"
            return
        }
        
        guard password.count >= 6 else {
            viewModel.errorMessage = "Пароль должен содержать минимум 6 символов"
            return
        }
        
        guard password == confirmPassword else {
            viewModel.errorMessage = "Пароли не совпадают"
            return
        }
        
        // Переходим к выбору роли
        showRoleSelection = true
        HapticService.shared.buttonPress()
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.8)) {
            animate = true
        }
    }
    
    // MARK: - UI Components
    
    private func modernTextField(text: Binding<String>, placeholder: String, icon: String, keyboardType: UIKeyboardType = .default) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
                .frame(width: 24)
            
            TextField(placeholder, text: text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 16)
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
    
    private func modernSecureField(text: Binding<String>, placeholder: String, icon: String, showPassword: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
                .frame(width: 24)
            
            if showPassword.wrappedValue {
                TextField(placeholder, text: text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                SecureField(placeholder, text: text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Button(action: { showPassword.wrappedValue.toggle() }) {
                Image(systemName: showPassword.wrappedValue ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
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
}

#Preview {
    RegistrationView()
}
