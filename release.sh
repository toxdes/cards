#!/usr/bin/env bash
# set -euxo pipefail
set -eu pipefail
source ./.env
# echo $GH_TOKEN
APP_VERSION=$(yq -r '.version' ./pubspec.yaml | sed -e 's/\+/_/')
# flutter build apk
RELEASE_NAME="cards-${APP_VERSION}"
TAG_NAME="internal-$APP_VERSION"
echo "[INFO] Tagging most recent commit with tag: $TAG_NAME"
git tag -a $TAG_NAME HEAD -m "release $APP_VERSION"
echo "[INFO] Generating source tar.gz"
git archive --format=tar.gz -o /tmp/cards.tar.gz --prefix=cards/ main
echo "[INFO] Building $RELEASE_NAME.apk"
flutter clean
flutter pub get
dart fix --apply
flutter build apk --flavor dev
flutter build apk --flavor prod
PROD_APK_PATH="./build/app/outputs/flutter-apk/app-prod-release.apk"
DEV_APK_PATH="./build/app/outputs/flutter-apk/app-dev-release.apk"

# create a new github release
echo "[INFO] Creating a new github release $RELEASE_NAME"
CREATE_RELEASE_RES=$(curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/toxdes/cards/releases \
  -d "{\"tag_name\":\"$TAG_NAME\",\"target_commitish\":\"main\",\"name\":\"$RELEASE_NAME\",\"body\":\"## Release Notes\n This is currently work in progress, more detailed release notes will be added later.\",\"draft\":false,\"prerelease\":false,\"generate_release_notes\":false}")
RELEASE_ID=$(echo $CREATE_RELEASE_RES | jq -r '.id')
echo "RELEASE ID: $RELEASE_ID"

# upload assets
echo "[INFO] Uploading Prod APK"
UPLOAD_URL="https://uploads.github.com/repos/toxdes/cards/releases/$RELEASE_ID/assets?name=$RELEASE_NAME.apk&label=$RELEASE_NAME.apk"
curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/octet-stream" \
  "$UPLOAD_URL" \
  --data-binary "@$PROD_APK_PATH"


echo "[INFO] Uploading Prod APK"
UPLOAD_URL="https://uploads.github.com/repos/toxdes/cards/releases/$RELEASE_ID/assets?name=$RELEASE_NAME-dev.apk&label=$RELEASE_NAME.apk"
curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/octet-stream" \
  "$UPLOAD_URL" \
  --data-binary "@$DEV_APK_PATH"

echo "[INFO] Uploading source tarball"
UPLOAD_URL="https://uploads.github.com/repos/toxdes/cards/releases/$RELEASE_ID/assets?name=cards.tar.gz&label=Source%20code%20(tarball)"
curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/octet-stream" \
  "$UPLOAD_URL" \
  --data-binary "@/tmp/cards.tar.gz"