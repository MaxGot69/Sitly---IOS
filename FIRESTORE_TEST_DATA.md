# 🔥 Тестовые данные для Firestore

Этот файл содержит тестовые данные для демонстрации инвесторам. Скопируйте JSON и добавьте в Firebase Console.

## 📍 Коллекция: restaurants

### Ресторан 1: Pushkin
```json
{
  "name": "Pushkin",
  "description": "Это культовое заведение, известное своим роскошным интерьером в стиле дворянской усадьбы XIX века и изысканной русской кухней.",
  "cuisineType": "russian",
  "address": "Тверской бул., 26А, Москва",
  "coordinate": {
    "latitude": 55.7652,
    "longitude": 37.6041
  },
  "phoneNumber": "+7 (495) 739-00-33",
  "website": "https://www.pushkin.ru",
  "rating": 4.6,
  "reviewCount": 1247,
  "priceRange": "high",
  "workingHours": {
    "monday": {"isOpen": true, "openTime": "12:00", "closeTime": "02:00"},
    "tuesday": {"isOpen": true, "openTime": "12:00", "closeTime": "02:00"},
    "wednesday": {"isOpen": true, "openTime": "12:00", "closeTime": "02:00"},
    "thursday": {"isOpen": true, "openTime": "12:00", "closeTime": "02:00"},
    "friday": {"isOpen": true, "openTime": "12:00", "closeTime": "03:00"},
    "saturday": {"isOpen": true, "openTime": "12:00", "closeTime": "03:00"},
    "sunday": {"isOpen": true, "openTime": "12:00", "closeTime": "02:00"}
  },
  "photos": [
    "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800",
    "https://images.unsplash.com/photo-1551632436-cbf8dd35addd?w=800",
    "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800"
  ],
  "isOpen": true,
  "isVerified": true,
  "ownerId": "pushkin-owner-1",
  "subscriptionPlan": "premium",
  "status": "active",
  "features": ["wifi", "parking", "private", "wheelchairAccessible"],
  "searchKeywords": ["pushkin", "пушкин", "русская", "кухня", "элитный", "дорого", "центр"],
  "createdAt": "2024-01-15T10:00:00Z",
  "lastUpdated": "2025-01-15T10:00:00Z"
}
```

### Ресторан 2: White Rabbit
```json
{
  "name": "White Rabbit",
  "description": "Ресторан с панорамным видом на Москву и современной европейской кухней от шеф-повара Владимира Мухина.",
  "cuisineType": "european",
  "address": "Смоленская пл., 3, 16 этаж, Москва",
  "coordinate": {
    "latitude": 55.7488,
    "longitude": 37.5847
  },
  "phoneNumber": "+7 (495) 241-99-99",
  "website": "https://whiterabbit.ru",
  "rating": 4.8,
  "reviewCount": 892,
  "priceRange": "premium",
  "workingHours": {
    "monday": {"isOpen": false, "openTime": "", "closeTime": ""},
    "tuesday": {"isOpen": true, "openTime": "19:00", "closeTime": "02:00"},
    "wednesday": {"isOpen": true, "openTime": "19:00", "closeTime": "02:00"},
    "thursday": {"isOpen": true, "openTime": "19:00", "closeTime": "02:00"},
    "friday": {"isOpen": true, "openTime": "19:00", "closeTime": "02:00"},
    "saturday": {"isOpen": true, "openTime": "19:00", "closeTime": "02:00"},
    "sunday": {"isOpen": true, "openTime": "19:00", "closeTime": "02:00"}
  },
  "photos": [
    "https://images.unsplash.com/photo-1559329007-40df8a9345d8?w=800",
    "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800",
    "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800"
  ],
  "isOpen": true,
  "isVerified": true,
  "ownerId": "whiterabbit-owner-1",
  "subscriptionPlan": "enterprise",
  "status": "active",
  "features": ["wifi", "parking", "outdoorSeating", "private", "wheelchairAccessible"],
  "searchKeywords": ["white rabbit", "вайт рэббит", "европейская", "мухин", "панорама", "вид", "премиум"],
  "createdAt": "2024-02-01T10:00:00Z",
  "lastUpdated": "2025-01-15T10:00:00Z"
}
```

