FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install basic tools and desktop dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        xfce4-panel \
        xfce4-session \
        xfce4-settings \
        xfdesktop4 \
        xfce4-terminal \
        xfce4-appfinder \
        xfce4-notifyd \
        xfce4-pulseaudio-plugin \
        xfce4-power-manager \
        thunar \
        xfconf \
        xfwm4 \
        falkon \
        wmctrl \
        xrdp \
        at-spi2-core \
        adwaita-icon-theme \
        dbus-x11 \
        xorg \
        xorgxrdp \
        fonts-open-sans \
        fonts-dejavu \
        fonts-liberation \
        fonts-freefont-ttf \
        software-properties-common \
        ca-certificates \
        sudo \
        gnupg \
        wget \
        lsb-release \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG QGIS_CHANNEL

# Add QGIS GPG key
RUN mkdir -p /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/qgis-archive-keyring.gpg \
        https://download.qgis.org/downloads/qgis-archive-keyring.gpg

# Add QGIS .sources file using the selected QGIS_CHANNEL
RUN echo "Types: deb deb-src\n\
URIs: https://qgis.org/${QGIS_CHANNEL}\n\
Suites: $(lsb_release -c -s)\n\
Components: main\n\
Signed-By: /etc/apt/keyrings/qgis-archive-keyring.gpg" \
> /etc/apt/sources.list.d/qgis.sources

# Install QGIS and GRASS plugin
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        qgis \
        qgis-plugin-grass \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure XRDP and XFCE
COPY startwm.sh /etc/xrdp/startwm.sh
COPY sesman.ini /etc/xrdp/sesman.ini
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /etc/xrdp/startwm.sh /entrypoint.sh

# Expose XRDP port
EXPOSE 3389

# Run entrypoint script on container start
CMD ["/entrypoint.sh"]
