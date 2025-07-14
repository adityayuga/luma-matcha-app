#!/bin/bash

# Flutter Web Deployment Script for Luma Matcha
# Fixes "Importing a module script failed" error

set -e

VPS_IP=$1
VPS_USER=$2
DOMAIN_NAME=$3
FORCE_OVERWRITE=""

# Parse additional arguments
for arg in "$@"; do
    case $arg in
        --force-nginx)
            FORCE_OVERWRITE="--force-nginx"
            shift
            ;;
    esac
done

if [ -z "$VPS_IP" ] || [ -z "$VPS_USER" ]; then
    echo "Usage: ./deploy.sh [VPS_IP] [VPS_USER] [DOMAIN_NAME(optional)] [--force-nginx]"
    echo "Example: ./deploy.sh 192.168.1.100 ubuntu lumamatcha.com"
    echo "Example (force nginx overwrite): ./deploy.sh 192.168.1.100 ubuntu lumamatcha.com --force-nginx"
    exit 1
fi

echo "🚀 Starting deployment to $VPS_IP..."

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
    # Pass the force flag to the remote script
    FORCE_OVERWRITE="$FORCE_OVERWRITE"
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
    
    # Check if Nginx config already exists and handle accordingly
    NGINX_CONFIG_EXISTS=false
    if [ -f "/etc/nginx/sites-available/luma-matcha" ]; then
        NGINX_CONFIG_EXISTS=true
        echo "⚠️  Existing Nginx configuration found at /etc/nginx/sites-available/luma-matcha"
    fi
    
    # Determine whether to update Nginx config
    UPDATE_NGINX=false
    if [ "$NGINX_CONFIG_EXISTS" = false ]; then
        echo "📝 No existing Nginx config found, will create new one"
        UPDATE_NGINX=true
    elif [ "\$FORCE_OVERWRITE" = "--force-nginx" ]; then
        echo "🔄 Force overwrite flag detected, updating Nginx configuration"
        UPDATE_NGINX=true
    else
        echo "🤔 Existing Nginx configuration detected."
        echo "   Current config will be backed up as luma-matcha.backup.\$(date +%Y%m%d_%H%M%S)"
        echo "   To force overwrite next time, use: ./deploy.sh [VPS_IP] [VPS_USER] [DOMAIN] --force-nginx"
        read -p "   Do you want to overwrite the existing Nginx config? (y/N): " -r REPLY
        if [[ \$REPLY =~ ^[Yy]\$ ]]; then
            UPDATE_NGINX=true
        else
            echo "⏭️  Skipping Nginx configuration update"
            UPDATE_NGINX=false
        fi
    fi
    
    # Update Nginx configuration if needed
    if [ "\$UPDATE_NGINX" = true ]; then
        # Backup existing config if it exists
        if [ "\$NGINX_CONFIG_EXISTS" = true ]; then
            sudo cp /etc/nginx/sites-available/luma-matcha /etc/nginx/sites-available/luma-matcha.backup.\$(date +%Y%m%d_%H%M%S)
            echo "✅ Existing config backed up"
        fi
        
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
    else
        # Clean up uploaded config file since we're not using it
        rm -f ~/nginx-flutter.conf
        echo "ℹ️  Using existing Nginx configuration"
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
echo "🔧 Fixes available in this deployment:"
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
echo "� Tips:"
echo "   • To force Nginx config overwrite: ./deploy.sh $VPS_IP $VPS_USER $DOMAIN_NAME --force-nginx"
echo "   • Check nginx logs: sudo tail -f /var/log/nginx/error.log"
echo "   • Test config: sudo nginx -t"