### Ресторан 3: Café Pушкинъ
```json
{
  "name": "Dr. Живаго",
  "description": "Современная интерпретация русской кухни в историческом здании с видом на Кремль.",
  "cuisineType": "russian",
  "address": "Моховая ул., 15/1, Москва",
  "coordinate": {
    "latitude": 55.7520,
    "longitude": 37.6175
  },
  "phoneNumber": "+7 (495) 789-96-96",
  "website": "https://drzhivago.ru",
  "rating": 4.5,
  "reviewCount": 634,
  "priceRange": "high",
  "workingHours": {
    "monday": {"isOpen": true, "openTime": "12:00", "closeTime": "00:00"},
    "tuesday": {"isOpen": true, "openTime": "12:00", "closeTime": "00:00"},
    "wednesday": {"isOpen": true, "openTime": "12:00", "closeTime": "00:00"},
    "thursday": {"isOpen": true, "openTime": "12:00", "closeTime": "00:00"},
    "friday": {"isOpen": true, "openTime": "12:00", "closeTime": "01:00"},
    "saturday": {"isOpen": true, "openTime": "12:00", "closeTime": "01:00"},
    "sunday": {"isOpen": true, "openTime": "12:00", "closeTime": "00:00"}
  },
  "photos": [
    "https://images.unsplash.com/photo-1590846406792-0adc7f938f1d?w=800",
    "https://images.unsplash.com/photo-1587899897387-091261b7fbfa?w=800"
  ],
  "isOpen": true,
  "isVerified": true,
  "ownerId": "drzhivago-owner-1",
  "subscriptionPlan": "premium",
  "status": "active",
  "features": ["wifi", "parking", "private", "liveMusic", "wheelchairAccessible"],
  "searchKeywords": ["доктор живаго", "русская", "кухня", "кремль", "исторический", "центр"],
  "createdAt": "2024-03-01T10:00:00Z",
  "lastUpdated": "2025-01-15T10:00:00Z"
}
```

### Ресторан 4: Sakura
```json
{
  "name": "Sakura",
  "description": "Аутентичная японская кухня с мастер-классами по приготовлению суши от японских поваров.",
  "cuisineType": "japanese",
  "address": "Ленинский проспект, 42, Москва",
  "coordinate": {
    "latitude": 55.7000,
    "longitude": 37.5000
  },
  "phoneNumber": "+7 (495) 987-65-43",
  "website": "https://sakura-moscow.ru",
  "rating": 4.4,
  "reviewCount": 456,
  "priceRange": "medium",
  "workingHours": {
    "monday": {"isOpen": true, "openTime": "12:00", "closeTime": "23:00"},
    "tuesday": {"isOpen": true, "openTime": "12:00", "closeTime": "23:00"},
    "wednesday": {"isOpen": true, "openTime": "12:00", "closeTime": "23:00"},
    "thursday": {"isOpen": true, "openTime": "12:00", "closeTime": "23:00"},
    "friday": {"isOpen": true, "openTime": "12:00", "closeTime": "00:00"},
    "saturday": {"isOpen": true, "openTime": "12:00", "closeTime": "00:00"},
    "sunday": {"isOpen": true, "openTime": "12:00", "closeTime": "23:00"}
  },
  "photos": [
    "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800",
    "https://images.unsplash.com/photo-1553621042-f6e147245754?w=800"
  ],
  "isOpen": true,
  "isVerified": true,
  "ownerId": "sakura-owner-1",
  "subscriptionPlan": "free",
  "status": "active",
  "features": ["wifi", "delivery", "takeaway"],
  "searchKeywords": ["sakura", "сакура", "японская", "суши", "роллы", "мастер-класс"],
  "createdAt": "2024-04-01T10:00:00Z",
  "lastUpdated": "2025-01-15T10:00:00Z"
}
```

### Ресторан 5: Trattoria Bella
```json
{
  "name": "Trattoria Bella",
  "description": "Семейная итальянская траттория с домашними рецептами и уютной атмосферой.",
  "cuisineType": "italian",
  "address": "Кутузовский проспект, 8, Москва",
  "coordinate": {
    "latitude": 55.7500,
    "longitude": 37.5500
  },
  "phoneNumber": "+7 (495) 555-12-34",
  "website": "https://trattoriabella.ru",
  "rating": 4.3,
  "reviewCount": 289,
  "priceRange": "medium",
  "workingHours": {
    "monday": {"isOpen": true, "openTime": "11:00", "closeTime": "23:00"},
    "tuesday": {"isOpen": true, "openTime": "11:00", "closeTime": "23:00"},
    "wednesday": {"isOpen": true, "openTime": "11:00", "closeTime": "23:00"},
    "thursday": {"isOpen": true, "openTime": "11:00", "closeTime": "23:00"},
    "friday": {"isOpen": true, "openTime": "11:00", "closeTime": "00:00"},
    "saturday": {"isOpen": true, "openTime": "11:00", "closeTime": "00:00"},
    "sunday": {"isOpen": true, "openTime": "11:00", "closeTime": "23:00"}
  },
  "photos": [
    "https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800",
    "https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?w=800"
  ],
  "isOpen": true,
  "isVerified": true,
  "ownerId": "bella-owner-1",
  "subscriptionPlan": "premium",
  "status": "active",
  "features": ["wifi", "parking", "liveMusic", "petFriendly", "kidsMenu"],
  "searchKeywords": ["trattoria bella", "траттория белла", "итальянская", "паста", "пицца", "семейный"],
  "createdAt": "2024-05-01T10:00:00Z",
  "lastUpdated": "2025-01-15T10:00:00Z"
}
```

