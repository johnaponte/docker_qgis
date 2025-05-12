#!/bin/bash

# Exit on any error
set -e

# Configuration: 
# Ensure MySQL version continainer
MYSQL_VERSION="8.4.5"
TAG="1.0.0"

# Derived values
MYSQL_VERSION_TAG=$(echo "$MYSQL_VERSION" | tr '.' '_')
IMAGE_BASE="rd-mysql-${MYSQL_VERSION_TAG}"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Optional Docker user
DOCKER_USER=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --docker-user)
      DOCKER_USER="$2"
      shift 2
      ;;
    *)
      echo "[ERROR] Unknown argument: $1"
      echo "Usage: $0 [--docker-user <username>]"
      exit 1
      ;;
  esac
done

# Compose full image name
if [[ -n "$DOCKER_USER" ]]; then
  IMAGE_NAME="${DOCKER_USER}/${IMAGE_BASE}"
else
  IMAGE_NAME="${IMAGE_BASE}"
fi

# Build image
echo "[INFO] Building Docker image: ${IMAGE_NAME}:${TAG}"
docker build \
  --build-arg MYSQL_VERSION="${MYSQL_VERSION}" \
  --label org.opencontainers.image.title="MySQL backend for Guacamole and XRDP connections" \
  --label org.opencontainers.image.version="${TAG}" \
  --label org.opencontainers.image.created="${CREATED_DATE}" \
  --label org.opencontainers.image.description="MySQL backed for Guacamole Authetication and xrdp connection" \
  --label org.opencontainers.image.licenses="MIT" \
  --label org.opencontainers.image.source="https://github.com/johnaponte/docker_qgis/tree/main/qgismysql" \
  --label org.opencontainers.image.documentation="https://github.com/johnaponte/docker_qgis/blob/main/mysql/README.md" \
  -t "${IMAGE_NAME}:${TAG}" \
  .

# Also tag as latest
docker tag "${IMAGE_NAME}:${TAG}" "${IMAGE_NAME}:latest"

echo "[INFO] Build complete:"
echo " - ${IMAGE_NAME}:${TAG}"
echo " - ${IMAGE_NAME}:latest"

