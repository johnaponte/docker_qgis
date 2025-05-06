FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install basic tools and desktop dependencies
RUN apt-get update \
    && apt-get install -y \
        xrdp \
        xfce4 \
        dbus-x11 \
        x11-xserver-utils \
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
        x11-utils \
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
    && adduser qgis sudo \
    && mkdir -p /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix \
    && touch /home/qgis/.Xresources \
    && chown qgis:qgis /home/qgis/.Xresources

# Prepare the session
COPY .xsession /home/qgis/.xsession
RUN chown qgis:qgis /home/qgis/.xsession

# Shared drive symlink to transfer files with guacamole
RUN ln -s /drive/transfer /home/qgis/transfer

# Expose port for xrdp
EXPOSE 3389

# Execute command at image creation
CMD service dbus start \
    && service xrdp start \
    && tail -f /var/log/xrdp-sesman.log

