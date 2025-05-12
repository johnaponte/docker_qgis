#!/bin/bash

# Exit on any error
set -e

# Configuration

# QGIS channel: 'ubuntu-ltr' = long term release. 'ubuntu' = latest stable
# As of May 2025, ubuntu-ltr = QGIS 3.40.6 — 
# confirm at: https://qgis.org/en/site/forusers/alldownloads.html
QGIS_CHANNEL="ubuntu-ltr"
QGIS_VERSION="3.40.6"
TAG="1.0.0"

# Derived values
QGIS_VERSION_TAG=$(echo "$QGIS_VERSION" | tr '.' '_')
IMAGE_BASE="rd-qgis-${QGIS_VERSION_TAG}"
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
  --build-arg QGIS_CHANNEL="${QGIS_CHANNEL}" \
  --label org.opencontainers.image.title="QGIS ${QGIS_VERSION} with xrdp" \
  --label org.opencontainers.image.version="${TAG}" \
  --label org.opencontainers.image.created="${CREATED_DATE}" \
  --label org.opencontainers.image.description="QGIS container with XRDP, based on channel ${QGIS_CHANNEL}" \
  --label org.opencontainers.image.licenses="MIT" \
  --label org.opencontainers.image.source="https://github.com/johnaponte/docker_qgis/tree/main/qgis" \
  --label org.opencontainers.image.documentation="https://github.com/johnaponte/docker_qgis/blob/main/qgis/README.md" \
  -t "${IMAGE_NAME}:${TAG}" \
  .

# Also tag as latest
docker tag "${IMAGE_NAME}:${TAG}" "${IMAGE_NAME}:latest"

echo "[INFO] Build complete:"
echo " - ${IMAGE_NAME}:${TAG}"
echo " - ${IMAGE_NAME}:latest"

