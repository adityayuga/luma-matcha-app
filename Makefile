# Luma Matcha Flutter Web App Makefile
# Author: Aditya Yuga
# Description: Automates building and deployment of Flutter web app

# Configuration
VPS_IP = 54.169.51.229
VPS_USER = ubuntu
DOMAIN_NAME = lumamatcha.com
PROJECT_NAME = luma-matcha
BUILD_DIR = build/web
ARCHIVE_NAME = luma-matcha-web.tar.gz

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help build clean deploy deploy-ip setup-vps check-deps test analyze build-android build-ios build-all build-appbundle build-appbundle-debug build-appbundle-simple build-android-simple build-appbundle check-android fix-android fix-java setup-android-signing configure-android-signing

# Default target
help:
	@echo "$(GREEN)Luma Matcha Flutter Web Deployment$(NC)"
	@echo ""
	@echo "$(YELLOW)Available commands:$(NC)"
	@echo "  make run-web      - Run Flutter web app for testing in localhost:8080"
	@echo "  make build        - Build Flutter web app for production"
	@echo "  make build-android - Build Android APK for release"
	@echo "  make build-ios    - Build iOS app for release"
	@echo "  make build-all    - Build web, Android, and iOS"
	@echo "  make build-appbundle - Build Android App Bundle (for Play Store)"
	@echo "  make build-appbundle-simple - Build AAB (bypasses Gradle issues)"
	@echo "  make build-android-simple - Build APK (simple method)"
	@echo "  make build-appbundle - Build AAB (direct Gradle - RECOMMENDED)"
	@echo "  make deploy       - Deploy to VPS with domain ($(DOMAIN_NAME))"
	@echo "  make deploy-ip    - Deploy to VPS with IP access only"
	@echo "  make setup-vps    - Setup VPS environment (run once)"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make test         - Run Flutter tests"
	@echo "  make analyze      - Analyze Flutter code"
	@echo "  make check-deps   - Check Flutter dependencies"
	@echo "  make fix-android  - Fix common Android build issues"
	@echo "  make fix-java     - Check and fix Java environment issues"
	@echo "  make setup-android-signing - Create release keystore"
	@echo "  make configure-android-signing - Configure build.gradle.kts"
	@echo "  make all          - Build, test, and deploy"
	@echo ""
	@echo "$(YELLOW)Mobile Development:$(NC)"
	@echo "  make run-android  - Run on Android device/emulator"
	@echo "  make run-ios      - Run on iOS device/simulator"
	@echo "  make devices      - Show available devices"
	@echo "  make check-size   - Check app sizes"
	@echo ""
	@echo "$(YELLOW)Help Commands:$(NC)"
	@echo "  make help-build   - Show build commands"
	@echo "  make help-mobile  - Show mobile development commands"
	@echo "  make help-deploy  - Show deployment commands"
	@echo ""
	@echo "$(YELLOW)Configuration:$(NC)"
	@echo "  VPS_IP: $(VPS_IP)"
	@echo "  VPS_USER: $(VPS_USER)"
	@echo "  DOMAIN: $(DOMAIN_NAME)"

# Check if required tools are installed
check-deps:
	@echo "$(YELLOW)Checking dependencies...$(NC)"
	@which flutter > /dev/null || (echo "$(RED)Error: Flutter not found$(NC)" && exit 1)
	@which ssh > /dev/null || (echo "$(RED)Error: SSH not found$(NC)" && exit 1)
	@which scp > /dev/null || (echo "$(RED)Error: SCP not found$(NC)" && exit 1)
	@echo "$(GREEN)✅ All dependencies found$(NC)"
	@echo "$(YELLOW)Flutter version:$(NC)"
	@flutter --version | head -1

