# Idle Blacksmith - Build & Release Guide

This document covers how to build and release Idle Blacksmith for all platforms.

## Prerequisites

### All Platforms
1. **Godot 4.5** with export templates installed
   - Open Godot Editor > Editor > Manage Export Templates > Download and Install

### Desktop (Windows/macOS/Linux)
- No additional requirements for basic builds

### macOS Specific
- **Xcode Command Line Tools**: `xcode-select --install`
- **Apple Developer Account** (for notarization): $99/year
- Your Team ID from Apple Developer portal

### iOS
- **macOS** (required - cannot build on other platforms)
- **Xcode** (latest version from Mac App Store)
- **Apple Developer Account**: $99/year
- **Provisioning profiles** created in Apple Developer portal

### Android
- **Android SDK** (via Android Studio or command line)
- **JDK 17+**
- **Debug keystore** (Godot generates automatically)
- **Release keystore** (you create for Play Store)

---

## Quick Start

### 1. Generate Icons (First Time Only)
```bash
./scripts/generate_icons.sh
```

### 2. Build All Platforms (Command Line)
```bash
# macOS
godot --headless --export-release "macOS" builds/macos/IdleBlacksmith.app

# Windows (cross-compile from any platform)
godot --headless --export-release "Windows Desktop" builds/windows/IdleBlacksmith.exe

# Linux
godot --headless --export-release "Linux" builds/linux/IdleBlacksmith.x86_64

# Android (requires SDK setup)
godot --headless --export-release "Android" builds/android/IdleBlacksmith.apk

# iOS (macOS only, requires Xcode)
godot --headless --export-release "iOS" builds/ios/IdleBlacksmith.ipa
```

### 3. Build via Godot Editor
1. Open project in Godot Editor
2. Go to **Project > Export**
3. Select platform preset
4. Click **Export Project** (release) or **Export PCK/ZIP** (for updates)

---

## Platform-Specific Instructions

## Steam (Desktop)

### Initial Setup

1. **Create Steamworks Account**
   - Go to https://partner.steamgames.com/
   - Pay $100 app credit fee
   - Complete required paperwork

2. **Create App**
   - In Steamworks, create new app
   - Note your App ID

3. **Install Steamworks SDK** (optional - for achievements/cloud saves)
   - Download from Steamworks
   - Install GodotSteam plugin if needed

### Build for Steam

1. Export your game:
   ```bash
   godot --headless --export-release "Windows Desktop" builds/steam/windows/IdleBlacksmith.exe
   godot --headless --export-release "macOS" builds/steam/macos/IdleBlacksmith.app
   godot --headless --export-release "Linux" builds/steam/linux/IdleBlacksmith.x86_64
   ```

2. Set up Steam depot configuration
3. Upload via SteamPipe (command line) or Steamworks website

### Steam Store Assets Needed
| Asset | Size | Format |
|-------|------|--------|
| Header Capsule | 460x215 | PNG/JPG |
| Small Capsule | 231x87 | PNG/JPG |
| Main Capsule | 616x353 | PNG/JPG |
| Hero Graphic | 3840x1240 | PNG/JPG |
| Logo | 1280x720 | PNG (transparent) |
| Screenshots | 1920x1080 (min 1280x720) | PNG/JPG |

---

## macOS

### Code Signing & Notarization

For distribution outside the App Store, Apple requires notarization.

1. **Get Developer ID Certificate**
   - Apple Developer Portal > Certificates > Developer ID Application

2. **Update export_presets.cfg**
   ```ini
   codesign/codesign=1
   codesign/apple_team_id="YOUR_TEAM_ID"
   codesign/identity="Developer ID Application: Your Name (TEAM_ID)"
   notarization/notarization=1
   notarization/apple_id_name="your@email.com"
   notarization/apple_id_password="app-specific-password"
   ```

3. **Create App-Specific Password**
   - Go to appleid.apple.com
   - Security > App-Specific Passwords > Generate

4. **Export with notarization**
   - Godot will automatically notarize during export

### Without Notarization
Users will see "unidentified developer" warning. They can bypass with:
- Right-click > Open (first launch only)

---

## iOS

### Provisioning Setup

1. **Create App ID**
   - Apple Developer Portal > Identifiers > App IDs
   - Bundle ID: `com.nepomuceno.idleblacksmith`

2. **Create Provisioning Profile**
   - For testing: Development profile
   - For App Store: Distribution profile

3. **Update export_presets.cfg**
   ```ini
   application/app_store_team_id="YOUR_TEAM_ID"
   application/provisioning_profile_uuid_debug="DEBUG_PROFILE_UUID"
   application/provisioning_profile_uuid_release="RELEASE_PROFILE_UUID"
   application/code_sign_identity_debug="iPhone Developer"
   application/code_sign_identity_release="iPhone Distribution"
   ```

### Build & Upload

1. **Export IPA**
   ```bash
   godot --headless --export-release "iOS" builds/ios/IdleBlacksmith.ipa
   ```

