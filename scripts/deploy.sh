#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/deploy.sh dev|prod
TARGET="${1:-dev}"
HUB_USER="akashvb"
APP_NAME="devops-build"

if [[ "$TARGET" == "prod" ]]; then
  REPO="$HUB_USER/$APP_NAME-prod"
else
  REPO="$HUB_USER/$APP_NAME-dev"
fi

# Point compose at the correct image
sed -i "s|^\\s*image:.*|    image: $REPO:latest|" docker-compose.yml

echo "Pulling latest image…"
docker compose pull

echo "Starting with docker compose…"
docker compose up -d

docker compose ps

