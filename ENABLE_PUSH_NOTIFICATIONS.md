# Enable Push Notifications in Xcode

## The Problem
OneSignal shows: **"Missing Push Capability"**

This means your iOS app doesn't have Push Notifications enabled in Xcode.

---

## Solution (2 minutes)

### Step 1: Open Xcode Project
```bash
cd air_charters/ios
open Runner.xcworkspace
```

### Step 2: Enable Push Notifications

1. **Select "Runner" target** (blue icon at the top of file list)
2. Click **"Signing & Capabilities"** tab
3. Click **"+ Capability"** button (top left)
4. Search for and add **"Push Notifications"**
5. You should see a new section appear with:
   ```
   Push Notifications
   ✓ Enabled
   ```

### Step 3: Add Entitlements File (if not auto-added)

1. In the **"Signing & Capabilities"** tab
2. Under **"Background Modes"** (should already exist from Info.plist)
3. Make sure **"Remote notifications"** is checked ✅

### Step 4: Verify Entitlements File

1. In Xcode left sidebar, you should see **"Runner.entitlements"**
2. Open it and verify it contains:
   ```xml
   <key>aps-environment</key>
   <string>development</string>
   ```

### Step 5: Clean and Rebuild

```bash
# In air_charters directory
flutter clean
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

---

## Verify It Worked

After reinstalling the app:

1. **Check Flutter logs:**
   ```
   OneSignalService: Permission granted: true
   OneSignalService: Player ID: abc123-...
   OneSignalService: Device registered with backend
   ```

2. **Check OneSignal Dashboard:**
   - Status should change from "Never Subscribed" → **"Subscribed"**
   - "Missing Push Capability" → **Gone**

3. **Test notification:**
   - OneSignal Dashboard → Messages → New Push
   - Send to your device's Player ID
   - You should receive the notification! 🎉

---

## For Production (later)

When ready for App Store:

1. In Xcode → Signing & Capabilities
2. Change `aps-environment` from `development` to `production`
3. Or let Xcode manage it automatically based on build configuration

---

## Troubleshooting

### "No provisioning profiles found"
- Make sure you're signed in to your Apple Developer account in Xcode
- Xcode → Preferences → Accounts → Add your Apple ID

### "Automatic signing failed"
- Switch to **"Automatically manage signing"** in Signing & Capabilities
- Select your Team from dropdown

### Still "Missing Push Capability" after rebuild
- Delete app from device
- Clean derived data: Xcode → Product → Clean Build Folder (Cmd+Shift+K)
- Rebuild and reinstall

---

**✅ After this, push notifications will work!**