# Fix Android build issues
fix-android:
	@echo "$(YELLOW)Fixing common Android build issues...$(NC)"
	@echo "$(YELLOW)1. Cleaning all build artifacts...$(NC)"
	@flutter clean
	@rm -rf android/.gradle
	@rm -rf android/app/build
	@rm -rf android/build
	@rm -rf ~/.gradle/caches
	@echo "$(YELLOW)2. Refreshing dependencies...$(NC)"
	@flutter pub get
	@echo "$(YELLOW)3. Accepting Android licenses...$(NC)"
	@flutter doctor --android-licenses || echo "$(YELLOW)License acceptance completed$(NC)"
	@echo "$(YELLOW)4. Checking Gradle wrapper...$(NC)"
	@cd android && chmod +x gradlew
	@echo "$(YELLOW)5. Setting JAVA_HOME to system Java...$(NC)"
	@echo "$(GREEN)Current JAVA_HOME: $${JAVA_HOME}$(NC)"
	@echo "$(GREEN)System Java: $$(which java)$(NC)"
	@echo "$(GREEN)✅ Android environment fixed$(NC)"
	@echo "$(YELLOW)Now try: make build-appbundle$(NC)"

# Fix Java environment specifically for Android builds
fix-java:
	@echo "$(YELLOW)Fixing Java environment for Android builds...$(NC)"
	@echo "$(YELLOW)Current Java versions:$(NC)"
	@java -version || echo "$(RED)Java not found$(NC)"
	@echo "$(YELLOW)Available Java installations:$(NC)"
	@/usr/libexec/java_home -V 2>/dev/null || echo "$(YELLOW)No Java installations found via java_home$(NC)"
	@echo "$(YELLOW)Android Studio Java:$(NC)"
	@ls -la "/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/java" 2>/dev/null || echo "$(YELLOW)Android Studio Java not found$(NC)"
	@echo "$(GREEN)✅ Java environment check completed$(NC)"

# Setup Android release signing (creates keystore for production)
setup-android-signing:
	@echo "$(YELLOW)Setting up Android release signing...$(NC)"
	@if [ -f "android/app/upload-keystore.jks" ]; then \
		echo "$(GREEN)✅ Keystore already exists: android/app/upload-keystore.jks$(NC)"; \
		echo "$(YELLOW)To recreate keystore, delete the existing file first$(NC)"; \
	else \
		echo "$(YELLOW)Creating release keystore...$(NC)"; \
		echo "$(YELLOW)You'll be prompted for keystore and key information$(NC)"; \
		keytool -genkey -v -keystore android/app/upload-keystore.jks \
			-keyalg RSA -keysize 2048 -validity 10000 \
			-alias upload -storetype JKS; \
		echo "$(GREEN)✅ Keystore created: android/app/upload-keystore.jks$(NC)"; \
		echo "$(YELLOW)Now configuring key.properties...$(NC)"; \
		echo "storePassword=" > android/key.properties; \
		echo "keyPassword=" >> android/key.properties; \
		echo "keyAlias=upload" >> android/key.properties; \
		echo "storeFile=upload-keystore.jks" >> android/key.properties; \
		echo "$(RED)⚠️  IMPORTANT: Edit android/key.properties and add your passwords$(NC)"; \
		echo "$(RED)⚠️  NEVER commit key.properties or keystore to version control$(NC)"; \
		echo "$(YELLOW)Example key.properties content:$(NC)"; \
		echo "  storePassword=your_store_password"; \
		echo "  keyPassword=your_key_password"; \
		echo "  keyAlias=upload"; \
		echo "  storeFile=upload-keystore.jks"; \
	fi

# Configure Android signing in build.gradle.kts
configure-android-signing:
	@echo "$(YELLOW)Configuring Android signing in build.gradle.kts...$(NC)"
	@if grep -q "signingConfigs" android/app/build.gradle.kts; then \
		echo "$(GREEN)✅ Signing configuration already present$(NC)"; \
	else \
		echo "$(YELLOW)Adding signing configuration...$(NC)"; \
		cp android/app/build.gradle.kts android/app/build.gradle.kts.backup; \
		echo "$(GREEN)✅ Backup created: android/app/build.gradle.kts.backup$(NC)"; \
		echo "$(RED)⚠️  Manual configuration required - see ANDROID_SIGNING_GUIDE.md$(NC)"; \
	fi

