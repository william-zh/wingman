# Wingman - Real Talk from Real Guys

A comprehensive dating safety app designed specifically for men, providing background checks, community warnings, and safety tools to navigate the modern dating landscape safely.

## 🛡️ Features

### Core Safety Features
- **Background Checks**: Comprehensive verification including criminal records, sex offender registry, and financial fraud history
- **Reverse Image Search**: Detect catfish profiles using stolen photos
- **Phone Number Verification**: Validate phone numbers against scammer databases
- **AI Catfish Detection**: Advanced algorithms to identify fake profiles
- **Financial Fraud Protection**: Alerts for money requests and investment scams

### Community Intelligence
- **Anonymous Warnings**: Share experiences without revealing identity
- **Community Reports**: Crowdsourced database of known scammers
- **Safety Tips**: Learn from collective community experience
- **Verification Badges**: Build trust with identity verification

### Privacy & Security
- **End-to-End Encryption**: All sensitive data encrypted
- **Anonymous Reporting**: Share warnings without compromising identity
- **PII Protection**: Automatic detection and removal of personal information
- **Secure Storage**: Industry-standard encryption for all user data

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Firebase CLI
- Android Studio / Xcode for mobile development

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/wingman.git
   cd wingman
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   ```bash
   # Install Firebase CLI if not already installed
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase in your project
   firebase init
   
   # Generate Firebase configuration
   flutterfire configure
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── user.dart            # User model with safety features
│   ├── safety_report.dart   # Community reports and warnings
│   └── background_check.dart # Background check results
├── services/                # Business logic
│   ├── auth_service.dart    # Authentication and user management
│   ├── background_check_service.dart # Safety verification
│   └── privacy_service.dart # Encryption and anonymization
├── screens/                 # UI screens
│   ├── auth/               # Login and registration
│   ├── home/               # Dashboard and overview
│   ├── safety/             # Safety tools and background checks
│   └── community/          # Community warnings and tips
└── widgets/                # Reusable UI components
```

### Key Services

#### AuthService
- Firebase Authentication integration
- User profile management
- Email/phone verification
- Account security features

#### BackgroundCheckService
- Phone number validation
- Criminal record searches
- Social media profile verification
- Risk score calculation

#### PrivacyService
- Data encryption/decryption
- PII detection and removal
- Anonymous identifier generation
- Security event logging

## 🔒 Security & Privacy

### Data Protection
- **AES-256 Encryption**: All sensitive data encrypted at rest
- **SHA-256 Hashing**: Phone numbers and emails hashed for lookups
- **Anonymous Reporting**: Community features preserve user privacy
- **GDPR Compliant**: Full user data control and deletion rights

### Safety Features
- **Rate Limiting**: Prevents abuse of background check APIs
- **Input Validation**: Protects against injection attacks
- **Secure Storage**: Sensitive data never stored in plain text
- **Audit Logging**: Security events logged without PII

## 🔌 API Integration

### Background Check APIs
The app integrates with various verification services:
- Criminal background check services
- Phone number validation APIs
- Social media verification
- Reverse image search
- Scammer databases

### Configuration
Create a `.env` file with your API keys:
```
BACKGROUND_CHECK_API_KEY=your_api_key
PHONE_VERIFICATION_API_KEY=your_api_key
IMAGE_SEARCH_API_KEY=your_api_key
```

## 🤝 Contributing

We welcome contributions to improve Wingman's safety features:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Guidelines
- Follow Flutter/Dart style guidelines
- Add tests for new features
- Update documentation for API changes
- Ensure privacy and security best practices

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 12.0+)
- ✅ Web (Chrome, Firefox, Safari, Edge)
- 🔄 macOS (Coming soon)
- 🔄 Windows (Coming soon)

## 🛠️ Development

### Running Tests
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Code Analysis
```bash
flutter analyze
```

## 📊 Performance

### Metrics
- App startup time: < 2 seconds
- Background check completion: 30-60 seconds
- Community data sync: Real-time
- Offline functionality: Core features available

### Optimization
- Lazy loading for large datasets
- Image caching and compression
- Background processing for heavy operations
- Efficient state management with Provider

## 🔐 Security Disclosure

If you discover a security vulnerability, please email security@wingman-app.com instead of opening a public issue. We take security seriously and will respond promptly.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Tea for Women** - Inspiration for women's safety features
- **Firebase** - Backend infrastructure
- **Flutter Community** - Amazing framework and ecosystem
- **Security Researchers** - Vulnerability disclosure and best practices

## 📞 Support

- **Documentation**: [docs.wingman-app.com](https://docs.wingman-app.com)
- **Community**: [Discord Server](https://discord.gg/wingman)
- **Issues**: [GitHub Issues](https://github.com/yourusername/wingman/issues)
- **Email**: support@wingman-app.com

## 🚨 Disclaimer

Wingman is a safety tool designed to help users make informed decisions. While we strive for accuracy, no background check service is 100% complete. Users should always exercise personal judgment and follow basic safety practices when meeting new people.

---

**Built with ❤️ for the safety of men in dating**