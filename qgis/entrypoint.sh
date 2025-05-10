#!/bin/bash

# Exit on error
set -e

# Check required environment variables
if [[ -z "$USER_NAME" || -z "$USER_PASSWORD" ]]; then
  echo "ERROR: USER_NAME and USER_PASSWORD must be set."
  exit 1
fi

# Create user if it doesn't exist
if ! id "$USER_NAME" &>/dev/null; then
  echo "Creating user $USER_NAME..."
  useradd -ms /bin/bash "$USER_NAME"
  echo "$USER_NAME:$USER_PASSWORD" | chpasswd
  adduser "$USER_NAME" sudo
fi

# Set up shared directories
mkdir -p /home/"$USER_NAME"/share /tmp/share
chmod 777 /home/"$USER_NAME"/share /tmp/share
chown -R "$USER_NAME":"$USER_NAME" /home/"$USER_NAME" /tmp/share

# Start services
service dbus start
service xrdp start

# Keep container running
tail -f /var/log/xrdp-sesman.log


CMD chown -R qgis:qgis /home/qgis  \
    && service dbus start \
    && service xrdp start \
    && tail -f /var/log/xrdp-sesman.log
