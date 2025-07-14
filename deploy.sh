#!/bin/bash

# Fixed Flutter Web Deployment Script for Luma Matcha
# Fixes "Importing a module script failed" error

set -e

VPS_IP=$1
VPS_USER=$2
DOMAIN_NAME=$3

if [ -z "$VPS_IP" ] || [ -z "$VPS_USER" ]; then
    echo "Usage: ./deploy.sh [VPS_IP] [VPS_USER] [DOMAIN_NAME(optional)]"
    echo "Example: ./deploy.sh 192.168.1.100 ubuntu lumamatcha.com"
    exit 1
fi

echo "🚀 Starting fixed deployment to $VPS_IP..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Build Flutter web app with proper settings
echo "📦 Building Flutter web app with production settings..."
flutter build web \
    --release \
    --base-href="/" \
    --pwa-strategy=offline-first

# Verify build files exist
if [ ! -f "build/web/main.dart.js" ]; then
    echo "❌ Build failed - main.dart.js not found"
    exit 1
fi

echo "✅ Build successful - main.dart.js size: $(wc -c < build/web/main.dart.js) bytes"

# Create deployment archive
echo "📁 Creating deployment archive..."
tar -czf luma-matcha-web.tar.gz build/web/

# Upload files to VPS
echo "⬆️ Uploading to VPS..."
scp luma-matcha-web.tar.gz $VPS_USER@$VPS_IP:~/
scp nginx-flutter.conf $VPS_USER@$VPS_IP:~/

# Execute deployment commands on VPS
echo "⚙️ Setting up on VPS with configuration..."
ssh $VPS_USER@$VPS_IP << EOF
    # Backup existing site if it exists
    if [ -d "/var/www/luma-matcha" ]; then
        sudo cp -r /var/www/luma-matcha /var/www/luma-matcha-backup-\$(date +%Y%m%d_%H%M%S)
    fi
    
    # Create web directory
    sudo mkdir -p /var/www/luma-matcha
    
    # Extract files
    sudo tar -xzf ~/luma-matcha-web.tar.gz --strip-components=2 -C /var/www/luma-matcha/
    
    # Set proper permissions
    sudo chown -R www-data:www-data /var/www/luma-matcha
    sudo chmod -R 755 /var/www/luma-matcha
    
    # Verify critical files exist
    if [ ! -f "/var/www/luma-matcha/main.dart.js" ]; then
        echo "❌ Critical file main.dart.js missing after extraction"
        exit 1
    fi
    
    echo "✅ Files deployed - main.dart.js size: \$(wc -c < /var/www/luma-matcha/main.dart.js) bytes"
    
    # Install Nginx if not installed
    sudo apt update
    sudo apt install nginx -y
    
    # Configure Nginx with Flutter-specific settings
    sudo mv ~/nginx-flutter.conf /etc/nginx/sites-available/luma-matcha
    sudo ln -sf /etc/nginx/sites-available/luma-matcha /etc/nginx/sites-enabled/
    
    # Remove default site
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Test Nginx configuration
    sudo nginx -t
    
    if [ \$? -eq 0 ]; then
        # Reload Nginx
        sudo systemctl reload nginx
        sudo systemctl enable nginx
        echo "✅ Nginx configuration updated and reloaded"
    else
        echo "❌ Nginx configuration test failed"
        exit 1
    fi
    
    # Clean up
    rm ~/luma-matcha-web.tar.gz
    
    echo "✅ Deployment completed successfully!"
    echo "📝 Next steps:"
    echo "   1. Update your Cloudflare SSL/TLS mode to 'Full (strict)'"
    echo "   2. Ensure your domain DNS points to this server"
    echo "   3. Set up SSL certificate if needed: sudo certbot --nginx -d $DOMAIN_NAME"
    echo "   4. Test the site: https://$DOMAIN_NAME"
EOF

# Clean up local files
rm luma-matcha-web.tar.gz

echo ""
echo "🎉 Deployment script completed!"
echo ""
echo "🔧 Common fixes applied:"
echo "   ✅ Fixed MIME types for .js and .wasm files"
echo "   ✅ Added proper Cross-Origin headers"
echo "   ✅ Fixed Content Security Policy for Flutter web"
echo "   ✅ Added proper caching rules"
echo "   ✅ Fixed base href in index.html"
echo ""
echo "🌐 Your site should now be accessible at:"
if [ -n "$DOMAIN_NAME" ]; then
    echo "   https://$DOMAIN_NAME"
else
    echo "   http://$VPS_IP"
fi
echo ""
echo "🐛 If you still see issues, check browser console and nginx logs:"
echo "   sudo tail -f /var/log/nginx/error.log"
