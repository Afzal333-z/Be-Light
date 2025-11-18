# NutriTrack - AI-Powered Meal Tracking App

A comprehensive Flutter mobile application for tracking meals, managing weight, and achieving health goals with AI-powered nutrition analysis and gamification.

## Features

### Core Features

1. **AI-Powered Meal Analysis**
   - Capture meal photos with camera
   - Automatic food recognition using Gemini AI
   - Detailed nutrition breakdown (calories, macros, micros)
   - Smart recommendations and health scores

2. **Comprehensive Nutrition Tracking**
   - Daily calorie tracking with visual progress indicators
   - Macronutrient tracking (Protein, Carbs, Fats)
   - Micronutrient monitoring (Vitamins, Minerals)
   - Weekly and monthly nutrition analytics
   - Interactive charts and visualizations

3. **Weight Management**
   - Daily weight logging
   - Progress tracking with visual charts
   - BMI and BMR calculations
   - Goal-based calorie recommendations
   - Body composition tracking (body fat, muscle mass, water %)

4. **Journal & Mood Tracking**
   - Daily feelings and mood recording
   - Hunger and energy level tracking
   - Correlation between mood and eating patterns
   - AI-powered insights from journal entries

5. **Gamification & Rewards**
   - Daily login streak tracking
   - Achievement system with multiple categories
   - Points and rewards system
   - Milestone celebrations with confetti
   - Rarity-based achievements (Common, Rare, Epic, Legendary)

6. **Meal Suggestions**
   - AI-generated personalized meal plans
   - Based on dietary preferences and goals
   - Calorie and macro-optimized suggestions
   - Recipe recommendations

7. **Smart Features**
   - Daily motivational messages
   - Push notifications for meal reminders
   - Dark mode support
   - Smart watch integration (planned)
   - Health app integration (planned)

## Screenshots

*Coming soon - Add screenshots of your app here*

## Technology Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Local Database**: Hive
- **AI/ML**: Google Gemini AI API
- **Charts**: FL Chart, Syncfusion Charts
- **Animations**: Flutter Animate, Lottie
- **Camera**: Image Picker, Camera
- **Notifications**: Flutter Local Notifications

## Setup Instructions

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (2.17 or higher)
- Android Studio / Xcode (for mobile development)
- Google Gemini API Key

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd Be-Light
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Gemini API**
   - Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Open `lib/services/gemini_service.dart`
   - Replace `YOUR_GEMINI_API_KEY` with your actual API key:
   ```dart
   static const String _apiKey = 'YOUR_ACTUAL_API_KEY_HERE';
   ```

4. **Generate Hive Adapters**
   ```bash
   flutter pub run build_runner build
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### Gemini API Setup

1. Visit [Google AI Studio](https://makersuite.google.com/)
2. Create a new API key
3. Add the key to `lib/services/gemini_service.dart`

### AWS Lambda & S3 Setup (Optional for Enhanced Image Analysis)

1. Create an AWS account
2. Set up S3 bucket for image storage
3. Create Lambda function for image processing
4. Update `lib/services/gemini_service.dart` with AWS credentials

### Smart Watch Integration (Future)

The app includes placeholders for smart watch integration:
- Health data sync (steps, heart rate, calories burned)
- Apple Health / Google Fit integration
- Automatic activity tracking

## App Architecture

```
lib/
├── models/              # Data models (User, Meal, Weight, Journal, etc.)
├── screens/             # UI screens
├── widgets/             # Reusable widgets
├── services/            # Business logic (API, Database, Notifications)
├── providers/           # State management
├── utils/              # Utilities and themes
└── main.dart           # App entry point
```

## Revenue Model

### Freemium Model with Premium Subscription

#### Free Tier
- Daily meal logging (up to 3 meals/day)
- Basic nutrition tracking
- Weight tracking
- Achievements and streaks
- 5 AI meal analyses per week
- Basic charts and insights

#### Premium Tier ($9.99/month or $79.99/year)

**Premium Features:**
- ✨ Unlimited AI meal analysis
- 📊 Advanced nutrition insights and trends
- 🍽️ Personalized meal plans and recipes
- 📈 Detailed micronutrient tracking
- 💬 AI nutritionist chat (unlimited)
- 🎯 Custom goals and targets
- 📱 Smart watch integration
- 🔔 Advanced notification customization
- 👥 Family sharing (up to 5 members)
- 📥 Data export (CSV, PDF)
- 🎨 Premium themes and customization
- 🚫 Ad-free experience
- ⚡ Priority support

#### Additional Revenue Streams

1. **In-App Purchases**
   - One-time achievement packs
   - Custom theme packs
   - Meal plan bundles

2. **Affiliate Marketing**
   - Healthy food delivery partnerships
   - Fitness equipment recommendations
   - Supplement recommendations

3. **Data Insights (Anonymized)**
   - Aggregated nutrition trends
   - Health research partnerships (with user consent)

4. **Corporate Wellness**
   - B2B subscriptions for companies
   - Employee wellness programs
   - Bulk licensing

### Conversion Strategy

- **Free Trial**: 7-day premium trial for new users
- **Limited Free Features**: Encourage upgrade with feature limitations
- **Achievements**: Unlock premium trial through achievements
- **Referral Program**: Premium days for referrals
- **Seasonal Promotions**: Black Friday, New Year deals

### Projected Revenue

**Assumptions:**
- 10,000 monthly active users (Year 1)
- 5% conversion rate to premium
- Average subscription value: $8/user/month (considering annual)

**Monthly Revenue:**
- Premium subscriptions: 500 users × $8 = $4,000
- In-app purchases: ~$500
- **Total: ~$4,500/month or $54,000/year**

**Year 2 Projections (with growth):**
- 50,000 monthly active users
- 8% conversion rate
- Monthly revenue: ~$32,000 or $384,000/year

## Marketing Strategy

1. **App Store Optimization (ASO)**
   - Keywords: meal tracker, nutrition, weight loss, AI diet
   - Screenshots highlighting AI features
   - Video preview showing meal capture flow

2. **Content Marketing**
   - Health and nutrition blog
   - YouTube tutorials
   - Social media (Instagram, TikTok)
   - Success stories and transformations

3. **Partnerships**
   - Fitness influencers
   - Nutritionists and dietitians
   - Gym and fitness center partnerships

4. **User Acquisition**
   - Google Ads
   - Facebook/Instagram ads
   - App Store featured placement
   - Referral program

## Future Enhancements

- [ ] Apple Watch & WearOS integration
- [ ] Barcode scanner for packaged foods
- [ ] Social features (friends, challenges)
- [ ] Integration with fitness apps (Strava, MyFitnessPal)
- [ ] Voice-powered meal logging
- [ ] Restaurant menu analysis
- [ ] Grocery shopping lists
- [ ] Recipe creator and meal prep planner
- [ ] Integration with smart scales
- [ ] Telemedicine integration

## Privacy & Security

- All data stored locally using Hive (encrypted)
- GDPR and CCPA compliant
- Optional cloud backup with encryption
- No data sharing without explicit consent
- Secure API communications
- Regular security audits

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## License

Copyright © 2024. All rights reserved.

## Support

For support, email support@nutritrack.com or join our Discord community.

## Acknowledgments

- Google Gemini AI for image analysis
- Flutter team for the amazing framework
- Open-source community for various packages

---

Built with ❤️ using Flutter
