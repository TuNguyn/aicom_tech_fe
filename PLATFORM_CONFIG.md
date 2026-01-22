# Platform Configuration Guide

## Bundle Identifiers
- **Android**: com.nailtech.aicom
- **iOS**: com.nailtech.aicom
- **Display Name**: Aicom Tech

## Platform Versions

### Android
- Min SDK: 21 (Android 5.0 Lollipop)
- Target SDK: 34 (Android 14)
- Compile SDK: 34
- Java Version: 11

### iOS
- Minimum iOS: 14.0
- Swift Version: 5.0
- Xcode: 14.0+

## Network Security

### Development Environment
HTTP connections allowed to:
- 172.232.3.34 (dev server)
- localhost
- 10.0.2.2 (Android emulator)

Configured in:
- Android: `android/app/src/main/res/xml/network_security_config.xml`
- iOS: `ios/Runner/Info.plist` (NSExceptionDomains)

### Staging & Production
HTTPS enforced automatically:
- Staging: https://staging-api.nailtech.com
- Production: https://api.nailtech.com

Set environment in `lib/main.dart` before building.

## Release Build Setup

### Android
Currently using debug signing. To setup release signing:

1. Generate keystore:
```bash
keytool -genkey -v -keystore release.keystore -alias release -keyalg RSA -keysize 2048 -validity 10000
```

2. Create `android/key.properties`:
```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=release
storeFile=../release.keystore
```

3. Update `android/app/build.gradle.kts` to load signing config

4. Build release:
```bash
flutter build apk --release
flutter build appbundle --release
```

**Important**: Backup keystore file securely. Cannot update app without it.

### iOS
Configure in Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select Runner target → Signing & Capabilities
3. Set Team and enable "Automatically manage signing"
4. Build via Xcode or `flutter build ios --release`

## Build Commands

### Debug Builds
```bash
# Clean build
flutter clean
flutter pub get

# Android
flutter run  # or flutter build apk --debug

# iOS
flutter run  # or flutter build ios --debug --no-codesign
```

### Release Builds
```bash
# Android (will use debug signing until keystore configured)
flutter build apk --release
flutter build appbundle --release

# iOS (requires proper signing in Xcode)
flutter build ios --release
```

## Environment Configuration

Edit `lib/main.dart` to change environment:
```dart
AppConfig.init(env: Environment.dev);      // Development
AppConfig.init(env: Environment.staging);  // Staging
AppConfig.init(env: Environment.production); // Production
```

Current endpoints in `lib/config/app_config.dart`:
- Dev: http://172.232.3.34:3002
- Staging: https://staging-api.nailtech.com/api
- Production: https://api.nailtech.com/api

## Key Dependencies

### Cross-Platform Compatible
All dependencies support both Android and iOS:
- socket_io_client ^2.0.3+1 (real-time communication)
- dio ^5.8.0 (HTTP client)
- hive_flutter ^1.1.0 (local storage)
- sqflite ^2.4.2 (local database)
- go_router ^16.0.0 (navigation)
- flutter_riverpod ^2.6.1 (state management)

Platform-specific implementations are handled automatically by Flutter plugins.

## Important Notes

### Application ID Change
If app was previously published with `com.example.aicom_tech_fe`, changing to `com.nailtech.aicom` will be treated as a NEW app by stores. Existing users cannot update - they must reinstall.

### iOS 14.0 Minimum
Devices running iOS 13 (iPhone 6 and older) cannot install the app. iOS 14+ covers 99%+ of active devices.

### Security
- Never commit `android/key.properties` or `.jks`/`.keystore` files to git
- Backup Android keystore securely - cannot publish updates without it
- Use HTTPS for all production APIs
