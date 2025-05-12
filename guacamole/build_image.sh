#!/bin/bash

# Exit on any error
set -e

# Configuration: 
# Ensure GUACAMOLE VERSION version continainer
GUACAMOLE_VERSION="1.5.5"
TAG="1.0.0"

# Derived values
GUACAMOLE_VERSION_TAG=$(echo "$GUACAMOLE_VERSION" | tr '.' '_')
IMAGE_BASE="rd-guacamole-${GUACAMOLE_VERSION_TAG}"
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
# Pack branding in a jar file
echo "[INFO] Packing branding .."
./pack_branding.sh

# Compose full image name
if [[ -n "$DOCKER_USER" ]]; then
  IMAGE_NAME="${DOCKER_USER}/${IMAGE_BASE}"
else
  IMAGE_NAME="${IMAGE_BASE}"
fi

# Build image
echo "[INFO] Building Docker image: ${IMAGE_NAME}:${TAG}"
docker build \
  --build-arg GUACAMOLE_VERSION="${GUACAMOLE_VERSION}" \
  --label org.opencontainers.image.title="Guacamole frontend with branding" \
  --label org.opencontainers.image.version="${TAG}" \
  --label org.opencontainers.image.created="${CREATED_DATE}" \
  --label org.opencontainers.image.description="Guacamole frontend with branding" \
  --label org.opencontainers.image.licenses="MIT" \
  --label org.opencontainers.image.source="https://github.com/johnaponte/docker_qgis/tree/main/guacamole" \
  --label org.opencontainers.image.documentation="https://github.com/johnaponte/docker_qgis/blob/main/guacamole/README.md" \
  -t "${IMAGE_NAME}:${TAG}" \
  .

# Also tag as latest
docker tag "${IMAGE_NAME}:${TAG}" "${IMAGE_NAME}:latest"

echo "[INFO] Build complete:"
echo " - ${IMAGE_NAME}:${TAG}"
echo " - ${IMAGE_NAME}:latest"

