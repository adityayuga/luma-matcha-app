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

.PHONY: help build clean deploy deploy-ip setup-vps check-deps test analyze

# Default target
help:
	@echo "$(GREEN)Luma Matcha Flutter Web Deployment$(NC)"
	@echo ""
	@echo "$(YELLOW)Available commands:$(NC)"
	@echo "  make build        - Build Flutter web app for production"
	@echo "  make deploy       - Deploy to VPS with domain ($(DOMAIN_NAME))"
	@echo "  make deploy-ip    - Deploy to VPS with IP access only"
	@echo "  make setup-vps    - Setup VPS environment (run once)"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make test         - Run Flutter tests"
	@echo "  make analyze      - Analyze Flutter code"
	@echo "  make check-deps   - Check Flutter dependencies"
	@echo "  make all          - Build, test, and deploy"
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

# Clean build artifacts
clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@flutter clean
	@rm -f $(ARCHIVE_NAME)
	@rm -f nginx-config
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

# Build Flutter web app
build: check-deps
	@echo "$(YELLOW)Building Flutter web app...$(NC)"
	@flutter pub get
	@flutter build web --release
	@echo "$(GREEN)✅ Build completed$(NC)"

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

# Update dependencies
update-deps:
	@echo "$(YELLOW)Updating Flutter dependencies...$(NC)"
	@flutter pub upgrade
	@echo "$(GREEN)✅ Dependencies updated$(NC)"

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
