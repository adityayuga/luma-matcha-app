#!/bin/bash

# Luma Matcha Flutter Web Deployment Script
# Usage: ./deploy.sh [VPS_IP] [VPS_USER] [DOMAIN_NAME(optional)]

set -e

VPS_IP=$1
VPS_USER=$2
DOMAIN_NAME=$3

if [ -z "$VPS_IP" ] || [ -z "$VPS_USER" ]; then
    echo "Usage: ./deploy.sh [VPS_IP] [VPS_USER] [DOMAIN_NAME(optional)]"
    echo "Example: ./deploy.sh 192.168.1.100 ubuntu luma-matcha.com"
    exit 1
fi

echo "🚀 Starting deployment to $VPS_IP..."

# Build Flutter web app
echo "📦 Building Flutter web app..."
flutter build web --release

# Create deployment archive
echo "📁 Creating deployment archive..."
tar -czf luma-matcha-web.tar.gz build/web/

# Upload to VPS
echo "⬆️ Uploading to VPS..."
scp luma-matcha-web.tar.gz $VPS_USER@$VPS_IP:~/

# Execute deployment commands on VPS
echo "⚙️ Setting up on VPS..."
ssh $VPS_USER@$VPS_IP << EOF
    # Create web directory
    sudo mkdir -p /var/www/luma-matcha
    
    # Extract files
    sudo tar -xzf ~/luma-matcha-web.tar.gz --strip-components=2 -C /var/www/luma-matcha/
    
    # Set permissions
    sudo chown -R www-data:www-data /var/www/luma-matcha
    sudo chmod -R 755 /var/www/luma-matcha
    
    # Clean up
    rm ~/luma-matcha-web.tar.gz
    
    echo "✅ Files deployed successfully!"
EOF

# Generate Nginx config based on whether domain is provided
if [ -n "$DOMAIN_NAME" ]; then
    echo "🔧 Creating Nginx config for domain: $DOMAIN_NAME"
    cat > nginx-config << EOL
server {
    listen 80;
    server_name $DOMAIN_NAME www.$DOMAIN_NAME;
    
    root /var/www/luma-matcha;
    index index.html;
    
    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private auth;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss;
    
    location / {
        try_files \$uri \$uri/ /index.html;
        
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
EOL
else
    echo "🔧 Creating Nginx config for IP-based access"
    cat > nginx-config << EOL
server {
    listen 80 default_server;
    server_name _;
    
    root /var/www/luma-matcha;
    index index.html;
    
    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private auth;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss;
    
    location / {
        try_files \$uri \$uri/ /index.html;
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
EOL
fi

# Upload and configure Nginx
scp nginx-config $VPS_USER@$VPS_IP:~/
ssh $VPS_USER@$VPS_IP << EOF
    # Install Nginx if not installed
    sudo apt update
    sudo apt install nginx -y
    
    # Configure Nginx
    sudo mv ~/nginx-config /etc/nginx/sites-available/luma-matcha
    sudo ln -sf /etc/nginx/sites-available/luma-matcha /etc/nginx/sites-enabled/
    
    # Remove default site
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Test and reload Nginx
    sudo nginx -t
    sudo systemctl restart nginx
    sudo systemctl enable nginx
    
    # Configure firewall
    sudo ufw allow 'Nginx Full' 2>/dev/null || true
    
    echo "✅ Nginx configured successfully!"
EOF

# Clean up local files
rm nginx-config
rm luma-matcha-web.tar.gz

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
if [ -n "$DOMAIN_NAME" ]; then
    echo "🌐 Your app is available at:"
    echo "   http://$DOMAIN_NAME"
    echo "   http://www.$DOMAIN_NAME"
    echo ""
    echo "🔒 To enable HTTPS, run on your VPS:"
    echo "   sudo apt install certbot python3-certbot-nginx -y"
    echo "   sudo certbot --nginx -d $DOMAIN_NAME -d www.$DOMAIN_NAME"
else
    echo "🌐 Your app is available at:"
    echo "   http://$VPS_IP"
fi
echo ""
echo "📚 For detailed instructions, see DEPLOYMENT_GUIDE.md"
