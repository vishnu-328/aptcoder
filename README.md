# AptCoder 📚

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)


## 🌟 Features

### For Students
- **Interactive Learning**: Engage with hands-on coding exercises and tutorials
- **Progress Tracking**: Monitor your learning journey with detailed progress analytics
- **Course Enrollment**: Access a wide range of coding courses and specializations
- **Offline Access**: Download content for offline learning
- **Achievement System**: Earn points and badges as you progress

### For Administrators
- **Course Management**: Create, update, and manage course content
- **User Analytics**: Track student progress and engagement metrics
- **Content Moderation**: Review and approve course materials
- **Role Management**: Assign roles and permissions to users
- **Dashboard Insights**: Comprehensive analytics and reporting

### Core Features
- **Google Authentication**: Secure sign-in with Google accounts
- **Cross-Platform**: Native Android and iOS support
- **Real-time Sync**: Firebase-powered data synchronization
- **Responsive Design**: Optimized for all screen sizes
- **Dark/Light Themes**: Customizable user interface

## 🛠️ Tech Stack

### Frontend
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Provider**: State management solution

### Backend & Services
- **Firebase Authentication**: User authentication and authorization
- **Cloud Firestore**: NoSQL database for real-time data
- **Firebase Storage**: File storage for media content
- **Firebase Analytics**: User behavior tracking
- **Firebase Messaging**: Push notifications

### Additional Libraries
- **Cached Network Image**: Efficient image loading and caching
- **Video Player**: Video content playback
- **Chewie**: Customizable video controls
- **Syncfusion PDF Viewer**: PDF document viewing
- **FL Chart**: Data visualization and charts
- **Lottie**: Vector animations
- **HTTP/Dio**: Network requests
- **Shared Preferences**: Local data persistence

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version 3.8.1 or higher
  ```bash
  flutter --version
  ```
- **Dart SDK**: Included with Flutter
- **Android Studio**: For Android development (with Android SDK)
- **Xcode**: For iOS development (macOS only)
- **Firebase CLI**: For Firebase configuration
  ```bash
  npm install -g firebase-tools
  ```

## 🚀 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/vishnu-328/aptcoder.git
   cd aptcoder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication with Google Sign-In
   - Enable Firestore Database
   - Enable Storage
   - Add Android and iOS apps to your Firebase project

4. **Configure Firebase for Android**
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/google-services.json`
   - Add your SHA-1 certificate fingerprint to Firebase Console

5. **Configure Firebase for iOS**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place it in `ios/Runner/GoogleService-Info.plist`
   - Add URL schemes to `ios/Runner/Info.plist`

6. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Usage

### Development
```bash
# Run on connected device
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios

# Run tests
flutter test

# Build for production
flutter build apk  # Android
flutter build ios  # iOS
```

### Firebase Configuration

1. **Authentication Setup**
   - Go to Firebase Console → Authentication → Sign-in method
   - Enable Google as a sign-in provider
   - Configure OAuth redirect domains

2. **Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth.uid == userId;
       }
       match /courses/{courseId} {
         allow read: if request.auth != null;
         allow write: if request.auth.token.role == 'admin';
       }
     }
   }
   ```

3. **Storage Security Rules**
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read: if request.auth != null;
         allow write: if request.auth.token.role == 'admin';
       }
     }
   }
   ```

## 📁 Project Structure

```
aptcoder/
├── android/                 # Android-specific files
├── ios/                     # iOS-specific files
├── lib/                     # Flutter source code
│   ├── main.dart           # App entry point
│   ├── firebase_options.dart # Firebase configuration
│   ├── models/             # Data models
│   │   ├── user_model.dart
│   │   └── course_model.dart
│   ├── providers/          # State management
│   │   ├── auth_provider.dart
│   │   ├── course_provider.dart
│   │   └── user_provider.dart
│   ├── screens/            # UI screens
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   └── login_screen.dart
│   │   ├── admin/
│   │   │   └── admin_dashboard.dart
│   │   └── student/
│   │       └── student_dashboard.dart
│   └── utils/              # Utilities
│       └── theme.dart
├── test/                   # Unit and widget tests
├── pubspec.yaml           # Dependencies and configuration
└── README.md              # This file
```

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory for sensitive configuration:

```env
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_APP_ID=your_app_id
```

### Build Flavors
The app supports different build flavors for development and production:

```yaml
# In pubspec.yaml
flavors:
  dev:
    appId: com.example.aptcoder.dev
  prod:
    appId: com.example.aptcoder
```

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```




**Made with ❤️ by vishnu**


