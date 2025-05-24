#!/bin/bash
# Set up a containerized QGIS remote desktop project
#
# Create .env file
cat > .env <<EOF
# QGIS and Guacamole user credentials
USER_NAME=
USER_PASSWORD=

# Guacamole admin user credentials 
GUACADMIN_USER=
GUACADMIN_PASS=

# MySQL credentials
MYSQL_ROOT_PASSWORD=
MYSQL_USER=
MYSQL_PASSWORD=
EOF

# Create docker-compose.yml file
cat > docker-compose.yml <<EOF
services:
  qgis:
    image: rd-qgis-3_40_6:1.0.0
    container_name: qgis
    restart: unless-stopped
    volumes:
      - ./projects:/home/\${USER_NAME}/projects
      - ./qgis_config/.local/share/QGIS:/home/\${USER_NAME}/.local
      - ./qgis_config/.config/QGIS:/home/\${USER_NAME}/.config
      - thinclient_data:/home/\${USER_NAME}/share
    environment:
      - USER_NAME=\${USER_NAME}
      - USER_PASSWORD=\${USER_PASSWORD}
    networks:
      - internal_net

  guacd:
    image: guacamole/guacd:1.5.5
    container_name: guacd
    platform: linux/amd64
    volumes:
      - thinclient_data:/tmp/share
    restart: unless-stopped
    networks:
      - internal_net

  mysql:
    image: rd-mysql-8_4_5:1.0.0
    container_name: mysql
    restart: unless-stopped
    environment:
      - APP_HOSTNAME=qgis
      - APP_HOSTPORT=3389
      - CONNECTION_NAME=QGIS Connection
      - MYSQL_DATABASE=guacamole_db
      - MYSQL_ROOT_PASSWORD=\${MYSQL_ROOT_PASSWORD}
      - MYSQL_USER=\${MYSQL_USER}
      - MYSQL_PASSWORD=\${MYSQL_PASSWORD}
      - GUACADMIN_USER=\${GUACADMIN_USER}
      - GUACADMIN_PASS=\${GUACADMIN_PASS}
      - GUAC_USER=\${USER_NAME}
      - GUAC_PASS=\${USER_PASSWORD}
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - internal_net

  guacamole:
    image: rd-guacamole-1_5_5:1.0.0
    container_name: guacamole
    platform: linux/amd64
    ports:
      - "8080:8080"
    environment:
      - GUACD_HOSTNAME=guacd
      - MYSQL_HOSTNAME=mysql
      - MYSQL_DATABASE=guacamole_db
      - MYSQL_USER=\${MYSQL_USER}
      - MYSQL_PASSWORD=\${MYSQL_PASSWORD}
    depends_on:
      - guacd
      - mysql
    networks:
      - internal_net

networks:
  internal_net:
    driver: bridge

volumes:
  thinclient_data:
  mysql_data:
EOF

# Create required directories
mkdir -p projects
mkdir -p qgis_config

# Create .gitignore file
cat > .gitignore <<EOF
.env
.DS_Store
projects
qgis-config
EOF

echo "QGIS project initialized.."
echo "Please customize .env and docker-compose.yml"