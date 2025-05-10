#!/bin/bash

# Exit on error
set -e

# Create user if it doesn't exist
if ! id "$USER_NAME" &>/dev/null; then
  echo "Creating user $USER_NAME..."
  useradd -m -s /bin/bash "$USER_NAME"
  echo "$USER_NAME:$USER_PASSWORD" | chpasswd
  adduser "$USER_NAME" sudo

  # Copy default config files from /etc/skel if home doesn't already have them
  echo "Copying default files from /etc/skel to /home/$USER_NAME..."
  cp -rn /etc/skel/. /home/"$USER_NAME"/
fi

# Ensure QGIS config directories exist
mkdir -p /home/"$USER_NAME"/.config/QGIS
mkdir -p /home/"$USER_NAME"/.local/share/QGIS

# Ensure shared folders exist
mkdir -p /home/"$USER_NAME"/share /tmp/share

# Set ownership and permissions
chown -R "$USER_NAME:$USER_NAME" /home/"$USER_NAME"
chown -R "$USER_NAME:$USER_NAME" /tmp/share
chmod 777 /home/"$USER_NAME"/share /tmp/share


# Start services
service dbus start
service xrdp start

# Keep container running
touch /tmp/startwm.log
chmod 666 /tmp/startwm.log
chown "$USER_NAME:$USER_NAME" /tmp/startwm.log
tail -F /var/log/xrdp-sesman.log /tmp/startwm.log