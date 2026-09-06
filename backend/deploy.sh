#!/usr/bin/env bash
# Deploy the Drive sync HTTP function to Google Cloud.
# Prerequisites: gcloud CLI logged in, Drive folder shared with the SA.
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-silent-oasis-507819-k4}"
REGION="${REGION:-europe-west1}"
FUNCTION_NAME="${FUNCTION_NAME:-syncUsage}"
API_KEY="${DRIVE_SYNC_API_KEY:-app_usage_sync_7f3a9c2e1b84d0f6}"
FOLDER_ID="${DRIVE_FOLDER_ID:-1bwuJe5xiUYW7PxqnaCJGmXngvpTt4ygz}"
SA_EMAIL="app-usage-drive-uploader@${PROJECT_ID}.iam.gserviceaccount.com"
ROOT="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -f "$ROOT/secrets/service-account.json" ]]; then
  echo "Missing $ROOT/secrets/service-account.json"
  exit 1
fi

gcloud config set project "$PROJECT_ID"
gcloud services enable cloudfunctions.googleapis.com run.googleapis.com cloudbuild.googleapis.com

gcloud functions deploy "$FUNCTION_NAME" \
  --gen2 \
  --runtime=nodejs20 \
  --region="$REGION" \
  --source="$ROOT" \
  --entry-point=syncUsage \
  --trigger-http \
  --allow-unauthenticated \
  --service-account="$SA_EMAIL" \
  --set-env-vars="DRIVE_FOLDER_ID=${FOLDER_ID},DRIVE_SYNC_API_KEY=${API_KEY}"

echo
echo "Done. Copy the HTTPS URL above into Flutter:"
echo "  flutter run --dart-define=DRIVE_SYNC_URL=https://REGION-PROJECT.cloudfunctions.net/${FUNCTION_NAME}"
echo "  --dart-define=DRIVE_SYNC_API_KEY=${API_KEY}"
