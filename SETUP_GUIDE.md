# NutriTrack - Complete Setup Guide

This guide will walk you through setting up the NutriTrack app from scratch.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (version 3.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Dart SDK** (version 2.17 or higher)
   - Comes bundled with Flutter

3. **IDE** (Choose one)
   - Android Studio (recommended)
   - Visual Studio Code with Flutter extension
   - IntelliJ IDEA

4. **Mobile Development Environment**
   - For Android: Android Studio and Android SDK
   - For iOS: Xcode (Mac only)

## Step 1: Project Setup

### Clone and Install Dependencies

```bash
# Clone the repository
git clone <your-repo-url>
cd Be-Light

# Get Flutter dependencies
flutter pub get

# Verify everything is working
flutter doctor
```

## Step 2: Gemini AI API Setup

### Get Your API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated API key

### Configure API Key

Open `lib/services/gemini_service.dart` and replace the placeholder:

```dart
class GeminiService {
  late GenerativeModel _model;
  late GenerativeModel _visionModel;

  // Replace with your actual API key
  static const String _apiKey = 'YOUR_ACTUAL_API_KEY_HERE';

  // ... rest of the code
}
```

**Important:** Never commit your API key to version control!

## Step 3: Generate Code

The app uses code generation for Hive database adapters. Generate them with:

```bash
# Generate Hive adapters
flutter pub run build_runner build

# If you need to rebuild and delete conflicting outputs
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate `.g.dart` files for all your models.

## Step 4: Platform-Specific Setup

### Android Setup

1. **Update `android/app/build.gradle`**

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

2. **Camera Permissions**

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

3. **Internet Permission** (already included)

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### iOS Setup

1. **Update `ios/Podfile`**

Uncomment this line:
```ruby
platform :ios, '12.0'
```

2. **Camera Permissions**

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture meal photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select meal images</string>
```

3. **Install Pods**

```bash
cd ios
pod install
cd ..
```

## Step 5: Test the App

### Run on Emulator/Simulator

```bash
# List available devices
flutter devices

# Run the app
flutter run

# Run in release mode
flutter run --release
```

### Run on Physical Device

1. **Android:**
   - Enable Developer Mode on your device
   - Enable USB Debugging
   - Connect via USB
   - Run `flutter run`

2. **iOS:**
   - Connect iPhone via USB
   - Trust the computer on your device
   - Run `flutter run`

## Step 6: AWS Setup (Optional - For Production)

### S3 Bucket Setup

1. Create an S3 bucket in AWS Console
2. Configure CORS policy:

```json
[
    {
        "AllowedHeaders": ["*"],
        "AllowedMethods": ["GET", "PUT", "POST"],
        "AllowedOrigins": ["*"],
        "ExposeHeaders": []
    }
]
```

### Lambda Function Setup

1. Create a Lambda function for image processing
2. Set up API Gateway
3. Configure IAM roles
4. Update the app with your Lambda endpoint

## Step 7: Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Test Features

1. **Onboarding Flow**
   - Complete user registration
   - Set goals and preferences

2. **Meal Logging**
   - Capture a meal photo
   - Verify AI analysis
   - Save meal

3. **Weight Tracking**
   - Add weight entry
   - View progress chart

4. **Journal**
   - Create journal entry
   - Test mood selection

5. **Achievements**
   - Complete tasks to unlock achievements
   - Verify streak tracking

## Troubleshooting

### Common Issues

#### 1. Build Runner Errors

```bash
# Clear cache and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 2. Gemini API Errors

- Verify API key is correct
- Check internet connection
- Ensure billing is enabled on Google Cloud (if required)
- Check API quota limits

#### 3. Camera Not Working

- Verify permissions are added
- Check physical device (emulator camera may not work properly)
- Restart the app after granting permissions

#### 4. Hive Database Errors

```bash
# Clear app data
flutter clean
# Uninstall app from device
# Reinstall
flutter run
```

#### 5. Dependencies Issues

```bash
# Update dependencies
flutter pub upgrade

# Remove lock file and reinstall
rm pubspec.lock
flutter pub get
```

## Performance Optimization

### Image Optimization

The app automatically compresses images before sending to Gemini API. Adjust quality in `gemini_service.dart`:

```dart
final compressedBytes = Uint8List.fromList(
  img.encodeJpg(resizedImage, quality: 85) // Adjust quality (0-100)
);
```

### Database Optimization

Hive is already optimized, but you can:
- Use lazy loading for large lists
- Implement pagination
- Compress data before storing

## Deployment

### Android (Google Play)

1. **Generate Signing Key**

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Configure Signing**

Create `android/key.properties`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

3. **Build Release APK**

```bash
flutter build apk --release
```

4. **Build App Bundle (AAB)**

```bash
flutter build appbundle --release
```

### iOS (App Store)

1. **Register App ID** in Apple Developer Portal
2. **Configure Signing** in Xcode
3. **Build Archive**

```bash
flutter build ios --release
```

4. Open in Xcode and archive
5. Upload to App Store Connect

## Environment Variables

For better security, use environment variables for API keys:

1. **Create `.env` file** (not committed to git)

```env
GEMINI_API_KEY=your_api_key_here
AWS_ACCESS_KEY=your_aws_key
AWS_SECRET_KEY=your_aws_secret
```

2. **Use flutter_dotenv package**

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

// Access variables
final apiKey = dotenv.env['GEMINI_API_KEY'];
```

## Monitoring & Analytics

### Firebase Setup (Recommended)

1. Create Firebase project
2. Add Android/iOS apps
3. Download config files
4. Add Firebase packages:

```yaml
dependencies:
  firebase_core: ^latest
  firebase_analytics: ^latest
  firebase_crashlytics: ^latest
```

### Crashlytics

Enable crash reporting to monitor app stability in production.

## Support

If you encounter issues:

1. Check the [README.md](README.md)
2. Search existing GitHub issues
3. Create a new issue with:
   - Flutter version (`flutter --version`)
   - Device/OS information
   - Error logs
   - Steps to reproduce

## Next Steps

1. Customize the app theme in `lib/utils/app_theme.dart`
2. Add your own branding and logo
3. Configure push notifications
4. Set up analytics
5. Implement in-app purchases
6. Submit to app stores

---

Happy coding! 🚀
