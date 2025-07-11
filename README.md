# FoodieHub - Food Ordering App

A modern, professional food ordering Flutter application with beautiful UI/UX and robust backend integration.

## Features

- **Modern UI/UX**: Beautiful glassmorphism design with smooth animations
- **Dark Mode Support**: Toggle between light and dark themes
- **User Authentication**: Secure login and registration with Supabase
- **Food Menu**: Browse categorized food items with search functionality
- **Shopping Cart**: Add items to cart with quantity management
- **Order History**: Track your previous orders
- **Responsive Design**: Works seamlessly on different screen sizes

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Supabase (PostgreSQL, Authentication, Storage)
- **State Management**: Provider
- **UI Components**: Custom widgets with glassmorphism effects
- **Fonts**: Google Fonts (Poppins, Montserrat)
- **Animations**: Custom animated buttons and transitions

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/E-Canteen-App.git
cd E-Canteen-App
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── providers/               # State management
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   ├── menu_provider.dart
│   └── theme_provider.dart
├── screens/                 # App screens
│   └── splash_screen.dart
├── services/               # API services
│   ├── auth_service.dart
│   └── menu_service.dart
├── widgets/                # Custom widgets
│   ├── animated_button.dart
│   ├── empty_state.dart
│   ├── glassmorphism_container.dart
│   ├── safe_network_image.dart
│   └── skeleton_loader.dart
└── utils/                  # Utilities
    └── image_validator.dart
```

## Configuration

The app uses Supabase for backend services. Make sure to configure your Supabase credentials in `main.dart`.

## Features Overview

### Authentication
- User registration and login
- Password reset functionality
- Secure session management

### Menu Management
- Browse food items by category
- Search functionality
- Real-time loading states
- Error handling with retry options

### Cart & Orders
- Add/remove items from cart
- Quantity management
- Order placement
- Order history tracking

### UI/UX
- Glassmorphism design
- Smooth animations
- Dark/light theme toggle
- Skeleton loading states
- Empty state handling

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
