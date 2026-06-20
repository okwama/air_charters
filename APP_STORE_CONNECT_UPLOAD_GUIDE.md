# AirCharters - App Store Connect Upload Guide

## 📱 App Information

### Basic App Details
- **App Name**: Air Charterss
- **Subtitle**: Charter Beyond Borders
- **Bundle ID**: `com.cit.air_charters`
- **Version**: 1.0.0 (Build 2)
- **Category**: Travel
- **Secondary Category**: Business
- **Content Rating**: 4+ (No Objectionable Content)
- **Age Rating**: 4+

### App Description

**Short Description (30 characters)**
Book Private Jet Charters

**Full Description (4000 characters)**
Experience luxury air travel like never before with Air Charterss - your premier platform for private jet charter bookings worldwide.

**Key Features:**
✈️ **Global Charter Network**: Access to thousands of private jets and aircraft worldwide
🌍 **Worldwide Coverage**: Book charters to any destination across the globe
🏥 **Medical Evacuations**: Specialized medical transport services
📦 **Cargo Solutions**: Dedicated cargo and freight charter services
💰 **Transparent Pricing**: Real-time quotes with no hidden fees
🔒 **Secure Payments**: Multiple payment options including Paystack integration
📱 **Real-time Tracking**: Track your flight status and updates
🎯 **Personalized Service**: Tailored recommendations based on your preferences
📋 **Document Management**: Easy upload and management of travel documents
🔔 **Smart Notifications**: Stay informed with push notifications

**Perfect for:**
• Business executives and corporate travel
• Luxury leisure travelers
• Medical emergency transport
• Cargo and freight needs
• Special events and occasions
• VIP transportation requirements

**Why Choose AirCharters?**
- 24/7 customer support
- Instant booking confirmation
- Competitive pricing
- Premium aircraft selection
- Global airport network
- Professional crew and service

Download Air Charterss today and experience the ultimate in private aviation services.

### Keywords
private jet, charter flights, luxury travel, aviation, air transport, cargo charter, medical evacuation, business aviation, private aircraft, jet booking, air charter, premium travel, executive transport, private plane, charter service

### Promotional Text
Discover the world of private aviation with Air Charterss. Book luxury private jet charters, medical evacuations, and cargo transport services worldwide. Experience premium air travel with transparent pricing and 24/7 support.

---

## 🔧 Technical Configuration

### Build Settings
- **Platform**: iOS
- **Minimum iOS Version**: 12.0
- **Target iOS Version**: 17.0+
- **Architecture**: ARM64
- **Flutter Version**: 3.6.1+
- **Dart SDK**: ^3.6.1

### App Capabilities
- **Background Modes**: Remote notifications
- **App Transport Security**: Enabled with HTTPS only
- **Biometric Authentication**: Face ID/Touch ID support
- **Location Services**: Required for airport services
- **Camera Access**: Document scanning
- **Push Notifications**: OneSignal integration

### Bundle Configuration
```xml
Bundle Identifier: com.cit.air_charters
Display Name: Air Charters
Version: 1.0.0
Build Number: 2
```

---

## 📋 Required Assets

### App Icon
- **Size**: 1024x1024 pixels
- **Format**: PNG (no transparency)
- **Location**: `assets/logo/logo.png`
- **Requirements**: High-resolution, no rounded corners

### Screenshots Required
**iPhone Screenshots (Required)**
- iPhone 6.7" (iPhone 15 Pro Max): 1290x2796 pixels
- iPhone 6.5" (iPhone 14 Plus): 1284x2778 pixels
- iPhone 5.5" (iPhone 8 Plus): 1242x2208 pixels

**iPad Screenshots (If iPad Support)**
- iPad Pro 12.9" (6th generation): 2048x2732 pixels
- iPad Pro 11" (4th generation): 1668x2388 pixels

### App Preview Videos (Optional but Recommended)
- **Duration**: 15-30 seconds
- **Format**: MP4 or MOV
- **Resolution**: Match device screenshots
- **Content**: Show key app features and user flow

---

## 🔒 Privacy & Permissions

### Required Permissions
1. **Location (When In Use)**
   - Purpose: Show nearby airports and calculate flight distances
   - Usage: Airport services and route recommendations

2. **Camera**
   - Purpose: Scan documents and capture photos for verification
   - Usage: Document upload and trip verification

3. **Photo Library**
   - Purpose: Upload documents and images for bookings
   - Usage: Travel document management

4. **Microphone**
   - Purpose: Video calls with charter operators
   - Usage: Customer support and operator communication

5. **Contacts**
   - Purpose: Share trip details with companions
   - Usage: Social features and trip sharing

6. **Face ID/Touch ID**
   - Purpose: Secure authentication
   - Usage: Biometric login and security

7. **Push Notifications**
   - Purpose: Flight updates and booking confirmations
   - Usage: Real-time notifications

### Privacy Policy
- **URL**: Available in app assets (`assets/legal/privacy_policy.pdf`)
- **Content**: Comprehensive privacy policy covering all data collection
- **GDPR Compliance**: European data protection compliance
- **CCPA Compliance**: California privacy compliance