## 👥 Коллекция: users

### Тестовый пользователь 1
```json
{
  "email": "demo@sitly.app",
  "name": "Демо Пользователь",
  "role": "client",
  "phoneNumber": "+7 (999) 123-45-67",
  "profileImageURL": null,
  "createdAt": "2025-01-01T10:00:00Z",
  "lastLoginAt": "2025-01-15T10:00:00Z",
  "restaurantId": null,
  "isVerified": true,
  "subscriptionPlan": null,
  "preferences": {
    "cuisineTypes": ["Русская", "Европейская", "Итальянская"],
    "priceRange": "medium",
    "maxDistance": 10.0,
    "preferredTimes": ["19:00", "20:00"],
    "dietaryRestrictions": [],
    "notificationSettings": {
      "pushEnabled": true,
      "emailEnabled": true,
      "smsEnabled": false,
      "bookingConfirmations": true,
      "bookingReminders": true,
      "promotions": false,
      "newRestaurants": true
    }
  },
  "favoriteRestaurants": ["pushkin-id", "whiterabbit-id"]
}
```

### Владелец ресторана
```json
{
  "email": "owner@pushkin.ru",
  "name": "Александр Петров",
  "role": "restaurant",
  "phoneNumber": "+7 (495) 739-00-33",
  "profileImageURL": null,
  "createdAt": "2024-01-01T10:00:00Z",
  "lastLoginAt": "2025-01-15T09:00:00Z",
  "restaurantId": "pushkin-id",
  "isVerified": true,
  "subscriptionPlan": "premium",
  "preferences": null,
  "favoriteRestaurants": null
}
```

## 📅 Коллекция: bookings

### Бронирование 1 (предстоящее)
```json
{
  "restaurantId": "pushkin-id",
  "userId": "demo-user-id",
  "date": "2025-01-20T19:00:00Z",
  "time": "19:00",
  "guestCount": 2,
  "tableType": "window",
  "specialRequests": "Столик у окна для романтического ужина",
  "contactPhone": "+7 (999) 123-45-67",
  "status": "confirmed",
  "createdAt": "2025-01-15T10:00:00Z",
  "updatedAt": "2025-01-15T10:30:00Z"
}
```

### Бронирование 2 (завершенное)
```json
{
  "restaurantId": "whiterabbit-id",
  "userId": "demo-user-id",
  "date": "2025-01-10T20:00:00Z",
  "time": "20:00",
  "guestCount": 4,
  "tableType": "private",
  "specialRequests": "Отмечаем день рождения, нужен торт",
  "contactPhone": "+7 (999) 123-45-67",
  "status": "completed",
  "createdAt": "2025-01-05T10:00:00Z",
  "updatedAt": "2025-01-10T22:00:00Z"
}
```

## ⭐ Коллекция: reviews

### Отзыв 1
```json
{
  "restaurantId": "pushkin-id",
  "userId": "demo-user-id",
  "userName": "Демо Пользователь",
  "rating": 4.5,
  "text": "Отличный ресторан! Очень вкусная еда и приятная атмосфера. Обслуживание на высшем уровне.",
  "createdAt": "2025-01-11T10:00:00Z",
  "isVerified": true
}
```

### Отзыв 2
```json
{
  "restaurantId": "whiterabbit-id",
  "userId": "demo-user-id",
  "userName": "Демо Пользователь",
  "rating": 5.0,
  "text": "Невероятный вид на Москву! Кухня на мишленовском уровне. Немного дорого, но того стоит.",
  "createdAt": "2025-01-11T20:00:00Z",
  "isVerified": true
}
```

## 🚀 Инструкция по добавлению данных

1. **Откройте Firebase Console**
2. **Перейдите в Firestore Database**
3. **Создайте коллекции:** `restaurants`, `users`, `bookings`, `reviews`
4. **Добавьте документы** используя JSON выше
5. **Проверьте правила безопасности:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Рестораны доступны для чтения всем
    match /restaurants/{restaurantId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Пользователи - только свои данные
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Бронирования - свои и рестораны
    match /bookings/{bookingId} {
      allow read, create: if request.auth != null;
      allow update: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Отзывы - чтение всем, запись авторизованным
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

## ✅ Готово!

После добавления этих данных приложение будет работать с реальной Firebase и готово к презентации инвесторам! 🎉
