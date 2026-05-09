#!/bin/bash
# Requires: docker login already completed before running this script.
# Use --no-push to build locally (single-platform, loaded into local daemon).
set -e

# ── Configuration ──────────────────────────────────────────────────────────────
NAMESPACE="jjserver"

GUACAMOLE_VERSION="1.5.5"
MYSQL_VERSION="8.4.5"
QGIS_VERSION="3.40.6"
QGIS_CHANNEL="ubuntu-ltr"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

GUAC_IMAGE="${NAMESPACE}/rd-guacamole-$(echo "$GUACAMOLE_VERSION" | tr '.' '_')"
MYSQL_IMAGE="${NAMESPACE}/rd-mysql-$(echo "$MYSQL_VERSION" | tr '.' '_')"
QGIS_IMAGE="${NAMESPACE}/rd-qgis-$(echo "$QGIS_VERSION" | tr '.' '_')"

# ── Flags ──────────────────────────────────────────────────────────────────────
BUILD_GUAC=false
BUILD_MYSQL=false
BUILD_QGIS=false
DRY_RUN=false
NO_PUSH=false
YES=false

# ── Tag helpers ────────────────────────────────────────────────────────────────

# Fetch the highest semver tag for a Docker Hub image (ignores 'latest').
get_latest_tag() {
  local image="$1"
  curl -sf "https://hub.docker.com/v2/repositories/${image}/tags?page_size=100" \
    | python3 -c "
import sys, json, re
data = json.load(sys.stdin)
tags = [r['name'] for r in data.get('results', []) if re.match(r'^\d+\.\d+\.\d+$', r['name'])]
tags.sort(key=lambda v: list(map(int, v.split('.'))))
print(tags[-1] if tags else '')
" 2>/dev/null || echo ""
}

# Bump the minor component: 1.2.3 -> 1.3.0
bump_minor() {
  local major minor patch
  IFS='.' read -r major minor patch <<< "$1"
  echo "${major}.$((minor + 1)).0"
}

# Return the next tag for an image (1.0.0 if no prior release exists).
next_tag() {
  local image="$1"
  local latest
  latest=$(get_latest_tag "$image")
  if [[ -z "$latest" ]]; then
    echo "1.0.0"
  else
    bump_minor "$latest"
  fi
}

# ── Buildx setup ───────────────────────────────────────────────────────────────

ensure_buildx() {
  if ! docker buildx version &>/dev/null; then
    echo "[ERROR] docker buildx is not available. Please install Docker Buildx."
    exit 1
  fi
  if ! docker buildx inspect multiarch-builder &>/dev/null; then
    echo "[INFO] Creating buildx builder 'multiarch-builder'"
    docker buildx create --name multiarch-builder --use
  else
    docker buildx use multiarch-builder
  fi
  docker buildx inspect --bootstrap
}

# ── Shared build helper ────────────────────────────────────────────────────────
# Usage: run_buildx <image> <tag> [--build-arg KEY=VAL ...] [--label KEY=VAL ...]
# Appends --push (multiarch) or --load (local) depending on NO_PUSH flag.
run_buildx() {
  local image="$1" tag="$2"
  shift 2

  if $NO_PUSH; then
    docker buildx build \
      --load \
      "$@" \
      -t "${image}:${tag}" \
      -t "${image}:latest" \
      .
    echo "[INFO] Built locally (not pushed): ${image}:${tag} and ${image}:latest"
  else
    docker buildx build \
      --platform linux/amd64,linux/arm64 \
      "$@" \
      -t "${image}:${tag}" \
      -t "${image}:latest" \
      --push \
      .
    echo "[INFO] Pushed: ${image}:${tag} and ${image}:latest"
  fi
}

# ── Image builders ─────────────────────────────────────────────────────────────

build_guacamole() {
  local tag="$1"
  echo ""
  echo "[INFO] === Guacamole: ${GUAC_IMAGE}:${tag} ==="
  $DRY_RUN && echo "[DRY-RUN] Would build ${GUAC_IMAGE}:${tag}" && return

  cd "${SCRIPT_DIR}/guacamole"
  echo "[INFO] Packing branding..."
  ./pack_branding.sh

  run_buildx "${GUAC_IMAGE}" "${tag}" \
    --build-arg GUACAMOLE_VERSION="${GUACAMOLE_VERSION}" \
    --label org.opencontainers.image.title="Guacamole frontend with branding" \
    --label org.opencontainers.image.version="${tag}" \
    --label org.opencontainers.image.created="${BUILD_DATE}" \
    --label org.opencontainers.image.description="Guacamole frontend with branding" \
    --label org.opencontainers.image.licenses="MIT" \
    --label org.opencontainers.image.source="https://github.com/johnaponte/docker_qgis/tree/main/guacamole" \
    --label org.opencontainers.image.documentation="https://github.com/johnaponte/docker_qgis/blob/main/guacamole/README.md"

  cd "${SCRIPT_DIR}"
}

