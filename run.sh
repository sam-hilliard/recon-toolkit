#!/usr/bin/bash

IMAGE_NAME="recon-toolkit"
CONTAINER_WORKDIR="/bounty"

# Docker exists
if ! command -v docker >/dev/null 2>&1; then
  echo "[!] Docker is not installed or not in PATH"
  exit 1
fi

# Parse args
INTERACTIVE=false

while getopts ":i" opt; do
  case $opt in
    i)
      INTERACTIVE=true
      ;;
    \?)
      echo "[!] Invalid option: -$OPTARG"
      echo "Usage: recon [-i] [directory]"
      exit 1
      ;;
  esac
done

shift $((OPTIND -1))

# Only accept <= 1 arg (optional directory arg)
if [[ $# -gt 1 ]]; then
  echo "[!] Usage: recon [-i] [directory]"
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

# Run
if $INTERACTIVE; then
  docker run --rm -it \
    --mount type=bind,target="$CONTAINER_WORKDIR",source="$TARGET_DIR" \
    "$IMAGE_NAME" \
    /bin/bash
else
  docker run --rm -it \
    --mount type=bind,target="$CONTAINER_WORKDIR",source="$TARGET_DIR" \
    "$IMAGE_NAME" \
    recon.sh
fi
