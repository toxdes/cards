#!/usr/bin/env bash
set -eu pipefail

BUMP_TYPE="${2:-patch}"

if [[ "$BUMP_TYPE" != "major" && "$BUMP_TYPE" != "minor" && "$BUMP_TYPE" != "patch" ]]; then
  echo "Error: Invalid bump type. Must be 'major', 'minor', or 'patch'."
  exit 1
fi

PUBSPEC_FILE="./pubspec.yaml"

if [[ ! -f "$PUBSPEC_FILE" ]]; then
  echo "Error: pubspec.yaml not found at $PUBSPEC_FILE"
  exit 1
fi

CURRENT_VERSION=$(yq -r '.version' "$PUBSPEC_FILE")
VERSION_PART=$(echo "$CURRENT_VERSION" | sed 's/+.*//')
VERSION_CODE=$(echo "$CURRENT_VERSION" | sed 's/.*+//')

IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION_PART"

case "$BUMP_TYPE" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
esac

VERSION_CODE=$((VERSION_CODE + 1))
NEW_VERSION="$MAJOR.$MINOR.$PATCH+$VERSION_CODE"

yq -i -y ".version = \"$NEW_VERSION\"" "$PUBSPEC_FILE"

git add pubspec.yaml

case "$BUMP_TYPE" in
  major)
    git commit -m "chore: bump major version"
    ;;
  minor)
    git commit -m "chore: bump minor version"
    ;;
  patch)
    git commit -m "chore: bump version"
    ;;
esac
