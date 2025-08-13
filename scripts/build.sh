set -euo pipefail
TARGET="${1:-dev}"                     # dev or prod
HUB_USER="${DOCKERHUB_USER:-akashvb}"  # CI provides DOCKERHUB_USER/DOCKERHUB_PASS
APP_NAME="devops-build"

if [[ "$TARGET" == "prod" ]]; then
  REPO="$HUB_USER/$APP_NAME-prod"
else
  REPO="$HUB_USER/$APP_NAME-dev"
fi

# Non-interactive login in CI; interactive locally
if [[ -n "${DOCKERHUB_PASS:-}" ]]; then
  echo "$DOCKERHUB_PASS" | docker login -u "${DOCKERHUB_USER:-$HUB_USER}" --password-stdin
else
  docker login -u "$HUB_USER"
fi

TAG="$(date +%Y%m%d%H%M%S)"
echo "Building image: $REPO:$TAG"
docker build --pull -t "$REPO:$TAG" .

echo "Pushing $REPO:$TAG"
docker push "$REPO:$TAG"

echo "Tagging latest"
docker tag "$REPO:$TAG" "$REPO:latest"
docker push "$REPO:latest"

echo "Pushed $REPO:$TAG and :latest"
