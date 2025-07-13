# Build Configuration Guide

## Android Release Build

### APK for Testing/Distribution
```bash
make build-android
```
- **Output**: `build/app/outputs/flutter-apk/app-release.apk`
- **Size**: ~30MB
- **Use**: Direct installation, testing, or distribution outside Play Store

### App Bundle for Play Store
```bash
make build-appbundle
```
- **Output**: `build/app/outputs/bundle/release/app-release.aab`
- **Size**: ~32MB
- **Use**: Upload to Google Play Store (recommended)

### Install APK on Device
```bash
make install-android
```
- Installs the built APK on connected Android device

## iOS Release Build (macOS only)

### Build for iOS
```bash
make build-ios
```
- **Output**: `build/ios/iphoneos/Runner.app`
- **Note**: Requires Xcode for signing and App Store submission

### Build for iOS Simulator
```bash
flutter build ios --simulator
```

## Web Release Build

### Build for Web
```bash
make build
```
- **Output**: `build/web/`
- **Size**: ~33MB
- **Use**: Deploy to web server

### Deploy to VPS
```bash
make deploy
```
- Builds and deploys to your VPS at lumamatcha.com

## Build All Platforms

### Build Everything
```bash
make build-all
```
- Builds web, Android APK, Android App Bundle
- Builds iOS (if on macOS)

## App Sizes

### Check Current Build Sizes
```bash
make check-size
```

### Optimize Build Size
1. **Enable tree-shaking** (automatically enabled)
2. **Remove unused assets** from `assets/` folder
3. **Use vector graphics** instead of large images
4. **Compress images** before adding to assets

## Keystore Configuration

Your Android keystore is configured in:
- `android/key.properties`
- `android/app/build.gradle`

### Create New Keystore (if needed)
```bash
keytool -genkey -v -keystore ~/luma-matcha-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias luma-matcha
```

## Build Troubleshooting

### Clean Build
```bash
make clean
flutter clean
flutter pub get
```

### Update Dependencies
```bash
make update-deps
```

### Check Dependencies
```bash
make check-deps
```

### Flutter Doctor
```bash
flutter doctor
```

## Release Checklist

### Before Release
- [ ] Update version in `pubspec.yaml`
- [ ] Test on real devices
- [ ] Run `flutter analyze`
- [ ] Run `flutter test`
- [ ] Check app sizes
- [ ] Test all features

### Android Release
- [ ] Build and test APK
- [ ] Build App Bundle for Play Store
- [ ] Test installation on different devices
- [ ] Upload to Google Play Console

### iOS Release (macOS only)
- [ ] Build in Xcode
- [ ] Archive for App Store
- [ ] Upload to App Store Connect
- [ ] Submit for review

### Web Release
- [ ] Build web version
- [ ] Test on different browsers
- [ ] Deploy to VPS
- [ ] Enable HTTPS
- [ ] Test all links and features
