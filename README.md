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
├── main.dart                     # Entry point
├── models/
│   └── menu_item.dart            # Menu item data model
├── state/
│   └── app_state.dart            # Simple app-wide state
├── screens/
│   ├── login_screen.dart         # Login UI
│   ├── home_screen.dart          # Bottom nav + routing
│   ├── menu_screen.dart          # Food menu
│   ├── cart_screen.dart          # Cart view & checkout
│   └── order_history_screen.dart # Order history
├── widgets/
│   └── cart_badge.dart           #reusable cart badge
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