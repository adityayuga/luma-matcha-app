# Flutter Web VPS Deployment Guide - Luma Matcha App

## 📋 Pre-requisites

### On your VPS:
- Ubuntu 20.04+ or similar Linux distribution
- Root or sudo access
- Domain name pointed to your VPS (optional but recommended)

### Required software:
- Nginx
- Certbot (for SSL/HTTPS)

## 🚀 Step 1: Prepare Your VPS

### 1. Update your system:
```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Install Nginx:
```bash
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 3. Install Certbot for SSL:
```bash
sudo apt install certbot python3-certbot-nginx -y
```

## 📦 Step 2: Upload Your Flutter Web Build

### 1. Transfer the build files to your VPS:

**Option A: Using SCP from your local machine:**
```bash
scp -r build/web/ user@your-vps-ip:/var/www/luma-matcha/
```

**Option B: Using rsync:**
```bash
rsync -avz build/web/ user@your-vps-ip:/var/www/luma-matcha/
```

**Option C: Using the archive file:**
```bash
# Upload the archive
scp luma-matcha-web.tar.gz user@your-vps-ip:~

# On VPS, extract:
sudo mkdir -p /var/www/luma-matcha
sudo tar -xzf ~/luma-matcha-web.tar.gz -C /var/www/
sudo mv /var/www/web/* /var/www/luma-matcha/
sudo rm -rf /var/www/web
```

### 2. Set proper permissions:
```bash
sudo chown -R www-data:www-data /var/www/luma-matcha
sudo chmod -R 755 /var/www/luma-matcha
```

## ⚙️ Step 3: Configure Nginx

### 1. Create Nginx configuration:
```bash
sudo nano /etc/nginx/sites-available/luma-matcha
```

### 2. Add this configuration:

**For domain-based deployment:**
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    
    root /var/www/luma-matcha;
    index index.html;
    
    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss;
    
    location / {
        try_files $uri $uri/ /index.html;
        
        # Add security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Handle Flutter service worker
    location /flutter_service_worker.js {
        add_header Cache-Control "no-cache";
        expires 0;
    }
}
```

**For IP-based deployment (no domain):**
```nginx
server {
    listen 80 default_server;
    server_name _;
    
    root /var/www/luma-matcha;
    index index.html;
    
    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Handle Flutter service worker
    location /flutter_service_worker.js {
        add_header Cache-Control "no-cache";
        expires 0;
    }
}
```

### 3. Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/luma-matcha /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 4. Remove default Nginx site (optional):
```bash
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl reload nginx
```

## 🔒 Step 4: Set up SSL (HTTPS) - For Domain-based Deployment

### 1. Obtain SSL certificate:
```bash
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

### 2. Test SSL renewal:
```bash
sudo certbot renew --dry-run
```

## 🔥 Step 5: Configure Firewall

```bash
sudo ufw allow 'Nginx Full'
sudo ufw allow ssh
sudo ufw --force enable
```

## ✅ Step 6: Verify Deployment

### 1. Check Nginx status:
```bash
sudo systemctl status nginx
```

### 2. Test your site:
- **With domain:** https://your-domain.com
- **With IP:** http://your-vps-ip

### 3. Check logs if there are issues:
```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

## 🔄 Step 7: Updating Your App

### When you make changes to your Flutter app:

1. **Build new version locally:**
```bash
flutter build web --release
```

2. **Upload to VPS:**
```bash
rsync -avz --delete build/web/ user@your-vps-ip:/var/www/luma-matcha/
```

3. **Set permissions:**
```bash
sudo chown -R www-data:www-data /var/www/luma-matcha
```

## 🛡️ Security Best Practices

### 1. Keep system updated:
```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Configure automatic security updates:
```bash
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 3. Regular SSL certificate renewal:
```bash
# Add to crontab
sudo crontab -e
# Add this line:
0 12 * * * /usr/bin/certbot renew --quiet
```

## 📊 Performance Optimization

### 1. Enable HTTP/2 in Nginx:
Add to server block:
```nginx
listen 443 ssl http2;
```

### 2. Add browser caching headers:
```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## 🐛 Troubleshooting

### Common issues:

1. **403 Forbidden:**
   - Check file permissions: `ls -la /var/www/luma-matcha`
   - Ensure www-data owns files: `sudo chown -R www-data:www-data /var/www/luma-matcha`

2. **404 Not Found:**
   - Check Nginx config: `sudo nginx -t`
   - Verify files exist: `ls -la /var/www/luma-matcha`

3. **Route not working:**
   - Ensure `try_files` directive includes `/index.html`
   - Check Flutter routing configuration

4. **Images not loading:**
   - Verify assets are in the correct directory
   - Check file permissions
   - Ensure assets are properly built

## 📱 Mobile Considerations

Your Flutter web app will work on mobile browsers, but consider:
- Touch-friendly interface (already implemented)
- Responsive design
- PWA features (service worker is included)

## 🔗 Useful Commands

```bash
# Check Nginx config
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Check disk space
df -h

# Monitor logs in real-time
sudo tail -f /var/log/nginx/access.log

# Check SSL certificate expiry
sudo certbot certificates
```

## 📞 Support

Your Luma Matcha app is now deployed! Access it at:
- **Domain:** https://your-domain.com
- **IP:** http://your-vps-ip

Features that work:
- ✅ All external links (Instagram, TikTok, WhatsApp, GrabFood, Location)
- ✅ GoRouter navigation
- ✅ Responsive design
- ✅ PWA capabilities
- ✅ Asset loading
- ✅ Google Fonts

**File size:** ~2.3MB (optimized with tree-shaking)
**Load time:** Fast (with proper caching)
**SEO:** Flutter web handles basic SEO
