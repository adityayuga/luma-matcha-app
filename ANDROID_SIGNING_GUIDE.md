# Android Signing Setup Guide

## The Problem
Google Play Store rejected your app with: "You uploaded an APK or Android App Bundle that was signed in debug mode. You need to sign your APK or Android App Bundle in release mode."

## ✅ SOLUTION IMPLEMENTED

The build configuration has been updated to automatically use proper release signing when available.

## Quick Setup for Production Release

### Option 1: Automated Setup (Recommended)
```bash
make setup-android-signing
```

This will:
1. Create a release keystore (`android/app/upload-keystore.jks`)
2. Generate a basic `android/key.properties` file
3. Prompt you for keystore details

### Option 2: Manual Setup

1. **Create a release keystore:**
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload -storetype JKS
   ```

2. **Create `android/key.properties`:**
   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password  
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

3. **Build for release:**
   ```bash
   make build-appbundle
   ```

## How It Works

The updated `build.gradle.kts` now:
- ✅ Checks for `android/key.properties` file
- ✅ Uses custom keystore if available
- ✅ Falls back to Flutter's default release signing if no keystore
- ✅ Enables ProGuard for optimized builds
- ✅ Removes debug signing configuration

## Build Commands

| Command | Description | Signing |
|---------|-------------|---------|
| `make build-appbundle` | **Recommended for Play Store** | Release keystore or Flutter default |
| `make build-appbundle-simple` | Alternative method | Release signing |
| `make build-android-simple` | APK for testing | Release signing |

## Security Notes

⚠️ **IMPORTANT SECURITY:**
- **NEVER** commit `key.properties` to version control
- **NEVER** commit `*.jks` keystore files to version control
- Store keystore passwords securely
- Make backups of your keystore file

Add to `.gitignore`:
```
android/key.properties
android/app/*.jks
android/app/*.keystore
```

## Verification

After setup, verify your build is signed correctly:

```bash
# Build the app bundle
make build-appbundle

# Check the signing (optional)
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

## Troubleshooting

### "Keystore file not found"
- Ensure `android/key.properties` has correct `storeFile` path
- Verify keystore file exists at specified location

### "Wrong password"  
- Check passwords in `android/key.properties`
- Ensure no extra spaces or special characters

### "Build still uses debug signing"
- Clean build: `flutter clean`
- Rebuild: `make build-appbundle`
- Check that `key.properties` exists and has correct content

## File Structure
```
android/
├── key.properties          # Keystore configuration (DO NOT COMMIT)
└── app/
    ├── upload-keystore.jks # Release keystore (DO NOT COMMIT)
    ├── build.gradle.kts    # Updated with signing config
    └── proguard-rules.pro  # ProGuard configuration
```

## Next Steps
1. ✅ Run `make setup-android-signing`
2. ✅ Edit `android/key.properties` with your passwords
3. ✅ Run `make build-appbundle`
4. ✅ Upload the `.aab` file to Google Play Store
5. ✅ Your app will now be signed in release mode! 🎉
