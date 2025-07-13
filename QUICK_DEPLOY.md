# Quick Deployment Guide

## Your Configuration
- **VPS IP**: 54.169.51.229
- **User**: ubuntu
- **Domain**: lumamatcha.com

## 🚀 Quick Start

### 1. First Time Setup (Run Once)
```bash
# Setup your VPS environment
make setup-vps

# Test SSH connection
make test-ssh
```

### 2. Deploy Your App
```bash
# Deploy with domain name (recommended)
make deploy

# OR deploy with IP access only
make deploy-ip
```

### 3. Enable HTTPS (Optional but Recommended)
```bash
make enable-https
```

## 📋 Common Commands

### Development
```bash
make build          # Build the app
make clean          # Clean build files
make analyze        # Check code quality
make test           # Run tests
```

### Deployment
```bash
make deploy         # Full deployment with domain
make deploy-ip      # Deploy with IP access
make quick          # Clean + build + deploy
make all            # Test + analyze + build + deploy
```

### Maintenance
```bash
make status         # Check VPS status
make logs           # View server logs
make restart        # Restart services
make backup         # Backup current deployment
```

## 🌐 URLs After Deployment

### HTTP Access
- http://lumamatcha.com
- http://www.lumamatcha.com
- http://54.169.51.229

### HTTPS Access (after running `make enable-https`)
- https://lumamatcha.com
- https://www.lumamatcha.com

## 🔧 Alternative: Manual Deployment

### Deploy with one command:
```bash
./deploy.sh 54.169.51.229 ubuntu lumamatcha.com
```

### First time VPS setup:
```bash
./setup-vps.sh
```

## �️ Troubleshooting

### Test SSH Connection
```bash
make test-ssh
```

### Check VPS Status
```bash
make status
```

### View Server Logs
```bash
make logs
```

### Restart Services
```bash
make restart
```

## 📁 File Structure
```
luma_app/
├── Makefile           # Deployment commands
├── deploy.sh          # Deployment script
├── setup-vps.sh       # VPS setup script
├── build/web/         # Flutter build output
└── lib/               # Flutter source code
```

## ✅ Features Available

✅ **All social media links work:**
- Instagram: Opens Luma Matcha Instagram
- TikTok: Opens Luma Matcha TikTok  
- WhatsApp: Direct message to your number
- GrabFood: Opens your GrabFood listing
- Location: Opens Google Maps

✅ **Menu viewing** (when you add menu image)
✅ **Responsive design** for mobile and desktop
✅ **Fast loading** with optimized assets
✅ **PWA capabilities** (installable on mobile)

## � Your build includes:
- **Size:** ~2.3MB (highly optimized)
- **Assets:** Your logo and icons
- **Fonts:** Google Fonts (Crimson Text)
- **Service Worker:** For PWA functionality

## 🔄 Updating Your App

When you make changes:
```bash
make quick          # Clean, build, and deploy
```

Or manually:
1. `flutter build web --release`
2. Upload new files to VPS
3. Restart Nginx (optional)

## 🔒 Security Features

- ✅ Firewall configured
- ✅ Nginx security headers
- ✅ Gzip compression enabled
- ✅ Static file caching
- ✅ HTTPS ready (with domain)

## 💡 Prerequisites
- Flutter SDK installed
- SSH access to your VPS
- Domain name pointing to your VPS (for HTTPS)

That's it! Your professional Luma Matcha web app is ready for the world! 🎉
