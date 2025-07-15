> [!NOTE]
> This project is currently under active development. Features are being added and improved!
# NomNom 🍔 [IN DEVELOPMENT]
A modern and beautiful e-canteen mobile application built with Flutter and Firebase. Browse, order, and enjoy your favorite meals with a seamless and delightful user experience.

---


## About The Project

This project started as a simple digital canteen concept and has been completely rebuilt from the ground up. **NomNom** is now a full-featured, scalable, and production-ready mobile app. It leverages a modern tech stack and follows best practices for state management, database integration, and UI/UX design.

The core idea is to provide a user-friendly platform for ordering food, while giving the developer (you!) a solid foundation to build even more amazing features upon.

### Key Features ✨

* **Full Authentication Suite:**
    * Sign up with Email & Password.
    * Sign in with Google for one-tap access.
    * Secure "Forgot Password" functionality.
* **Dynamic Menu System:**
    * Food items are neatly organized into categories.
    * Beautiful, image-rich tile layout for easy browsing.
    * Detailed view for each food item with description, price, and image.
* **Interactive Shopping Cart:**
    * Add items to your cart with a single tap.
    * Easily increase or decrease the quantity of items.
    * Real-time calculation of the total order amount.
* **Seamless Checkout Process:**
    * Prompts first-time users to enter their delivery address and phone number.
    * Securely saves user address details to their profile for future orders.
    * Pre-fills saved address for returning users, making checkout a breeze.
* **Personalized User Profile:**
    * View and manage your profile information.
    * **Complete Order History:** See a list of all your past orders, including items, total cost, and date placed.
    * **Light & Dark Mode:** A theme toggle to switch between a beautiful light theme and a sleek dark theme.
* **Robust Backend:**
    * Built on **Firebase**, providing a secure and scalable backend.
    * **Cloud Firestore** to store user profiles, orders, and menu data.
    * **Firebase Authentication** to manage user identities securely.

### Built With

This project uses a selection of modern and powerful technologies:

* [Flutter](https://flutter.dev/) - The core framework for building the beautiful UI.
* [Dart](https://dart.dev/) - The language that powers Flutter.
* [Firebase](https://firebase.google.com/) - For all our backend needs.
    * Firebase Authentication
    * Cloud Firestore
* [Provider](https://pub.dev/packages/provider) - For simple and effective state management.
* [animate_do](https://pub.dev/packages/animate_do) - For creating elegant animations with minimal effort.
* [intl](https://pub.dev/packages/intl) - For beautiful date and number formatting.

---

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

Make sure you have the Flutter SDK installed on your machine. You can find instructions [here](https://flutter.dev/docs/get-started/install).

### Setup & Installation

1.  **Clone the repository:**
    ```sh
    git clone [https://github.com/petrioteer/E-Canteen-App.git](https://github.com/petrioteer/E-Canteen-App.git)
    ```

2.  **Set up your Firebase Project:**
    * Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
    * Register a new **Android** app with the package name `com.nomnom.app`.
    * Follow the setup instructions to download the `google-services.json` file.
    * Place the downloaded `google-services.json` file inside the `android/app/` directory of the project.
    * In the Firebase console, go to **Authentication** -> **Sign-in method** and enable both **Email/Password** and **Google**.
    * Go to **Firestore Database**, create a database, and start in **test mode** for now.
    * Finally, don't forget to add your **SHA-1 fingerprint** to the Firebase project settings to enable Google Sign-In.

3.  **Install Packages:**
    ```sh
    flutter pub get
    ```

4.  **Run the App:**
    ```sh
    flutter run
    ```

---

## Project Structure

The project follows a clean and scalable structure to make it easy to find files and add new features.

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models (User, Order, etc.)
├── providers/                # State management (Auth, Cart, Theme)
├── screens/                  # All the UI screens for the app
│   ├── auth/
│   ├── main/
│   └── menu/
├── services/                 # Services like Firestore
├── utils/                    # Utility files like AppTheme
└── widgets/                  # Reusable UI components
```
---

## Future Goals 🚀

This project has a solid foundation, but there's always room for more! Here are some features planned for the future:

* [ ] **Menu Search:** A search bar to quickly find specific food items.
* [ ] **Real-Time Order Tracking:** See the status of your order live (e.g., "Preparing," "On Counter").
* [ ] **User Profile Pictures:** Allow users to upload their own profile photos.
* [ ] **Ratings & Reviews:** Let users rate and review food items.
* [ ] **Payment Gateway Integration:** Add support for online payments.

---

made with ❤️ by [**petrioteer**](https://github.com/petrioteer)