# Check Android environment
check-android:
	@echo "$(YELLOW)Checking Android environment...$(NC)"
	@flutter doctor --android-licenses 2>/dev/null || echo "$(YELLOW)Note: Run 'flutter doctor --android-licenses' if needed$(NC)"
	@flutter doctor | grep -E "(Android|Chrome)" || echo "$(YELLOW)Android toolchain check...$(NC)"

# Clean build artifacts
clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@flutter clean
	@rm -f $(ARCHIVE_NAME)
	@rm -f nginx-config
	@rm -rf build/
	@echo "$(GREEN)✅ Clean completed$(NC)"

# Analyze Flutter code
analyze:
	@echo "$(YELLOW)Analyzing Flutter code...$(NC)"
	@flutter analyze
	@echo "$(GREEN)✅ Analysis completed$(NC)"

# Run Flutter tests
test:
	@echo "$(YELLOW)Running Flutter tests...$(NC)"
	@flutter test
	@echo "$(GREEN)✅ Tests completed$(NC)"

# Run Flutter web
run-web:
	@echo "$(YELLOW)Running Flutter web app...$(NC)"
	@flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080

# Build Flutter web app
build: check-deps
	@echo "$(YELLOW)Building Flutter web app...$(NC)"
	@flutter pub get
	@flutter build web --release
	@echo "$(GREEN)✅ Web build completed$(NC)"

# Build Android APK
build-android: check-deps check-android
	@echo "$(YELLOW)Building Android APK...$(NC)"
	@echo "$(YELLOW)Cleaning previous builds...$(NC)"
	@flutter clean
	@flutter pub get
	@echo "$(YELLOW)Starting Android APK build...$(NC)"
	@cd android && \
	JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home \
	./gradlew clean
	@JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home \
	flutter build apk --release
	@echo "$(GREEN)✅ Android APK build completed$(NC)"
	@if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then \
		echo "$(GREEN)APK location: build/app/outputs/flutter-apk/app-release.apk$(NC)"; \
		ls -lh build/app/outputs/flutter-apk/app-release.apk; \
	else \
		echo "$(RED)❌ APK file not found$(NC)"; \
		exit 1; \
	fi

# Build Android App Bundle - Simple Method (bypasses Gradle issues)
build-appbundle-simple:
	@echo "$(YELLOW)Building Android App Bundle (Simple Method)...$(NC)"
	@echo "$(YELLOW)This bypasses Gradle Worker Daemon issues$(NC)"
	@flutter clean
	@flutter pub get
	@echo "$(YELLOW)Building directly with Flutter...$(NC)"
	@export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home && \
	flutter build appbundle --release --no-tree-shake-icons
	@if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then \
		echo "$(GREEN)✅ Android App Bundle built successfully!$(NC)"; \
		echo "$(GREEN)Location: build/app/outputs/bundle/release/app-release.aab$(NC)"; \
		ls -lh build/app/outputs/bundle/release/app-release.aab; \
		echo "$(GREEN)🎉 Ready for Google Play Store upload!$(NC)"; \
	else \
		echo "$(RED)❌ Build failed - AAB file not found$(NC)"; \
	fi

# Build Android APK - Simple Method 
build-android-simple:
	@echo "$(YELLOW)Building Android APK (Simple Method)...$(NC)"
	@flutter clean
	@flutter pub get
	@echo "$(YELLOW)Building directly with Flutter...$(NC)"
	@export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home && \
	flutter build apk --release --no-tree-shake-icons
	@if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then \
		echo "$(GREEN)✅ Android APK built successfully!$(NC)"; \
		echo "$(GREEN)Location: build/app/outputs/flutter-apk/app-release.apk$(NC)"; \
		ls -lh build/app/outputs/flutter-apk/app-release.apk; \
		echo "$(GREEN)🎉 Ready for installation!$(NC)"; \
	else \
		echo "$(RED)❌ Build failed - APK file not found$(NC)"; \
	fi

