#!/bin/bash

if [[ -f "$(dirname "$0")/build_image.env" ]]; then
  source "$(dirname "$0")/build_image.env"
else
  echo "[ERROR] build_image.env not found in script directory."
  exit 1
fi

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

IMAGE_NAME="${NAMESPACE_TO}/${IMAGE_BASE}"

# Ensure docker buildx is available and initialized
if ! docker buildx version &> /dev/null; then
  echo "[ERROR] docker buildx is not available. Please ensure Docker Buildx is installed and enabled."
  exit 1
fi

if ! docker buildx inspect multiarch-builder &> /dev/null; then
  echo "[INFO] Creating and bootstrapping buildx builder 'multiarch-builder'"
  docker buildx create --name multiarch-builder --use
  docker buildx inspect --bootstrap
else
  docker buildx use multiarch-builder
  docker buildx inspect --bootstrap
fi

echo "[INFO] Building Docker image: ${IMAGE_NAME}:${TAG}"
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg MYSQL_VERSION="${MYSQL_VERSION}" \
  --label org.opencontainers.image.title="MySQL backend for Guacamole and XRDP connections" \
  --label org.opencontainers.image.version="${TAG}" \
  --label org.opencontainers.image.created="${BUILD_DATE}" \
  --label org.opencontainers.image.description="MySQL backed for Guacamole Authetication and xrdp connection" \
  --label org.opencontainers.image.licenses="MIT" \
  --label org.opencontainers.image.source="https://github.com/johnaponte/docker_qgis/tree/main/qgismysql" \
  --label org.opencontainers.image.documentation="https://github.com/johnaponte/docker_qgis/blob/main/mysql/README.md" \
  -t "${IMAGE_NAME}:${TAG}" \
  -t "${IMAGE_NAME}:latest" \
  --push \
  .

echo "[INFO] Build and push complete:"
echo " - ${IMAGE_NAME}:${TAG}"
echo " - ${IMAGE_NAME}:latest"
