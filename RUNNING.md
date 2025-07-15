# How to Run the E-Canteen App

## Prerequisites

- Flutter SDK installed
- Android SDK installed
- Android Studio or VS Code with Flutter plugin

## Steps to Run

### 1. Accept Android Licenses (Run once)

```bash
./accept_licenses.sh
```

### 2. Get Flutter Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
flutter run
```

## Troubleshooting

### NDK Issues

- Installing NDK version 25.2.9519653 through Android Studio's SDK Manager
- Or modify the `ndkVersion` in `android/app/build.gradle.kts` to match your installed version

### Firebase Issues

- Check that google-services.json is properly set up
- Verify the applicationId in build.gradle.kts matches the one in Firebase console

### Google Sign In

- Verify SHA-1 fingerprint is added to Firebase console
- Check internet connectivity
