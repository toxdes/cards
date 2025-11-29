#!/usr/bin/env python3
"""Build and release Android APKs to GitHub."""

import re
from pathlib import Path

from lib import Config, GitHub, Shell, Version, log_error, log_info


def build_apks() -> tuple[Path, Path]:
    """Build APKs and return (dev_dir, prod_dir)."""
    log_info("Building APKs")
    Shell.run("flutter clean")
    Shell.run("flutter pub get")
    Shell.run("dart fix --apply")
    Shell.run("flutter build apk --release --flavor dev --split-per-abi")
    Shell.run("flutter build apk --release --flavor prod --split-per-abi")

    return (
        Path("./build/app/outputs/apk/dev/release"),
        Path("./build/app/outputs/apk/prod/release"),
    )


def upload_apks(
    github: GitHub, release_id: int, dev_dir: Path, prod_dir: Path, version: str
) -> None:
    """Upload all APKs to release."""
    # Upload prod APKs (arch-specific)
    for apk in sorted(prod_dir.glob("app-prod-*-release.apk")):
        if "universal" in apk.name:
            continue

        match = re.search(r"app-prod-(.+?)-release\.apk", apk.name)
        if match:
            arch = match.group(1)
            asset_name = f"cards-{arch}-{version}.apk"
            github.upload(release_id, str(apk), asset_name, asset_name)

    # Upload prod universal APK
    prod_universal = prod_dir / "app-prod-universal-release.apk"
    if prod_universal.exists():
        asset_name = f"cards-universal-{version}.apk"
        github.upload(release_id, str(prod_universal), asset_name, asset_name)

    # Upload dev APKs (arch-specific)
    for apk in sorted(dev_dir.glob("app-dev-*-release.apk")):
        if "universal" in apk.name:
            continue

        match = re.search(r"app-dev-(.+?)-release\.apk", apk.name)
        if match:
            arch = match.group(1)
            asset_name = f"dev-cards-{arch}-{version}.apk"
            github.upload(release_id, str(apk), asset_name, asset_name)

    # Upload dev universal APK
    dev_universal = dev_dir / "app-dev-universal-release.apk"
    if dev_universal.exists():
        asset_name = f"dev-cards-universal-{version}.apk"
        github.upload(release_id, str(dev_universal), asset_name, asset_name)


def main() -> None:
    """Build and upload Android APKs to existing release."""
    try:
        config = Config()
        github = GitHub(config.gh_token)

        version_fmt = Version.formatted()
        tag = f"internal-{version_fmt}"

        # Get release ID from tag
        log_info(f"Getting release ID for tag: {tag}")
        release_id = github.get_release_id(tag)
        print(f"RELEASE ID: {release_id}")

        # Build APKs
        log_info("Building APKs")
        dev_dir, prod_dir = build_apks()

        # Upload APKs
        upload_apks(github, release_id, dev_dir, prod_dir, version_fmt)

        log_info("release_android: SUCCESS")
    except Exception as e:
        log_error(str(e))


if __name__ == "__main__":
    main()
