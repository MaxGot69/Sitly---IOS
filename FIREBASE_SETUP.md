# 🔥 Настройка Firebase для Sitly

Это руководство поможет вам настроить Firebase для работы с приложением Sitly.

## 📋 Предварительные требования

- Аккаунт Google
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

## 🚀 Пошаговая настройка

### 1. Создание проекта Firebase

1. **Перейдите на [Firebase Console](https://console.firebase.google.com/)**
2. **Нажмите "Создать проект"**
3. **Введите название проекта**: `sitly-ios` (или любое другое)
4. **Отключите Google Analytics** (для MVP не нужен)
5. **Нажмите "Создать проект"**

### 2. Добавление iOS приложения

1. **В консоли Firebase нажмите "iOS"**
2. **Введите Bundle ID**: `com.yourcompany.sitly` (замените на ваш)
3. **Введите название приложения**: `Sitly`
4. **Нажмите "Зарегистрировать приложение"**
5. **Скачайте `GoogleService-Info.plist`**

### 3. Настройка Firebase в Xcode

#### 3.1 Добавление GoogleService-Info.plist

1. **Перетащите `GoogleService-Info.plist` в проект Xcode**
2. **Убедитесь, что файл добавлен в target `Sitly`**
3. **Проверьте, что файл находится в папке `Sitly`**

#### 3.2 Добавление Firebase SDK

1. **В Xcode выберите File → Add Package Dependencies**
2. **Вставьте URL**: `https://github.com/firebase/firebase-ios-sdk.git`
3. **Выберите версию**: `10.0.0` или новее
4. **Выберите пакеты**:
   - `FirebaseAuth`
   - `FirebaseFirestore`
   - `FirebaseAnalytics` (опционально)

### 4. Настройка Firestore Database

#### 4.1 Создание базы данных

1. **В Firebase Console перейдите в "Firestore Database"**
2. **Нажмите "Создать базу данных"**
3. **Выберите "Начать в тестовом режиме"**
4. **Выберите ближайший регион** (например, `europe-west3`)

#### 4.2 Настройка правил безопасности

Замените правила по умолчанию на:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Пользователи могут читать и изменять только свои данные
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Рестораны доступны для чтения всем авторизованным пользователям
    match /restaurants/{restaurantId} {
      allow read: if request.auth != null;
      allow write: if false; // Только админы могут изменять
    }
    
    // Бронирования: пользователи могут читать свои и создавать новые
    match /bookings/{bookingId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         resource.data.restaurantId in get(/databases/$(database)/documents/users/$(request.auth.uid)).data.ownedRestaurants);
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
      allow update: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Отзывы: пользователи могут читать все и создавать свои
    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

### 5. Настройка Authentication

#### 5.1 Включение Email/Password

1. **В Firebase Console перейдите в "Authentication"**
2. **Нажмите "Начать"**
3. **Перейдите на вкладку "Sign-in method"**
4. **Включите "Email/Password"**
5. **Нажмите "Сохранить"**

#### 5.2 Настройка шаблонов email

1. **Перейдите на вкладку "Templates"**
2. **Настройте "Password reset"**:
   - Subject: `Восстановление пароля для Sitly`
   - Message: `Здравствуйте! Для восстановления пароля перейдите по ссылке: {{LINK}}`

### 6. Создание тестовых данных

#### 6.1 Коллекция restaurants

Создайте документ с ID `restaurant_1`:

```json
{
  "name": "Pushkin",
  "cuisine": "Русская",
  "rating": 4.6,
  "description": "Это культовое заведение, известное своим роскошным интерьером в стиле дворянской усадьбы XIX века и изысканной русской кухней.",
  "imageNames": ["Pushkin", "Pushkin2", "Pushkin3"],
  "address": "Тверской бул., 26А, Москва",
  "workHours": "10:00 – 23:00",
  "averageCheck": 1800,
  "coordinate": {
    "latitude": 55.7652,
    "longitude": 37.6041
  },
  "availableTables": 5,
  "phone": "+7 (495) 123-45-67",
  "website": "https://pushkinrestaurant.ru",
  "isOpen": true,
  "features": ["wifi", "parking", "outdoor", "privateRooms"],
  "priceRange": "high",
  "lastUpdated": "2025-01-15T10:00:00Z",
  "searchKeywords": ["pushkin", "русская", "москва", "ресторан", "кухня"]
}
```

#### 6.2 Коллекция users

Создайте документ с ID `user_1`:

```json
{
  "email": "test@example.com",
  "name": "Тестовый Пользователь",
  "phone": "+7 (999) 123-45-67",
  "createdAt": "2025-01-15T10:00:00Z",
  "profileImageURL": null,
  "preferences": {
    "favoriteCuisines": ["Русская", "Европейская"],
    "preferredPriceRange": "medium",
    "notificationsEnabled": true,
    "locationSharingEnabled": true
  }
}
```

### 7. Тестирование подключения

#### 7.1 Проверка аутентификации

1. **Запустите приложение**
2. **Попробуйте зарегистрироваться с новым email**
3. **Проверьте, что пользователь создался в Firestore**

#### 7.2 Проверка загрузки ресторанов

1. **После входа проверьте, что список ресторанов загрузился**
2. **Проверьте консоль Xcode на наличие ошибок**

## 🔧 Решение проблем

### Ошибка "Firebase not configured"

**Проблема**: Приложение не может подключиться к Firebase

**Решение**:
1. Убедитесь, что `GoogleService-Info.plist` добавлен в проект
2. Проверьте, что Bundle ID совпадает с настройками Firebase
3. Перезапустите Xcode

### Ошибка "Permission denied"

**Проблема**: Приложение не может читать/записывать данные

**Решение**:
1. Проверьте правила безопасности Firestore
2. Убедитесь, что пользователь авторизован
3. Проверьте структуру данных

### Ошибка "Network error"

**Проблема**: Проблемы с сетевым подключением

**Решение**:
1. Проверьте интернет-соединение
2. Убедитесь, что Firebase проект активен
3. Проверьте регион Firestore

## 📱 Настройка для продакшена

### 1. Изменение правил безопасности

Для продакшена используйте более строгие правила:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Более строгие правила для продакшена
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /restaurants/{restaurantId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        request.auth.token.admin == true;
    }
    
    // Добавьте rate limiting и другие проверки
  }
}
```

### 2. Настройка мониторинга

1. **Включите Firebase Analytics**
2. **Настройте Crashlytics**
3. **Настройте Performance Monitoring**

### 3. Настройка CI/CD

1. **Создайте Firebase App Distribution**
2. **Настройте автоматические сборки**
3. **Настройте тестирование**

## 📚 Дополнительные ресурсы

- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Firebase Console](https://console.firebase.google.com/)

## 🆘 Поддержка

Если у вас возникли проблемы:

1. **Проверьте консоль Xcode** на наличие ошибок
2. **Проверьте Firebase Console** на наличие ошибок
3. **Создайте Issue** в GitHub репозитории
4. **Обратитесь в поддержку** Firebase

---

**Удачи с настройкой Firebase! 🔥**