# Build Android App Bundle - Direct Gradle Method (WORKING SOLUTION)
build-appbundle:
	@echo "$(GREEN)Building Android App Bundle using direct Gradle with Java 17...$(NC)"
	@export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home; \
	echo "$(YELLOW)Using Java: $$JAVA_HOME$(NC)"; \
	echo "$(YELLOW)Stopping existing Gradle daemons...$(NC)"; \
	./android/gradlew --stop; \
	echo "$(YELLOW)Building with Gradle...$(NC)"; \
	cd android && ./gradlew bundleRelease; \
	echo "$(GREEN)✅ Android App Bundle created successfully!$(NC)"
	@if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then \
		echo "$(GREEN)Location: build/app/outputs/bundle/release/app-release.aab$(NC)"; \
		ls -lh build/app/outputs/bundle/release/app-release.aab; \
		echo "$(GREEN)🎉 Ready for Google Play Store upload!$(NC)"; \
	else \
		echo "$(RED)❌ Build output not found at expected location$(NC)"; \
		find . -name "*.aab" -type f 2>/dev/null | head -3; \
	fi

# Build Android App Bundle with verbose output for debugging
build-appbundle-debug: check-deps check-android
	@echo "$(YELLOW)Building Android App Bundle with debug output...$(NC)"
	@flutter clean
	@flutter pub get
	@echo "$(YELLOW)Java Environment:$(NC)"
	@echo "JAVA_HOME: /Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home"
	@cd android && \
	JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home \
	./gradlew clean --info
	@JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home \
	flutter build appbundle --release --verbose
	@if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then \
		echo "$(GREEN)✅ AAB built successfully$(NC)"; \
		ls -lh build/app/outputs/bundle/release/app-release.aab; \
	else \
		echo "$(RED)❌ Build failed$(NC)"; \
	fi

# Build iOS app
build-ios: check-deps
	@echo "$(YELLOW)Building iOS app...$(NC)"
	@if [ "$$(uname)" != "Darwin" ]; then \
		echo "$(RED)❌ iOS builds are only supported on macOS$(NC)"; \
		exit 1; \
	fi
	@flutter pub get
	@flutter build ios --release --no-codesign
	@echo "$(GREEN)✅ iOS build completed$(NC)"
	@echo "$(GREEN)iOS app location: build/ios/iphoneos/Runner.app$(NC)"
	@echo "$(YELLOW)Note: Use Xcode to sign and archive for App Store submission$(NC)"

# Build all platforms
build-all: build build-android build-appbundle
	@if [ "$$(uname)" = "Darwin" ]; then \
		$(MAKE) build-ios; \
	else \
		echo "$(YELLOW)Skipping iOS build (macOS required)$(NC)"; \
	fi
	@echo "$(GREEN)🎉 All platform builds completed!$(NC)"

# Deploy with domain name
deploy: build
	@echo "$(YELLOW)Deploying to $(VPS_IP) with domain $(DOMAIN_NAME)...$(NC)"
	@chmod +x deploy.sh
	@./deploy.sh $(VPS_IP) $(VPS_USER) $(DOMAIN_NAME)
	@echo "$(GREEN)🎉 Deployment completed!$(NC)"
	@echo "$(GREEN)Your app is available at: http://$(DOMAIN_NAME)$(NC)"

# Deploy with IP access only
deploy-ip: build
	@echo "$(YELLOW)Deploying to $(VPS_IP) with IP access...$(NC)"
	@chmod +x deploy.sh
	@./deploy.sh $(VPS_IP) $(VPS_USER)
	@echo "$(GREEN)🎉 Deployment completed!$(NC)"
	@echo "$(GREEN)Your app is available at: http://$(VPS_IP)$(NC)"

