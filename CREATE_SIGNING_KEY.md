# How to Create Google Play Signing Key for AirCharters

## Step 1: Generate Upload Keystore

Run this command in your terminal from the `android/app/` directory:

```bash
cd "/Users/citlogistics/Desktop/Flutter Projects/Members/sp/air_charters/android/app"
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

When prompted, enter:
- **Keystore password**: Choose a strong password (minimum 6 characters)
- **Key password**: Use the same password or a different one
- **Your name**: Your name or company name
- **Organizational unit**: Your department or team
- **Organization**: Your company name
- **City**: Your city
- **State**: Your state/province
- **Country code**: Your 2-letter country code (e.g., US, CA, GB)

## Step 2: Update key.properties

Edit the `android/key.properties` file and replace:
- `your_keystore_password_here` with your actual keystore password
- `your_key_password_here` with your actual key password

## Step 3: Update build.gradle

The build.gradle is already configured to use the key.properties file. The release signing configuration will automatically use:
- `storeFile`: `upload-keystore.jks`
- `keyAlias`: `upload`
- Passwords from `key.properties`

## Step 4: Test the Build

Build a release APK to test the signing:

```bash
flutter build apk --release
```

## Step 5: Google Play App Signing Setup

1. **Go to Google Play Console**
2. **Navigate to your app** (or create a new app)
3. **Go to Release > Setup > App signing**
4. **Choose "Use Google Play App Signing"**
5. **Upload your upload-keystore.jks** when prompted
6. **Google will generate the app signing key** for you

## Security Notes

- **Keep your upload keystore secure** - Store it in a safe location
- **Backup your keystore** - If you lose it, you'll need to create a new app
- **Never commit keystore to version control** - Add `*.jks` and `key.properties` to `.gitignore`

## Files Created

- `android/app/upload-keystore.jks` - Your upload keystore
- `android/key.properties` - Keystore configuration
- This guide for reference

## Next Steps

After creating the keystore:
1. Update the passwords in `key.properties`
2. Test the release build
3. Upload to Google Play Console
4. Configure Google Play App Signing
