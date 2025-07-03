#!/bin/bash

# Ensure script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)"
    exit 1
fi

# Get the public IP address of the server
PUBLIC_IP=$(curl -s http://ifconfig.me)

# Check if public IP was retrieved successfully
if [ -z "$PUBLIC_IP" ]; then
    echo "Error: Could not retrieve public IP address"
    exit 1
fi

# Define the Nginx configuration
NGINX_CONFIG="server {
    listen 80;
    server_name ${PUBLIC_IP};

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}"

# Path to default Nginx configuration file on Ubuntu
NGINX_CONF_PATH="/etc/nginx/sites-available/default"

# Check if Nginx is installed
if ! command -v nginx &> /dev/null; then
    echo "Error: Nginx is not installed. Install it with 'sudo apt install nginx'"
    exit 1
fi

# Check if the configuration file exists
if [ ! -f "$NGINX_CONF_PATH" ]; then
    echo "Error: Nginx default configuration file not found at $NGINX_CONF_PATH"
    exit 1
fi

# Backup the existing default configuration
BACKUP_PATH="${NGINX_CONF_PATH}.backup-$(date +%F_%H-%M-%S)"
cp "$NGINX_CONF_PATH" "$BACKUP_PATH"
if [ $? -eq 0 ]; then
    echo "Backed up existing configuration to $BACKUP_PATH"
else
    echo "Error: Failed to create backup of existing configuration"
    exit 1
fi

# Write the new configuration
echo "$NGINX_CONFIG" > /tmp/nginx_temp_config
mv /tmp/nginx_temp_config "$NGINX_CONF_PATH"
if [ $? -ne 0 ]; then
    echo "Error: Failed to write new configuration to $NGINX_CONF_PATH"
    exit 1
fi

# Set appropriate permissions
chmod 644 "$NGINX_CONF_PATH"
chown root:root "$NGINX_CONF_PATH"

# Test the Nginx configuration
nginx -t
if [ $? -ne 0 ]; then
    echo "Error: Nginx configuration test failed"
    exit 1
fi

# Reload Nginx to apply changes
systemctl reload nginx
if [ $? -eq 0 ]; then
    echo "Nginx configuration updated successfully with public IP: ${PUBLIC_IP}"
else
    echo "Error: Failed to reload Nginx"
    exit 1
fi
