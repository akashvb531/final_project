set -euo pipefail
TARGET="${1:-dev}"                     # dev or prod
HUB_USER="${DOCKERHUB_USER:-akashvb}"  # allow CI to override
APP_NAME="devops-build"

if [[ "$TARGET" == "prod" ]]; then
  IMAGE="$HUB_USER/$APP_NAME-prod:latest"
else
  IMAGE="$HUB_USER/$APP_NAME-dev:latest"
fi
export IMAGE

# If CI provides creds, login before pulling (needed for private prod repo)
if [[ -n "${DOCKERHUB_PASS:-}" ]]; then
  echo "$DOCKERHUB_PASS" | docker login -u "${DOCKERHUB_USER:-$HUB_USER}" --password-stdin
fi

echo "Starting with docker compose…"
docker compose -p devops-build pull
docker compose -p devops-build up -d
docker compose -p devops-build ps