build_mysql() {
  local tag="$1"
  echo ""
  echo "[INFO] === MySQL: ${MYSQL_IMAGE}:${tag} ==="
  $DRY_RUN && echo "[DRY-RUN] Would build ${MYSQL_IMAGE}:${tag}" && return

  cd "${SCRIPT_DIR}/mysql"

  run_buildx "${MYSQL_IMAGE}" "${tag}" \
    --build-arg MYSQL_VERSION="${MYSQL_VERSION}" \
    --label org.opencontainers.image.title="MySQL backend for Guacamole and XRDP connections" \
    --label org.opencontainers.image.version="${tag}" \
    --label org.opencontainers.image.created="${BUILD_DATE}" \
    --label org.opencontainers.image.description="MySQL backend for Guacamole authentication and xrdp connection" \
    --label org.opencontainers.image.licenses="MIT" \
    --label org.opencontainers.image.source="https://github.com/johnaponte/docker_qgis/tree/main/mysql" \
    --label org.opencontainers.image.documentation="https://github.com/johnaponte/docker_qgis/blob/main/mysql/README.md"

  cd "${SCRIPT_DIR}"
}

build_qgis() {
  local tag="$1"
  echo ""
  echo "[INFO] === QGIS: ${QGIS_IMAGE}:${tag} ==="
  $DRY_RUN && echo "[DRY-RUN] Would build ${QGIS_IMAGE}:${tag}" && return

  cd "${SCRIPT_DIR}/qgis"

  run_buildx "${QGIS_IMAGE}" "${tag}" \
    --build-arg QGIS_CHANNEL="${QGIS_CHANNEL}" \
    --label org.opencontainers.image.title="QGIS ${QGIS_VERSION} with xrdp" \
    --label org.opencontainers.image.version="${tag}" \
    --label org.opencontainers.image.created="${BUILD_DATE}" \
    --label org.opencontainers.image.description="QGIS container with XRDP, based on channel ${QGIS_CHANNEL}" \
    --label org.opencontainers.image.licenses="MIT" \
    --label org.opencontainers.image.source="https://github.com/johnaponte/docker_qgis/tree/main/qgis" \
    --label org.opencontainers.image.documentation="https://github.com/johnaponte/docker_qgis/blob/main/qgis/README.md"

  cd "${SCRIPT_DIR}"
}

# ── CLI parsing ────────────────────────────────────────────────────────────────

usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Build and release Docker images to Docker Hub with an auto-incremented minor tag.
The user must already be logged in to Docker Hub (docker login) before running.
If no image flag is given, all three images are built.

Options:
  --guacamole   Build/release only the Guacamole image
  --mysql       Build/release only the MySQL image
  --qgis        Build/release only the QGIS image
  --no-push     Build locally (single-platform, loaded into local daemon) without pushing
  --dry-run     Show what would be done without building or pushing
  --yes, -y     Skip confirmation prompt
  -h, --help    Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --guacamole) BUILD_GUAC=true ;;
    --mysql)     BUILD_MYSQL=true ;;
    --qgis)      BUILD_QGIS=true ;;
    --no-push)   NO_PUSH=true ;;
    --dry-run)   DRY_RUN=true ;;
    --yes|-y)    YES=true ;;
    -h|--help)   usage; exit 0 ;;
    *) echo "[ERROR] Unknown argument: $1"; usage; exit 1 ;;
  esac
  shift
done

# Default: build all if no specific image was selected
if ! $BUILD_GUAC && ! $BUILD_MYSQL && ! $BUILD_QGIS; then
  BUILD_GUAC=true
  BUILD_MYSQL=true
  BUILD_QGIS=true
fi

# ── Main ───────────────────────────────────────────────────────────────────────

echo "[INFO] Fetching latest tags from Docker Hub..."

GUAC_TAG=""
MYSQL_TAG=""
QGIS_TAG=""

$BUILD_GUAC  && GUAC_TAG=$(next_tag "$GUAC_IMAGE")
$BUILD_MYSQL && MYSQL_TAG=$(next_tag "$MYSQL_IMAGE")
$BUILD_QGIS  && QGIS_TAG=$(next_tag "$QGIS_IMAGE")

echo ""
echo "[INFO] Build plan:"
$BUILD_GUAC  && echo "  Guacamole : ${GUAC_IMAGE}:${GUAC_TAG}"
$BUILD_MYSQL && echo "  MySQL     : ${MYSQL_IMAGE}:${MYSQL_TAG}"
$BUILD_QGIS  && echo "  QGIS      : ${QGIS_IMAGE}:${QGIS_TAG}"
$NO_PUSH     && echo "" && echo "[INFO] --no-push: images will be built locally, not pushed to Docker Hub."
$DRY_RUN     && echo "" && echo "[INFO] --dry-run: nothing will be built or pushed."
echo ""

if ! $YES && ! $DRY_RUN; then
  $NO_PUSH \
    && read -r -p "Proceed with local build (no push)? [y/N] " confirm \
    || read -r -p "Proceed with build and push? [y/N] " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "[INFO] Aborted."
    exit 0
  fi
fi

$DRY_RUN || ensure_buildx

$BUILD_GUAC  && build_guacamole "$GUAC_TAG"
$BUILD_MYSQL && build_mysql     "$MYSQL_TAG"
$BUILD_QGIS  && build_qgis      "$QGIS_TAG"

echo ""
echo "[INFO] Done:"
$BUILD_GUAC  && echo "  ${GUAC_IMAGE}:${GUAC_TAG}"
$BUILD_MYSQL && echo "  ${MYSQL_IMAGE}:${MYSQL_TAG}"
$BUILD_QGIS  && echo "  ${QGIS_IMAGE}:${QGIS_TAG}"
