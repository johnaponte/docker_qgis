#!/bin/sh

if [ -r /etc/profile ]; then
    . /etc/profile
fi

# Lanzar dbus si no está activo
if [ -z "\$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "\$(dbus-launch --sh-syntax --exit-with-session)"
fi

export DESKTOP_SESSION=xfce
export XDG_SESSION_DESKTOP=xfce
export XDG_CURRENT_DESKTOP=XFCE

# Lanzar el demonio de configuración de XFCE si no se lanza solo
#/usr/lib/x86_64-linux-gnu/xfce4/xfconf/xfconfd --replace &

# Iniciar gestor de configuración manualmente si lo querés
# /usr/lib/xfce4/xfsettingsd &

# Iniciar el gestor de ventanas (barras, bordes)
xfwm4 &

# Fondo e iconos (opcional)
#xfdesktop &

# Panel de XFCE
xfce4-panel &

# File manager opcional
# thunar &
 
# Iniciar QGIS maximizado
qgis & sleep 5 && wmctrl -r QGIS -b add,maximized_vert,maximized_horz &

# Mantener sesión viva (esperar a que panel termine)
wait

# OR start xfce4....
#startxfce4 &
