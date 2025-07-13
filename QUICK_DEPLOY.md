# Quick VPS Deployment for Luma Matcha App

## 🚀 Option 1: Automated Deployment (Recommended)

### Prerequisites:
- SSH access to your VPS
- Flutter installed locally

### Deploy with one command:
```bash
./deploy.sh YOUR_VPS_IP YOUR_VPS_USERNAME [OPTIONAL_DOMAIN]
```

**Examples:**
```bash
# IP-based deployment
./deploy.sh 192.168.1.100 ubuntu

# Domain-based deployment
./deploy.sh 192.168.1.100 ubuntu luma-matcha.com
```

## 🔧 Option 2: Manual Deployment

### 1. Build your app:
```bash
flutter build web --release
```

### 2. Upload to your VPS:
```bash
scp -r build/web/ user@your-vps-ip:/var/www/luma-matcha/
```

### 3. On your VPS, install Nginx:
```bash
sudo apt update
sudo apt install nginx -y
```

### 4. Configure Nginx:
```bash
sudo nano /etc/nginx/sites-available/luma-matcha
```

Add this configuration:
```nginx
server {
    listen 80;
    server_name _;
    root /var/www/luma-matcha;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### 5. Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/luma-matcha /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

## 🌐 Access Your App

After deployment, your Luma Matcha app will be available at:
- **http://YOUR_VPS_IP**
- **http://YOUR_DOMAIN** (if you have a domain)

## 🔒 Enable HTTPS (Optional but Recommended)

If you have a domain:
```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d your-domain.com
```

## 📱 Features Available

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

## 📁 Your build includes:
- **Size:** ~2.3MB (highly optimized)
- **Assets:** Your logo and icons
- **Fonts:** Google Fonts (Crimson Text)
- **Service Worker:** For PWA functionality

## 🔄 Updating Your App

When you make changes:
1. `flutter build web --release`
2. Upload new files to VPS
3. Restart Nginx (optional)

That's it! Your professional Luma Matcha web app is ready for the world! 🎉
