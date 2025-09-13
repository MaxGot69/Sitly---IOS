import SwiftUI

struct WelcomeView: View {
    @StateObject private var viewModel: WelcomeViewModel
    @State private var animate = false
    @State private var heartbeat = false
    @State private var glowIntensity = false
    
    init() {
        let container = DependencyContainer.shared
        self._viewModel = StateObject(wrappedValue: WelcomeViewModel(userUseCase: container.userUseCase))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Чистый зеленый градиентный фон
                LinearGradient(
                    colors: [
                        Color(red: 0.0, green: 0.4, blue: 0.2),
                        Color(red: 0.0, green: 0.6, blue: 0.3),
                        Color(red: 0.0, green: 0.5, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Крутая анимированная иконка с частицами! 🎆
                    ZStack {
                        // Партиклы вокруг иконки
                        ForEach(0..<8) { index in
                            Image(systemName: "sparkle")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .offset(
                                    x: cos(Double(index) * .pi / 4) * 100,
                                    y: sin(Double(index) * .pi / 4) * 100
                                )
                                .opacity(animate ? 0.8 : 0.3)
                                .scaleEffect(animate ? 1.0 : 0.5)
                                .animation(
                                    .easeInOut(duration: 2.0 + Double(index) * 0.2)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.3),
                                    value: animate
                                )
                        }
                        // Статичное свечение (никаких полетов!)
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.mint.opacity(0.15),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 60,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 200, height: 200)
                            .opacity(0.4)
                        
                        // Крутая анимированная иконка! 😎
                        Image(systemName: "fork.knife.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.white, Color.mint.opacity(0.9)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .scaleEffect(heartbeat ? 1.05 : 1.0)
                            .shadow(
                                color: Color.white.opacity(glowIntensity ? 0.8 : 0.4),
                                radius: glowIntensity ? 25 : 15,
                                x: 0, y: 0
                            )
                            .shadow(
                                color: Color.mint.opacity(glowIntensity ? 0.6 : 0.3),
                                radius: glowIntensity ? 35 : 20,
                                x: 0, y: 0
                            )
                            .opacity(animate ? 1 : 0)
                            .animation(.easeInOut(duration: 0.8).delay(0.1), value: animate)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: heartbeat)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowIntensity)
                    }
                    .frame(height: 250)
                    
                    Spacer().frame(height: 50)
                    
                    // Заголовок (статично!)
                    VStack(spacing: 12) {
                        Text("Добро пожаловать в")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                            .opacity(animate ? 1 : 0)
                            .animation(.easeInOut(duration: 0.8).delay(0.3), value: animate)
                        
                        Text("Sitly")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.mint, Color.white],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .white.opacity(0.5), radius: 8)
                            .opacity(animate ? 1 : 0)
                            .animation(.easeInOut(duration: 0.8).delay(0.5), value: animate)
                        
                        Text("Твой столик уже ждёт 🥂")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(animate ? 1 : 0)
                            .animation(.easeInOut(duration: 0.8).delay(0.7), value: animate)
                    }
                    
                    Spacer()
                    
                    // Кнопки
                    VStack(spacing: 20) {
                        // Главная кнопка с haptic feedback! 🚀
                        Button(action: {
                            HapticService.shared.buttonPress()
                            viewModel.skipAuthentication()
                        }) {
                            Text("Открыть рестораны")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.green.opacity(0.9))
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [Color.mint, Color.white],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 2
                                                )
                                        )
                                )
                                .shadow(color: .white.opacity(0.3), radius: 10)
                        }
                        .padding(.horizontal, 40)
                        .opacity(animate ? 1 : 0)
                        .animation(.easeInOut(duration: 0.8).delay(1.1), value: animate)
                        
                        // Кнопка войти (ахуенная!) 🔥
                        Button(action: {
                            HapticService.shared.buttonPress()
                            viewModel.showLoginScreen()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.badge.key.fill")
                                    .font(.title2)
                                Text("Войти")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(
                                ZStack {
                                    // Основной фон
                                    RoundedRectangle(cornerRadius: 27.5)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.25),
                                                    Color.white.opacity(0.15)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    // Граница
                                    RoundedRectangle(cornerRadius: 27.5)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.8),
                                                    Color.mint.opacity(0.6)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                }
                            )
                            .shadow(color: .white.opacity(0.4), radius: 8, x: 0, y: 4)
                            .shadow(color: .mint.opacity(0.3), radius: 12, x: 0, y: 6)
                        }
                        .padding(.horizontal, 50)
                        .opacity(animate ? 1 : 0)
                        .animation(.easeInOut(duration: 0.8).delay(0.9), value: animate)
                        
                        // Ссылка регистрации ✨
                        Button(action: {
                            HapticService.shared.selection()
                            viewModel.showRegistrationScreen()
                        }) {
                            Text("Нет аккаунта? Зарегистрируйся")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .underline()
                        }
                        .opacity(animate ? 1 : 0)
                        .animation(.easeInOut(duration: 0.8).delay(1.3), value: animate)
                    }
                    
                    Spacer().frame(height: 60)
                }
                .padding(.horizontal, 20)
            }
            .onAppear {
                animate = true
                heartbeat = true
                glowIntensity = true
            }
        }
        .sheet(isPresented: $viewModel.showLogin) {
            LoginView()
        }
        .sheet(isPresented: $viewModel.showRegistration) {
            RegistrationView()
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
}

#Preview {
    WelcomeView()
}
