# QGIS Remote Desktop Container

A Docker container to run **QGIS** remotely with a lightweight **XFCE4 desktop**, ready to be used behind **Apache Guacamole** or any XRDP-compatible client.

## ✨ Features

- Based on official QGIS **LTR or Latest** packages *(version not guaranteed to remain stable as channels evolve)*  
- Built on top of **Ubuntu 22.04 LTS** image
- Includes **XFCE4** for a minimal but functional remote desktop
- Accessible via **XRDP** (port `3389` exposed by default)

## 🛠️ Usage

### Build

```bash
# Inside ./qgis directory
./build_image.sh --docker-user <Docker user name>
```

### Required Environment Variables

When running the container, you must define:

- `USER_NAME` – The default user created inside the container
- `USER_PASSWORD` – Password for remote login (via XRDP)

Example `docker-compose.yml` snippet:

```yaml
services:
  qgis:
    image: rd-qgis-3_40_6:1
    container_name: qgis
    ports:
      - "3389:3389"
    restart: unless-stopped
    environment:
      - USER_NAME=youruser
      - USER_PASSWORD=yourpassword
    volumes:
      - ./data/qgis-projects:/home/youruser/qgis-projects
      - ./data/qgis-config/.local/share/QGIS:/home/youruser/.local/share/QGIS
      - ./data/qgis-config/.config/QGIS:/home/youruser/.config/QGIS
```

### Connect

Use any RDP client (or Apache Guacamole) to connect to:

```
host: [container_ip_or_hostname]
port: 3389
username: $USER_NAME
password: $USER_PASSWORD
```

## 📌 Notes

- This image tracks **ubuntu-ltr** or **ubuntu** QGIS channels — versions will float as the channels are updated upstream.
- This container is best suited for integration with **remote desktop gateways** (like Guacamole) or lightweight RDP clients.
- XFCE is configured for basic usage and optimized for fast startup.

```
