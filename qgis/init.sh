#!/bin/bash

# Set DISPLAY for all graphical applications
export DISPLAY=:0

# Set XDG_RUNTIME_DIR to avoid Qt warnings
export XDG_RUNTIME_DIR=/tmp/runtime-qgis
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

# Start virtual X server
Xvfb :0 -screen 0 1920x1080x24 +extension RANDR &
XVFB_PID=$!
sleep 2

# Start D-Bus session
eval "$(dbus-launch --sh-syntax)"
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

# Start LXDE desktop environment
lxsession &

# Wait for LXDE to initialize
sleep 5

# Start QGIS in background
qgis &

# Start VNC with optional performance tuning
x11vnc -display :0 \
    -forever \
    -nopw \
    -shared \
    -rfbport 5901 \
    -noxdamage \
    -xrandr 
