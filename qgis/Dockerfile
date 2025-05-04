FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    gnupg \
    lsb-release \
    ca-certificates \
    software-properties-common \
    x11vnc \
    xvfb \
    xterm \
    x11-xserver-utils \
    xfonts-75dpi \
    xfonts-100dpi \
    arandr \
    lxrandr \
    x11-utils \
    lxde \
    dbus-x11 \
    qgis \
    qgis-plugin-grass


# Crear /tmp/.X11-unix con los permisos correctos
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix
    
# Crear usuario no root
RUN useradd -ms /bin/bash qgis && echo "qgis:qgis" | chpasswd && adduser qgis sudo

# Configurar VNC password para qgis (usa 'vncpass' como clave)
#RUN mkdir -p /home/qgis/.vnc && \
#    echo "vncpass" | vncpasswd -f > /home/qgis/.vnc/passwd && \
#    chmod 600 /home/qgis/.vnc/passwd && \
#    chown -R qgis:qgis /home/qgis/.vnc

USER qgis
ENV USER=qgis
WORKDIR /home/qgis


# Expone el puerto VNC
EXPOSE 5901
RUN touch /home/qgis/.Xresources && chown qgis:qgis /home/qgis/.Xresources

# Start Xvfb and x11vnc with dynamic resolution support
#CMD ["sh", "-c", "Xvfb :0 -screen 0 1920x1080x24 +extension RANDR & \
#          sleep 2 && \
#          x11vnc -display :0 -forever -passwdfile /home/qgis/.vnc/passwd -shared -rfbport 5901 -noxdamage -xrandr"]

CMD sh -c   "Xvfb :0 -screen 0 1920x1080x24 +extension RANDR & \
            sleep 2 && \
            export DISPLAY=:0 && \
            lxsession & \
            x11vnc -display :0 -forever -nopw -shared -rfbport 5901 -noxdamage -xrandr"          