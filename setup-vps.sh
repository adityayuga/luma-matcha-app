#!/bin/bash

# VPS Setup Script for Luma Matcha Flutter Web App
# This script prepares a Ubuntu VPS for hosting the Flutter web app

set -e

echo "🚀 Setting up VPS for Luma Matcha Flutter Web App..."

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "🔧 Installing required packages..."
sudo apt install -y nginx curl wget unzip git ufw

# Configure firewall
echo "🔒 Configuring firewall..."
sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw allow 80
sudo ufw allow 443

# Create web directory
echo "📁 Creating web directory..."
sudo mkdir -p /var/www/luma-matcha
sudo chown -R www-data:www-data /var/www/luma-matcha
sudo chmod -R 755 /var/www/luma-matcha

# Start and enable Nginx
echo "🌐 Starting Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Create a simple index page
sudo tee /var/www/luma-matcha/index.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Luma Matcha - Setup Complete</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            text-align: center; 
            margin: 50px;
            background-color: #fefff a;
            color: #456330;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            border: 2px solid #456330;
            border-radius: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🍃 Luma Matcha Jogja</h1>
        <h2>VPS Setup Complete!</h2>
        <p>Your server is ready for deployment.</p>
        <p>Run <code>make deploy</code> to deploy your Flutter web app.</p>
    </div>
</body>
</html>
EOF

# Install Certbot (for HTTPS)
echo "🔒 Installing Certbot for SSL certificates..."
sudo apt install -y certbot python3-certbot-nginx

# Test and reload Nginx
echo "✅ Testing Nginx configuration..."
sudo nginx -t
sudo systemctl reload nginx

# Display system information
echo ""
echo "🎉 VPS Setup completed successfully!"
echo ""
echo "📊 System Information:"
echo "   OS: $(lsb_release -d | cut -f2)"
echo "   Nginx: $(nginx -v 2>&1 | cut -d' ' -f3)"
echo "   UFW Status: $(sudo ufw status | head -1)"
echo ""
echo "📁 Web Directory: /var/www/luma-matcha"
echo "🌐 Nginx Status: $(systemctl is-active nginx)"
echo ""
echo "✅ Your VPS is ready for Flutter web deployment!"
echo "🚀 Run 'make deploy' to deploy your app."
