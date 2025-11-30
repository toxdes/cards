#!/usr/bin/env python3
"""Build and release Linux packages to GitHub."""

from pathlib import Path

from lib import Config, GitHub, Shell, Version, log_error, log_info


def main() -> None:
    """Build and upload Linux packages to existing release."""
    try:
        config = Config()
        github = GitHub(config.gh_token)

        version_fmt = Version.formatted()
        version_raw = Version.raw()
        tag = f"internal-{version_fmt}"

        # Get release ID from tag
        log_info(f"Getting release ID for tag: {tag}")
        release_id = github.get_release_id(tag)
        print(f"RELEASE ID: {release_id}")

        # Build Linux releases
        log_info("Building Linux releases")
        Shell.run("dart pub global activate fastforge")
        Shell.run(
            "~/.pub-cache/bin/fastforge release "
            "--name=dev --jobs=release-linux-deb,release-linux-appimage"
        )

        # Upload DEB
        deb_path = Path(f"./dist/{version_raw}/cards-{version_raw}-linux.deb")
        if deb_path.exists():
            asset_name = f"cards-{version_fmt}.deb"
            github.upload(release_id, str(deb_path), asset_name, asset_name)

        # Upload AppImage
        appimage_path = Path(f"./dist/{version_raw}/cards-{version_raw}-linux.AppImage")
        if appimage_path.exists():
            asset_name = f"cards-{version_fmt}-x86_64.AppImage"
            github.upload(release_id, str(appimage_path), asset_name, asset_name)

        log_info("release_linux: SUCCESS")
    except Exception as e:
        log_error(str(e))


if __name__ == "__main__":
    main()
