#!/usr/bin/env bash
source ./.env

APP_VERSION=$(yq -r '.version' ./pubspec.yaml | sed -e 's/\+/_/')
TAG_NAME="internal-$APP_VERSION"
RELEASE_RES=$(curl -L \
  -X GET \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
   "https://api.github.com/repos/toxdes/cards/releases/tags/$TAG_NAME"
)
RELEASE_ID=$(echo $RELEASE_RES | jq -r '.id')
LINUX_RELEASE_NAME=$(yq -r '.version' ./pubspec.yaml)
dart pub global activate flutter_distributor
~/.pub-cache/bin/flutter_distributor release --name=dev --jobs=release-linux-deb
UPLOAD_URL="https://uploads.github.com/repos/toxdes/cards/releases/$RELEASE_ID/assets?name=cards-$APP_VERSION.deb&label=cards-$APP_VERSION.deb"
DEB_PATH="./dist/$LINUX_RELEASE_NAME/cards-$LINUX_RELEASE_NAME-linux.deb"
curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/octet-stream" \
  "$UPLOAD_URL" \
  --data-binary "@$DEB_PATH"