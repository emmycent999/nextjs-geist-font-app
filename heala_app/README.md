# Heala - Healthcare at Your Fingertips

A comprehensive telehealth mobile application built with Flutter, designed to improve healthcare access in Nigeria by connecting patients with healthcare professionals.

## 🏥 About Heala

Heala is a telehealth platform that provides:
- **Patient-Doctor Connections**: Easy access to verified healthcare professionals
- **Teleconsultations**: Video and audio consultations from anywhere
- **AI Health Assistant**: Symptom checker with escalation to real doctors
- **Emergency Services**: Quick access to emergency contacts and services
- **Appointment Management**: Seamless booking and management system
- **Offline Support**: Works in low-bandwidth conditions

## 🚀 Features

### Core MVP Features

#### 🔐 Authentication
- Secure sign-up and login for patients and healthcare professionals
- Role-based access control
- Password reset functionality
- Profile verification for healthcare professionals

#### 👤 Profile Management
- Comprehensive user profiles
- Medical history tracking for patients
- Professional credentials for healthcare providers
- Emergency contact management

#### 📅 Appointment Booking
- Search and filter healthcare professionals by specialty
- Real-time availability checking
- Multiple consultation types (video, audio, in-person)
- Appointment scheduling and management

#### 💻 Teleconsultation
- High-quality video and audio calls using WebRTC
- Call controls (mute, camera toggle, speaker)
- Connection status monitoring
- Cross-platform compatibility

#### 🚨 Emergency Services
- One-tap access to emergency hotlines
- Ambulance request functionality
- Nearest hospital finder
- First aid guidance
- Emergency contact management

#### 🤖 AI Health Assistant
- Intelligent symptom checker
- Health guidance and recommendations
- Escalation to live doctors
- Medical knowledge base

#### 🔔 Push Notifications
- Appointment reminders
- Medication alerts
- Emergency notifications
- Real-time updates

## 🛠 Tech Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language
- **Provider**: State management
- **Material Design**: UI components

### Backend & Services
- **Supabase**: Authentication, database, and real-time features
- **WebRTC**: Video/audio calling infrastructure
- **Firebase Cloud Messaging**: Push notifications
- **Hive**: Local offline storage

### Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^1.0.0      # Backend services
  flutter_webrtc: ^0.9.20       # Video calling
  firebase_messaging: ^14.0.1   # Push notifications
  hive_flutter: ^1.1.0          # Offline storage
  provider: ^6.0.3              # State management
  url_launcher: ^6.1.12         # External links
  image_picker: ^1.0.4          # Profile photos
  http: ^1.1.0                  # API requests
  intl: ^0.18.0                 # Internationalization
```

## 📁 Project Structure

```
heala_app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── user.dart
│   │   ├── appointment.dart
│   │   └── chat_message.dart
│   ├── services/                 # Business logic
│   │   ├── auth_service.dart
│   │   ├── appointment_service.dart
│   │   ├── call_service.dart
│   │   ├── chatbot_service.dart
│   │   ├── notification_service.dart
│   │   └── storage_service.dart
│   ├── screens/                  # UI screens
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── home_screen.dart
│   │   ├── appointment_booking_screen.dart
│   │   ├── teleconsultation_screen.dart
│   │   ├── emergency_screen.dart
│   │   ├── chatbot_screen.dart
│   │   └── profile_screen.dart
│   └── widgets/                  # Reusable components
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── doctor_card.dart
│       └── chat_bubble.dart
├── android/                      # Android configuration
├── ios/                         # iOS configuration
├── assets/                      # App assets
└── test/                        # Unit tests
```

## 🎨 Design System

### Color Palette
- **Primary Blue**: `#0077CC` - Trust and professionalism
- **Secondary Green**: `#4CAF50` - Health and vitality
- **Emergency Orange**: `#FF9800` - Urgent care and alerts
- **Background**: `#F5F7FA` - Clean, modern interface
- **Text**: `#333333` - High readability

### Typography
- **Headers**: Bold, clear hierarchy
- **Body Text**: Readable, accessible fonts
- **UI Elements**: Consistent sizing and spacing

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (>=2.19.0)
- Dart SDK
- Android Studio / Xcode
- Supabase account
- Firebase project

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd heala_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a Supabase project
   - Update `lib/main.dart` with your Supabase URL and anon key
   - Set up database tables for users, appointments, etc.

4. **Configure Firebase**
   - Create a Firebase project
   - Add Android/iOS apps to Firebase
   - Download and add configuration files
   - Enable Cloud Messaging

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screens Overview

### Authentication Flow
- **Splash Screen**: App initialization and routing
- **Login Screen**: User authentication
- **Signup Screen**: Multi-step registration process

### Main Application
- **Home Screen**: Dashboard with quick actions and upcoming appointments
- **Appointment Booking**: Doctor search, selection, and scheduling
- **Teleconsultation**: Video/audio calling interface
- **Emergency Services**: Quick access to emergency contacts and services
- **AI Chatbot**: Symptom checker and health guidance
- **Profile Management**: User settings and information

## 🔒 Security Features

- **End-to-end encryption** for sensitive medical data
- **Secure authentication** with Supabase Auth
- **Data validation** and sanitization
- **Privacy controls** for user information
- **Compliance** with healthcare data protection standards

## 🌍 Accessibility & Localization

- **Responsive design** for various screen sizes
- **Accessibility features** for users with disabilities
- **Offline functionality** for low-bandwidth areas
- **Nigerian healthcare context** optimization

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 📈 Performance Optimization

- **Lazy loading** for large lists
- **Image optimization** and caching
- **Efficient state management** with Provider
- **Offline-first architecture** with Hive storage
- **Network optimization** for low-bandwidth scenarios

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- **Email**: support@heala.ng
- **Phone**: +234 800 HEALA
- **Website**: www.heala.ng

For emergencies, always call **199** (Nigeria Emergency Services).

## 🔮 Future Enhancements

- **Prescription management** system
- **Health records integration**
- **Insurance claim processing**
- **Multi-language support**
- **Wearable device integration**
- **Advanced AI diagnostics**
- **Telemedicine marketplace**

## 📊 Analytics & Monitoring

- **User engagement tracking**
- **Performance monitoring**
- **Error reporting and logging**
- **Healthcare outcome metrics**

---

**Heala** - Connecting Nigeria to Quality Healthcare 🇳🇬

Built with ❤️ for better healthcare access in Nigeria.
