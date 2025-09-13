# Sitly — iOS Restaurant Reservation App

Sitly - это мобильное приложение для поиска ресторанов и бронирования столиков, построенное на SwiftUI с использованием современной архитектуры MVVM и Firebase.

## 🚀 Текущий статус

✅ **MVP версия готова к работе!**

- ✅ Реальная аутентификация через Firebase Auth
- ✅ Работающий бэкенд на Firebase Firestore
- ✅ Современный UI/UX дизайн
- ✅ Полная архитектура MVVM
- ✅ Кэширование и офлайн режим
- ✅ Геолокация и карты
- ✅ Система бронирований

## 🛠 Технологический стек

| Слой | Технология |
|------|------------|
| Язык | Swift 5.9+ |
| UI Framework | SwiftUI |
| Архитектура | MVVM + Clean Architecture |
| Бэкенд | Firebase (Auth + Firestore) |
| Карты | MapKit |
| Версия iOS | 17.0+ |
| Управление зависимостями | Swift Package Manager |

## 📱 Основные функции

### 🔐 Аутентификация
- Регистрация и вход через email/password
- Восстановление пароля
- Автоматическое сохранение сессии

### 🍽 Поиск ресторанов
- Поиск по названию, кухне, адресу
- Фильтрация по типу кухни
- Сортировка по рейтингу и расстоянию
- Карта с расположением ресторанов

### 📅 Бронирование столиков
- Выбор даты и времени
- Выбор количества гостей
- Выбор типа столика
- Подтверждение бронирования

### 👤 Профиль пользователя
- Управление личными данными
- История бронирований
- Настройки уведомлений

## 🚀 Быстрый старт

### 1. Клонирование репозитория
```bash
git clone https://github.com/yourusername/sitly-ios.git
cd sitly-ios
```

### 2. Настройка Firebase

#### 2.1 Создание проекта Firebase
1. Перейдите на [Firebase Console](https://console.firebase.google.com/)
2. Создайте новый проект
3. Добавьте iOS приложение
4. Скачайте `GoogleService-Info.plist`

#### 2.2 Настройка Firebase в проекте
1. Замените `Sitly/GoogleService-Info.plist` на ваш файл
2. Обновите Bundle ID в Xcode проекте
3. Добавьте Firebase SDK через Swift Package Manager

#### 2.3 Настройка Firestore
Создайте следующие коллекции в Firestore:

**restaurants**
```json
{
  "name": "Pushkin",
  "cuisine": "Русская",
  "rating": 4.6,
  "description": "Культовое заведение...",
  "address": "Тверской бул., 26А, Москва",
  "coordinate": {
    "latitude": 55.7652,
    "longitude": 37.6041
  },
  "availableTables": 5,
  "searchKeywords": ["pushkin", "русская", "москва"]
}
```

**users**
```json
{
  "email": "user@example.com",
  "name": "Имя пользователя",
  "phone": "+7 (999) 123-45-67",
  "preferences": {
    "favoriteCuisines": ["Русская", "Европейская"],
    "preferredPriceRange": "medium"
  }
}
```

**bookings**
```json
{
  "restaurantId": "restaurant_uuid",
  "userId": "user_uuid",
  "date": "2025-01-15T19:00:00Z",
  "time": "19:00",
  "guestCount": 2,
  "tableType": "window",
  "status": "pending"
}
```

### 3. Запуск проекта
1. Откройте `Sitly.xcodeproj` в Xcode
2. Выберите симулятор или устройство
3. Нажмите ▶️ для запуска

## 🏗 Архитектура проекта

```
Sitly/
├── Core/                    # Основные компоненты
│   ├── AppState.swift      # Глобальное состояние приложения
│   └── DI/                 # Dependency Injection
├── Domain/                 # Бизнес-логика
│   ├── Models/            # Модели данных
│   ├── Protocols/         # Протоколы и интерфейсы
│   └── UseCases/          # Сценарии использования
├── Data/                  # Слой данных
│   ├── Repositories/      # Репозитории
│   └── Services/          # Сервисы (Network, Cache, Storage)
├── ViewModels/            # ViewModels для MVVM
├── views/                 # UI компоненты
└── Services/              # Дополнительные сервисы
```

## 🔧 Конфигурация

### Переменные окружения
Создайте файл `Config.xcconfig`:
```xcconfig
FIREBASE_PROJECT_ID = your-project-id
FIREBASE_API_KEY = your-api-key
```

### Настройка сборки
- **Debug**: Использует Firebase dev окружение
- **Release**: Использует Firebase production окружение

## 📱 Скриншоты

### Welcome Screen
![Welcome](./Assets/welcome.png)

### Restaurant List
![Restaurant List](./Assets/restaurant-list.png)

## 🧪 Тестирование

### Unit Tests
```bash
# Запуск всех тестов
xcodebuild test -scheme Sitly -destination 'platform=iOS Simulator,name=iPhone 15'

# Запуск конкретного теста
xcodebuild test -scheme Sitly -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:SitlyTests/RestaurantUseCaseTests
```

### UI Tests
```bash
xcodebuild test -scheme Sitly -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:SitlyUITests
```

## 🚀 Развертывание

### 1. Подготовка к релизу
1. Обновите версию в `Info.plist`
2. Настройте Firebase production окружение
3. Проведите финальное тестирование

### 2. Сборка для App Store
```bash
xcodebuild archive -scheme Sitly -archivePath build/Sitly.xcarchive
xcodebuild -exportArchive -archivePath build/Sitly.xcarchive -exportPath build/Export -exportOptionsPlist ExportOptions.plist
```

### 3. Загрузка в App Store Connect
1. Откройте Xcode Organizer
2. Выберите архив
3. Нажмите "Distribute App"

## 🤝 Вклад в проект

1. Fork репозитория
2. Создайте feature branch (`git checkout -b feature/amazing-feature`)
3. Commit изменения (`git commit -m 'Add amazing feature'`)
4. Push в branch (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

## 📄 Лицензия

Этот проект лицензирован под [MIT License](LICENSE).

## 📞 Поддержка

- 📧 Email: support@sitly.app
- 💬 Telegram: @sitly_support
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/sitly-ios/issues)

## 🎯 Roadmap

### v1.1 (Q1 2025)
- [ ] Push-уведомления
- [ ] Apple Sign In
- [ ] Google Sign In
- [ ] Биометрическая аутентификация

### v1.2 (Q2 2025)
- [ ] Система отзывов
- [ ] Рейтинговая система
- [ ] Персональные рекомендации
- [ ] Интеграция с платежными системами

### v2.0 (Q3 2025)
- [ ] Админ-панель для ресторанов
- [ ] AI-рекомендации
- [ ] Мультиязычность
- [ ] Темная/светлая тема

---

**Sitly** - Твой столик уже ждёт! 🥂
