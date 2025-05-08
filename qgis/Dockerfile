FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install basic tools and desktop dependencies
RUN apt-get update \
    && apt-get install -y  --no-install-recommends\
        xfce4-panel \
        xfce4-session \
        xfce4-settings \
        xfdesktop4 \
        xfce4-terminal \
        xfce4-appfinder \
        thunar \
        xfconf \
        xfwm4 \
        falkon \
        wmctrl \
        xrdp \
        dbus-x11 \
        xorg\
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
Architectures: amd64\n\
Components: main\n\
Signed-By: /etc/apt/keyrings/qgis-archive-keyring.gpg" \
> /etc/apt/sources.list.d/qgis.sources

# Install QGIS and GRASS plugin
RUN apt-get update \
    && apt-get install -y --no-install-recommends\
        qgis \
        qgis-plugin-grass \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -ms /bin/bash qgis \
    && echo "qgis:qgis" | chpasswd \
    && adduser qgis sudo

# Configure XRDP +XFCE
COPY startwm.sh /etc/xrdp/startwm.sh
RUN chmod +x /etc/xrdp/startwm.sh
COPY qgis.desktop /etc/xrdp/startwm.shnfig/autostart/qgis.desktop
RUN chmod +x /etc/xrdp/startwm.shnfig/autostart/qgis.desktop

# Directory to transfer files
RUN mkdir -p /tmp/transfer \
  && chmod 777 /tmp/transfer

# Ensure qgis is the owner of /home/qgis
RUN chown -R qgis:qgis /home/qgis

# Expose port for xrdp
EXPOSE 3389

# Execute command at image creation
CMD chown -R qgis:qgis /home/qgis  \
    && service dbus start \
    && service xrdp start \
    && tail -f /var/log/xrdp-sesman.log

