FROM ubuntu:24.04 

ARG QGIS_CHANNEL=stable   # Options: stable, ltr

ENV DEBIAN_FRONTEND=noninteractive

# Install basic tools and desktop dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    gnupg \
    wget \
    sudo \
    lsb-release \
    software-properties-common \
    fonts-open-sans \
    fonts-dejavu \
    fonts-liberation \
    fonts-freefont-ttf \
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
    notify-osd  

# Add QGIS GPG key
RUN mkdir -p /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/qgis-archive-keyring.gpg \
    https://download.qgis.org/downloads/qgis-archive-keyring.gpg

# Add QGIS .sources file
RUN echo "Types: deb deb-src\n\
URIs: https://qgis.org/debian\n\
Suites: $(lsb_release -c -s)\n\
Architectures: amd64\n\
Components: main\n\
Signed-By: /etc/apt/keyrings/qgis-archive-keyring.gpg" \
> /etc/apt/sources.list.d/qgis.sources

# Install QGIS and GRASS plugin
RUN apt-get update && apt-get install -y \
    qgis \
    qgis-plugin-grass 

# Create non-root user
RUN useradd -ms /bin/bash qgis && \
    echo "qgis:qgis" | chpasswd && \
    adduser qgis sudo && \
    mkdir -p /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    touch /home/qgis/.Xresources && \
    chown qgis:qgis /home/qgis/.Xresources

# Disable lxpolkit to avoid session warnings
RUN sed -i '/lxpolkit/d' /etc/xdg/lxsession/LXDE/autostart

# Copy startup script
COPY init.sh /home/qgis/init.sh
RUN chmod +x /home/qgis/init.sh && chown qgis:qgis /home/qgis/init.sh

USER qgis
ENV USER=qgis
WORKDIR /home/qgis

EXPOSE 5901

CMD ["./init.sh"]
