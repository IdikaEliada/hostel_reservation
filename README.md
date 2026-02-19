# hostel_reservation

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# SOE-305-PROJECT

This is the public repository for our open-source Flutter development project (course/module SOE-305).


## Project Overview

A cross-platform mobile application built with Flutter and Dart.  
(You can add a short 1–2 sentence description of what the app actually does here, e.g., "A task management app with Firebase backend" or whatever fits your project.)


## Getting Started

Follow these steps to set up the project locally:

1. **Clone the repository**  
   ```bash
   git clone https://github.com/IdikaEliada/hostel_reservation.git
   cd SOE-305-PROJECT


2. **Install Flutter dependencies**
   ```bash
   flutter pub get

   
3. **Verify your Flutter environment**
   ```bash
   flutter doctor #Resolve any issues (especially Android toolchain, connected devices, or licenses).

   
4. **Firebase Setup**
   - *Install Firebase CLI (if not already installed):*
     ```bash
     npm install -g firebase-tools
   - *Log in to Firebase:*
     ```bash
     firebase login
   - *(If not already done) Initialize Firebase in your project:*
     ```bash
     flutterfire configure   # Recommended — uses the official FlutterFire CLI
   OR manually:
   - Add google-services.json to android/app/
   - Add GoogleService-Info.plist to ios/Runner/
   - Enable desired services (Auth, Firestore, Storage, etc.) in Firebase Console


5. **Run the app**
   - On a connected emulator/device:
     ```bash
     flutter run
   - Or use VS Code / Android Studio run/debug buttons


## Project Structure

We follow a clean, maintainable structure (inspired by common Flutter best practices):

```
user/
├── domain/              # Business Logic Layer (Independent)
│   ├── entities/        # Pure business objects
│   ├── repositories/     # Repository interfaces (contracts)
│   └── usecases/         # Business logic use cases
├── data/                 # Data Layer (Depends on domain)
│   ├── models/           # Data models (with JSON serialization)
│   ├── datasources/      # Remote & Local data sources
│   └── repositories/     # Repository implementations
├── presentation/         # Presentation Layer (Depends on domain)
│   └── pages/            # UI pages/screens
└── di/                   # Dependency Injection
    └── user_dependency_injection.dart
```

### **Contributors**


- Ibiam Idika 20231390342
- Ekeadah Victory Uchenna 20231361742
- Ogueke Chienweatu Blaise 
20231394752
- Nwite Maximilian Somto
20231404342
- Okpara Fortune Nkemakolam 
20231396212
- Ojigbulem desire chimenum 20231393852
- Jude - okoro Dennis 
20231374472
- Benjamin Hilkiah Ihechukwu 
20231406882
- Anyanwu Emmanuel chisom 
20231401262
- Eke Onyinyechi Kalu
20231390652
- Uche Ezeanyika Davis 
20231391692
- Inyama Prince Chinedu 20231377992
