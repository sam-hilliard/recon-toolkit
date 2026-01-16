#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="recon-toolkit"
CONTAINER_WORKDIR="/bounty"
SCRIPT_PATH="/usr/local/bin/recon.sh"

# Docker exists
if ! command -v docker >/dev/null 2>&1; then
  echo "[!] Docker is not installed or not in PATH"
  echo "    Install Docker first: https://docs.docker.com/get-docker/"
  exit 1
fi

# Only accept <= 1 arg (optional directory arg)
if [[ $# -gt 1 ]]; then
  echo "[!] Usage: recon [directory]"
  exit 1
fi

TARGET_DIR="${1:-$PWD}"

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "[!] Directory does not exist: $TARGET_DIR"
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Need a built image to run
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  echo "[!] Docker image '$IMAGE_NAME' not found."
  echo
  echo "    Build it first:"
  echo "      docker build -t $IMAGE_NAME ."
  echo
  exit 1
fi

# Run recon script
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$TARGET_DIR:$CONTAINER_WORKDIR" \
  -w "$CONTAINER_WORKDIR" \
  "$IMAGE_NAME" \
  "$SCRIPT_PATH"