# Setup VPS environment (run once)
setup-vps: check-deps
	@echo "$(YELLOW)Setting up VPS environment...$(NC)"
	@ssh $(VPS_USER)@$(VPS_IP) 'bash -s' < setup-vps.sh
	@echo "$(GREEN)✅ VPS setup completed$(NC)"

# Test SSH connection
test-ssh:
	@echo "$(YELLOW)Testing SSH connection to $(VPS_IP)...$(NC)"
	@ssh -o ConnectTimeout=10 $(VPS_USER)@$(VPS_IP) 'echo "✅ SSH connection successful"'

# Check VPS status
status:
	@echo "$(YELLOW)Checking VPS status...$(NC)"
	@ssh $(VPS_USER)@$(VPS_IP) << 'EOF'
		echo "🖥️  System Info:"
		uname -a
		echo ""
		echo "💾 Disk Usage:"
		df -h /var/www/ 2>/dev/null || df -h /
		echo ""
		echo "🌐 Nginx Status:"
		sudo systemctl is-active nginx || echo "Nginx not running"
		echo ""
		echo "📁 Web Directory:"
		ls -la /var/www/$(PROJECT_NAME)/ 2>/dev/null || echo "Directory not found"
	EOF

# Enable HTTPS with Let's Encrypt
enable-https:
	@echo "$(YELLOW)Enabling HTTPS for $(DOMAIN_NAME)...$(NC)"
	@ssh $(VPS_USER)@$(VPS_IP) << 'EOF'
		sudo apt update
		sudo apt install certbot python3-certbot-nginx -y
		sudo certbot --nginx -d $(DOMAIN_NAME) -d www.$(DOMAIN_NAME) --non-interactive --agree-tos --email admin@$(DOMAIN_NAME)
		sudo systemctl restart nginx
	EOF
	@echo "$(GREEN)✅ HTTPS enabled!$(NC)"
	@echo "$(GREEN)Your app is now available at: https://$(DOMAIN_NAME)$(NC)"

# View logs
logs:
	@echo "$(YELLOW)Viewing Nginx logs...$(NC)"
	@ssh $(VPS_USER)@$(VPS_IP) 'sudo tail -f /var/log/nginx/access.log'

# Restart services
restart:
	@echo "$(YELLOW)Restarting services on VPS...$(NC)"
	@ssh $(VPS_USER)@$(VPS_IP) << 'EOF'
		sudo systemctl restart nginx
		sudo systemctl status nginx --no-pager
	EOF
	@echo "$(GREEN)✅ Services restarted$(NC)"

# Quick deployment (build + deploy)
quick: clean build deploy

# Full pipeline (test + analyze + build + deploy)
all: clean analyze test build deploy

# Development helpers
dev-build:
	@echo "$(YELLOW)Building for development...$(NC)"
	@flutter build web --debug
	@echo "$(GREEN)✅ Development build completed$(NC)"

dev-serve:
	@echo "$(YELLOW)Starting development server...$(NC)"
	@flutter run -d chrome --web-port=8080

# Run on Android device/emulator
run-android:
	@echo "$(YELLOW)Running on Android...$(NC)"
	@flutter run -d android

# Run on iOS device/simulator
run-ios:
	@echo "$(YELLOW)Running on iOS...$(NC)"
	@if [ "$$(uname)" != "Darwin" ]; then \
		echo "$(RED)❌ iOS development is only supported on macOS$(NC)"; \
		exit 1; \
	fi
	@flutter run -d ios

# Show connected devices
devices:
	@echo "$(YELLOW)Available devices:$(NC)"
	@flutter devices

# Install app on connected Android device
install-android: build-android
	@echo "$(YELLOW)Installing APK on Android device...$(NC)"
	@flutter install --use-application-binary=build/app/outputs/flutter-apk/app-release.apk

