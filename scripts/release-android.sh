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
echo "[INFO] Building $RELEASE_NAME.apk"
flutter clean
flutter pub get
dart fix --apply
flutter build apk --release --flavor dev --split-per-abi
flutter build apk --release --flavor prod --split-per-abi
DEV_APK_DIR="./build/app/outputs/apk/dev/release"
PROD_APK_DIR="./build/app/outputs/apk/prod/release"

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

# Upload file to GitHub release with progress bar
upload_asset() {
  local file_path=$1
  local asset_name=$2
  local asset_label=$3
  
  echo "[INFO] Uploading $asset_label"
  curl -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GH_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -H "Content-Type: application/octet-stream" \
    --progress-bar \
    "https://uploads.github.com/repos/toxdes/cards/releases/$RELEASE_ID/assets?name=$asset_name&label=$asset_label" \
    --data-binary "@$file_path"
  echo ""
}

# Upload prod APKs (arch-specific)
for apk in $PROD_APK_DIR/app-prod-*-release.apk; do
  [[ "$apk" =~ universal ]] && continue
  arch=$(basename "$apk" | sed -E 's/app-prod-(.+?)-release\.apk/\1/')
  upload_asset "$apk" "cards-${arch}-${APP_VERSION}.apk" "Prod - $arch"
done

# Upload prod universal APK
[[ -f "$PROD_APK_DIR/app-prod-universal-release.apk" ]] && \
  upload_asset "$PROD_APK_DIR/app-prod-universal-release.apk" "cards-universal-${APP_VERSION}.apk" "Prod - Universal"

# Upload dev APKs (arch-specific)
for apk in $DEV_APK_DIR/app-dev-*-release.apk; do
  [[ "$apk" =~ universal ]] && continue
  arch=$(basename "$apk" | sed -E 's/app-dev-(.+?)-release\.apk/\1/')
  upload_asset "$apk" "cards-dev-${arch}-${APP_VERSION}.apk" "Dev - $arch"
done

# Upload dev universal APK
[[ -f "$DEV_APK_DIR/app-dev-universal-release.apk" ]] && \
  upload_asset "$DEV_APK_DIR/app-dev-universal-release.apk" "cards-dev-universal-${APP_VERSION}.apk" "Dev - Universal"

echo "[INFO] Release complete!"