import SwiftUI

struct ContentView: View {
    @State private var showLogo = false
    @State private var showText = false
    @State private var showButton = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.black, .gray.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    // ЛОГОТИП
                    Image(systemName: "fork.knife.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                        .scaleEffect(showLogo ? 1 : 0.5)
                        .opacity(showLogo ? 1 : 0)
                        .animation(.easeOut(duration: 0.5), value: showLogo)

                    // ПРИВЕТСТВИЕ
                    Text("Добро пожаловать в Sitly")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(showText ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showText)

                    // Подзаголовок
                    Text("Где ваш столик уже ждёт вас!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .opacity(showText ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: showText)
                    
                    


                    Spacer().frame(height: 10)

                    // КНОПКА НАВИГАЦИИ
                    NavigationLink("Перейти к ресторанам", destination: RestaurantListView())
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .opacity(showButton ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.4), value: showButton)

                    // Подпись под кнопкой
                    Text("Открой лучшие рестораны рядом 🍽️")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                        .opacity(showButton ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.5), value: showButton)

                    // КНОПКА РЕГИСТРАЦИИ
                    Button(action: {
                        // Пока ничего, позже сделаем переход
                    }) {
                        Text("Нет аккаунта? Зарегистрируйся")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .underline()
                    }
                    .opacity(showButton ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.6), value: showButton)
                }
                .padding()
            }
            .onAppear {
                showLogo = true
                showText = true
                showButton = true
            }
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    ContentView()
}
