# 🥪 E-Canteen App

A simple and clean Flutter app for digital canteen ordering.

---

## 📱 What It Does

The E-Canteen app lets users:

- 🍔 **Browse a menu**   
- 🛒 **Add items to cart**  
- 📦 **Place an order**  
- 📜 **View order history**  
- 🔐 **Log in / out**

---

## 📂 Project Structure

```
lib/
├── main.dart
├── providers/
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   └── theme_provider.dart
├── models/
│   ├── cart_item_model.dart
│   ├── category_model.dart
│   ├── menu_item_model.dart
│   ├── order_model.dart
│   └── user_model.dart
├── services/
│   └── firestore_service.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── main/
│   │   ├── home_screen.dart
│   │   ├── cart_screen.dart
│   │   └── profile_screen.dart
│   ├── menu/
│   │   ├── menu_home_screen.dart
│   │   └── category_items_screen.dart
│   └── splash_screen.dart
├── utils/
│   └── app_theme.dart
└── widgets/
    ├── cart_badge.dart
    ├── category_tile.dart
    ├── menu_item_card.dart
    └── quantity_stepper.dart

```

---

## 🚀 Getting Started

Make sure you have Flutter & Android SDK set up.

```bash
flutter pub get
flutter run
```

To build APK:

```bash
flutter build apk
```

---

## ✨ Features that will be added later

- ✅ Firebase Auth  
- 🧾 Razorpay payments  
- 🛍 Dynamic menu from backend  
- 🔔 Push notifications  
- 📦 Real-time order tracking  

---

made with ❤️ by [**petrioteer**](https://github.com/petrioteer)