#!/bin/sh

# Redirect stdout and stderr to Docker-visible log file
exec >> /tmp/startwm.log 2>&1

echo "[startwm.sh] launched ************************"

# Fix runtime dir to avoid XDG warnings
export XDG_RUNTIME_DIR=/tmp/runtime-$USER
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# Avoid accessibility bridge warnings
export NO_AT_BRIDGE=1

# Set display environment
export DISPLAY=:10
export XAUTHORITY="/home/$USER/.Xauthority"

# Set XFCE-related environment vars
export DESKTOP_SESSION=xfce
export XDG_SESSION_DESKTOP=xfce
export XDG_CURRENT_DESKTOP=XFCE
export GTK_A11Y=none

# Launch XFCE components
echo "[startwm.sh] Starting XFCE..."
xfwm4 &
xfce4-panel &
xfsettingsd &

#opcional ##
# File manager 
# thunar &
# Desktop icons 
#xfdesktop &

# Disable compositor after XFCE is running
sleep 1  # give it a sec to start
xfconf-query -c xfwm4 -p /general/use_compositing --create -t bool -s false

# Clean the panel
rm -rf ~/.config/xfce4/panel

# Start QGIS
echo "[startwm.sh] Launching QGIS..."
qgis &

# Wait for the main QGIS window to appear (not splash or helper windows)
echo "[startwm.sh] Waiting for main QGIS window..."
while true; do
    echo "[DEBUG] Current open windows:"
    wmctrl -l || echo "[DEBUG] Could not retrieve window list"

    QGIS_LINE=$(wmctrl -l | grep " — QGIS" | head -n1)

    if [ -n "$QGIS_LINE" ]; then
        echo "[DEBUG] Main QGIS window detected:"
        echo "[DEBUG] $QGIS_LINE"

        QGIS_ID=$(echo "$QGIS_LINE" | awk '{print $1}')
        echo "[DEBUG] Maximizing window ID: $QGIS_ID"
        wmctrl -i -r "$QGIS_ID" -b add,maximized_vert,maximized_horz

        break
    else
        echo "[DEBUG] No main QGIS window found yet..."
        sleep 1
    fi
done

# Keep session alive
echo "[startwm.sh] XFCE + QGIS running."
wait