# Check app size
check-size:
	@echo "$(YELLOW)Checking app sizes...$(NC)"
	@if [ -f "build/web/main.dart.js" ]; then \
		echo "$(GREEN)Web app size:$(NC)"; \
		du -sh build/web/; \
	fi
	@if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then \
		echo "$(GREEN)Android APK size:$(NC)"; \
		ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print $$5 " " $$9}'; \
	fi
	@if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then \
		echo "$(GREEN)Android App Bundle size:$(NC)"; \
		ls -lh build/app/outputs/bundle/release/app-release.aab | awk '{print $$5 " " $$9}'; \
	fi

# Update dependencies
update-deps:
	@echo "$(YELLOW)Updating Flutter dependencies...$(NC)"
	@flutter pub upgrade
	@echo "$(GREEN)✅ Dependencies updated$(NC)"

# Update web favicon and icons from assets
update-favicon:
	@echo "$(YELLOW)Updating web favicon from assets/logo_transparent.png...$(NC)"
	@sips -z 16 16 assets/logo_transparent.png --out web/favicon-16x16.png
	@sips -z 32 32 assets/logo_transparent.png --out web/favicon.png
	@sips -z 192 192 assets/logo_transparent.png --out web/icons/Icon-192.png
	@sips -z 512 512 assets/logo_transparent.png --out web/icons/Icon-512.png
	@sips -z 192 192 assets/logo_transparent.png --out web/icons/Icon-maskable-192.png
	@sips -z 512 512 assets/logo_transparent.png --out web/icons/Icon-maskable-512.png
	@echo "$(GREEN)✅ Web favicon updated$(NC)"
	@echo "$(YELLOW)Run 'make build' to apply changes$(NC)"

# Backup current deployment
backup:
	@echo "$(YELLOW)Creating backup of current deployment...$(NC)"
	@ssh $(VPS_USER)@$(VPS_IP) << 'EOF'
		cd /var/www/
		sudo tar -czf $(PROJECT_NAME)-backup-$(shell date +%Y%m%d_%H%M%S).tar.gz $(PROJECT_NAME)/
		ls -la $(PROJECT_NAME)-backup-*.tar.gz
	EOF
	@echo "$(GREEN)✅ Backup created$(NC)"

# Show help for specific targets
help-deploy:
	@echo "$(GREEN)Deployment Commands:$(NC)"
	@echo "  make deploy     - Deploy with domain name (recommended)"
	@echo "  make deploy-ip  - Deploy with IP access only"
	@echo "  make quick      - Clean, build, and deploy"
	@echo "  make all        - Full pipeline with tests"

help-setup:
	@echo "$(GREEN)Setup Commands:$(NC)"
	@echo "  make setup-vps    - Initial VPS setup"
	@echo "  make enable-https - Enable SSL/HTTPS"
	@echo "  make test-ssh     - Test SSH connection"

help-maintenance:
	@echo "$(GREEN)Maintenance Commands:$(NC)"
	@echo "  make status     - Check VPS status"
	@echo "  make logs       - View Nginx logs"
	@echo "  make restart    - Restart services"
	@echo "  make backup     - Backup current deployment"

help-build:
	@echo "$(GREEN)Build Commands:$(NC)"
	@echo "  make build           - Build web app"
	@echo "  make build-android   - Build Android APK"
	@echo "  make build-appbundle - Build Android App Bundle (for Play Store)"
	@echo "  make build-ios       - Build iOS app (macOS only)"
	@echo "  make build-all       - Build all platforms"
	@echo "  make fix-android     - Fix common Android build issues"
	@echo "  make check-android   - Check Android environment"
	@echo "  make check-size      - Check built app sizes"
	@echo "  make update-deps     - Update Flutter dependencies"
	@echo "  make update-favicon  - Update web favicon from assets logo"

help-mobile:
	@echo "$(GREEN)Mobile Development Commands:$(NC)"
	@echo "  make run-android     - Run on Android device/emulator"
	@echo "  make run-ios         - Run on iOS device/simulator (macOS only)"
	@echo "  make install-android - Install APK on connected Android device"
	@echo "  make devices         - Show available devices"
	@echo "  make check-size      - Check app sizes"