---

## 💳 App Store Information

### Pricing & Availability
- **Price**: Free (with in-app purchases)
- **Availability**: Worldwide
- **Release Date**: TBD
- **In-App Purchases**: Charter booking fees, premium services

### App Store Optimization
- **Primary Category**: Travel
- **Secondary Category**: Business
- **Keywords**: private jet, charter flights, luxury travel, aviation
- **Localization**: English (Primary)

### Support Information
- **Support URL**: https://aircharters.com/support
- **Marketing URL**: https://aircharters.com
- **Privacy Policy URL**: Available in app
- **Terms of Service**: Available in app

---

## 🧪 Testing Information

### TestFlight Configuration
- **Internal Testing**: Available for team members
- **External Testing**: Available for beta testers
- **Test Groups**: 
  - Internal Team (5 testers)
  - Beta Testers (100 testers)
  - Charter Operators (50 testers)

### Test Credentials
- **Test Environment**: Production backend configured
- **Payment Testing**: Live Paystack integration
- **Authentication**: Firebase + JWT system
- **Test Data**: Sample aircraft and routes available

### Critical Test Scenarios
1. **User Registration**: Email/password → Firebase → Backend
2. **Aircraft Search**: Location-based aircraft availability
3. **Booking Process**: Search → Select → Payment → Confirmation
4. **Payment Flow**: Paystack integration and verification
5. **Document Upload**: Camera and file management
6. **Push Notifications**: Real-time updates
7. **Biometric Login**: Face ID/Touch ID authentication

---

## 🔧 Build Configuration

### Xcode Project Settings
- **Deployment Target**: iOS 12.0
- **Swift Version**: 5.0
- **Bitcode**: Enabled
- **App Transport Security**: Enabled
- **Background Modes**: Remote notifications

### Code Signing
- **Distribution Certificate**: Required
- **Provisioning Profile**: App Store distribution
- **Entitlements**: Push notifications, location services
- **Capabilities**: Background app refresh, push notifications

### Build Commands
```bash
# Clean and build
flutter clean
flutter pub get

# iOS Release Build
flutter build ios --release

# Archive for App Store
# Use Xcode to create archive
```

---

## 📊 Analytics & Monitoring

### Analytics Configuration
- **Firebase Analytics**: User behavior tracking
- **Crashlytics**: Crash reporting
- **OneSignal**: Push notification analytics
- **Custom Events**: Booking flow tracking

### Key Metrics to Track
- **User Registration**: Conversion rates
- **Booking Completion**: Success rates
- **Payment Processing**: Transaction success
- **App Performance**: Load times and crashes
- **User Engagement**: Session duration and frequency

---

## 🚀 Upload Checklist

### Pre-Upload Requirements
- [ ] **App Icon**: 1024x1024 PNG ready
- [ ] **Screenshots**: All required sizes captured
- [ ] **App Preview**: Video created (optional)
- [ ] **Privacy Policy**: URL or document ready
- [ ] **Terms of Service**: Available
- [ ] **Support Information**: Contact details ready

### Build Requirements
- [ ] **Release Build**: iOS archive created
- [ ] **Code Signing**: Distribution certificate configured
- [ ] **Provisioning Profile**: App Store distribution profile
- [ ] **Entitlements**: All capabilities configured
- [ ] **App Transport Security**: HTTPS only enabled

### App Store Connect Setup
- [ ] **App Information**: All details filled
- [ ] **Pricing**: Free with in-app purchases
- [ ] **Availability**: Worldwide release
- [ ] **Age Rating**: 4+ confirmed
- [ ] **Content Rights**: All content owned or licensed

### Testing Requirements
- [ ] **TestFlight**: Beta version uploaded
- [ ] **Internal Testing**: Team access configured
- [ ] **External Testing**: Beta testers invited
- [ ] **Crash Testing**: All features tested
- [ ] **Performance**: App performance verified

---

## 📞 Support & Contact

### Developer Information
- **Developer Name**: CIT Logistics
- **Support Email**: support@aircharters.com
- **Website**: https://aircharters.com
- **Privacy Policy**: Available in app
- **Terms of Service**: Available in app

### App Store Connect
- **App ID**: TBD (will be assigned)
- **Bundle ID**: com.cit.air_charters
- **Version**: 1.0.0
- **Build**: 2

---

## 🔄 Post-Upload Process

### Review Timeline
- **Initial Review**: 24-48 hours
- **Rejection Handling**: Address feedback promptly
- **Approval**: Ready for release
- **Release**: Manual or automatic

### Launch Strategy
- **Soft Launch**: Test in select markets
- **Full Launch**: Worldwide release
- **Marketing**: Coordinate with launch
- **Monitoring**: Track performance and feedback

---

## 📝 Notes

- All required assets are available in the project
- Backend is production-ready
- Payment integration is live
- Push notifications are configured
- All permissions are justified and documented
- Privacy policy and terms are included
- App follows iOS Human Interface Guidelines
- Ready for App Store submission

---

*This guide contains all the information needed for successful App Store Connect upload and review process.*
