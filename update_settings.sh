#!/bin/bash

# Exit on any error
set -e

# Fetch the public IP address from EC2 metadata
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Check if PUBLIC_IP was successfully retrieved
if [ -z "$PUBLIC_IP" ]; then
    echo "Error: Could not retrieve public IP address. Ensure this is running on an EC2 instance with a public IP."
    exit 1
fi

# Define the path to settings.py
SETTINGS_FILE="/home/ubuntu/course_platform/course_platform/settings.py"

# Check if settings.py exists
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "Error: settings.py not found at $SETTINGS_FILE"
    exit 1
fi

# Create a temporary file for the updated settings
TEMP_FILE=$(mktemp)

# Replace <ec2-public-ip> with the actual public IP
sed "s/<ec2-public-ip>/$PUBLIC_IP/" "$SETTINGS_FILE" > "$TEMP_FILE"

# Move the updated file to replace the original settings.py
mv "$TEMP_FILE" "$SETTINGS_FILE"

# Set appropriate permissions for settings.py
chmod 644 "$SETTINGS_FILE"

echo "Updated settings.py with public IP: $PUBLIC_IP"

# Optional: Restart the Django application (e.g., Gunicorn)
# Uncomment and modify the following lines based on your setup
# pkill gunicorn
# gunicorn --bind 0.0.0.0:8000 course_platform.wsgi:application &
