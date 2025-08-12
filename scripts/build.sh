#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/build.sh dev|prod
TARGET="${1:-dev}"          # dev or prod
HUB_USER="akashvb"
APP_NAME="devops-build"

if [[ "$TARGET" == "prod" ]]; then
  REPO="$HUB_USER/$APP_NAME-prod"
else
  REPO="$HUB_USER/$APP_NAME-dev"
fi

echo "Logging in to Docker Hub…"
docker login

TAG="$(date +%Y%m%d%H%M%S)"
echo "Building image: $REPO:$TAG"
docker build -t "$REPO:$TAG" .

echo "Pushing $REPO:$TAG"
docker push "$REPO:$TAG"

echo "Tagging and pushing latest"
docker tag "$REPO:$TAG" "$REPO:latest"
docker push "$REPO:latest"

echo "Done -> $REPO:$TAG (and latest)"