2. **Upload to App Store Connect**
   - Use Transporter app (Mac App Store)
   - Or use `xcrun altool`:
   ```bash
   xcrun altool --upload-app -f builds/ios/IdleBlacksmith.ipa \
     -u your@email.com -p app-specific-password
   ```

### App Store Connect Setup
1. Create app in App Store Connect
2. Fill in metadata, screenshots, privacy policy URL
3. Submit for review

### Required Screenshots
| Device | Size |
|--------|------|
| iPhone 6.7" | 1290x2796 |
| iPhone 6.5" | 1284x2778 |
| iPhone 5.5" | 1242x2208 |
| iPad Pro 12.9" | 2048x2732 |

---

## Android

### Keystore Setup

1. **Create Release Keystore** (once, keep forever!)
   ```bash
   keytool -genkey -v -keystore idleblacksmith-release.keystore \
     -alias idleblacksmith -keyalg RSA -keysize 2048 -validity 10000
   ```
   
   **IMPORTANT**: Back up this keystore! You cannot update your app without it.

2. **Configure Godot**
   - Editor > Editor Settings > Export > Android
   - Set Android SDK path
   - Set keystore path and credentials

### Build APK/AAB

```bash
# APK (for testing/sideloading)
godot --headless --export-release "Android" builds/android/IdleBlacksmith.apk

# AAB (required for Play Store)
# Change gradle_build/export_format=1 in export_presets.cfg first
godot --headless --export-release "Android" builds/android/IdleBlacksmith.aab
```

### Google Play Console Setup

1. **Create Developer Account**: $25 one-time
2. **Create App** in Play Console
3. **Complete Data Safety** questionnaire
4. **Upload AAB** to internal testing track first
5. **Progress through testing tracks**: Internal > Closed > Open > Production

### Required Assets
| Asset | Size |
|-------|------|
| App Icon | 512x512 PNG |
| Feature Graphic | 1024x500 PNG/JPG |
| Screenshots | Min 2, various sizes |
| Privacy Policy | URL required |

---

## Version Management

### Updating Version Numbers

Before each release, update versions in:

1. **export_presets.cfg** (all platforms)
   ```ini
   version/code=2          # Android: increment each release
   version/name="1.1.0"    # Semantic version
   application/short_version="1.1.0"  # iOS/macOS
   application/version="1.1.0"        # iOS/macOS
   ```

2. **Version numbering scheme**
   - Major.Minor.Patch (e.g., 1.2.3)
   - Android version_code must always increase

---

## Ads Integration (Future)

Ads are currently disabled. To enable:

1. **Install AdMob Plugin**
   - https://github.com/poing-studios/Godot-AdMob-Android-iOS

2. **Create AdMob Account**
   - Get App IDs for Android and iOS
   - Create ad unit IDs

3. **Update ad_manager.gd**
   ```gdscript
   const ENABLED: bool = true
   const AD_UNIT_INTERSTITIAL_ANDROID: String = "ca-app-pub-XXX/YYY"
   const AD_UNIT_INTERSTITIAL_IOS: String = "ca-app-pub-XXX/ZZZ"
   ```

4. **Configure in export settings**
   - Add AdMob App ID to Android/iOS export settings

---

## Checklist Before Release

### All Platforms
- [ ] Test gameplay thoroughly
- [ ] Verify save/load works correctly
- [ ] Check all UI elements display correctly
- [ ] Update version numbers
- [ ] Test on target devices/OS versions

### Steam
- [ ] Steam depot configured
- [ ] Store page complete (description, screenshots, tags)
- [ ] Build uploaded and tested

### iOS
- [ ] App icons at all required sizes
- [ ] Screenshots for all required device sizes
- [ ] Privacy policy URL hosted and accessible
- [ ] App Store Connect metadata complete
- [ ] TestFlight testing completed

### Android
- [ ] Release keystore backed up securely
- [ ] AAB built (not APK) for Play Store
- [ ] Data safety questionnaire completed
- [ ] Internal testing track verified
- [ ] Content rating questionnaire completed

---

## Troubleshooting

### macOS: "App is damaged and can't be opened"
```bash
xattr -cr /path/to/IdleBlacksmith.app
```

### iOS: Export fails with signing error
- Verify provisioning profile matches bundle ID
- Check certificate is not expired
- Ensure Xcode is up to date

### Android: APK won't install
- Enable "Install from unknown sources" for testing
- Check minimum SDK version compatibility

### All: Export template missing
- Editor > Manage Export Templates > Download and Install

---

## File Structure

```
builds/
├── windows/
│   └── IdleBlacksmith.exe
├── macos/
│   └── IdleBlacksmith.app
├── linux/
│   └── IdleBlacksmith.x86_64
├── android/
│   ├── IdleBlacksmith.apk
│   └── IdleBlacksmith.aab
└── ios/
    └── IdleBlacksmith.ipa

assets/icons/
├── AppIcon.ico          # Windows
├── AppIcon.icns         # macOS
├── android_*.png        # Android icons
└── ios_*.png            # iOS icons

docs/
└── privacy_policy.html  # Host this somewhere accessible
```
