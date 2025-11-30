#!/usr/bin/env python3
"""Tag commit and create GitHub release (without building)."""

from lib import Config, Git, GitHub, Version, log_error, log_info


def main() -> None:
    """Prepare release: tag commit and create GitHub release."""
    try:
        config = Config()
        github = GitHub(config.gh_token)

        version_fmt = Version.formatted()
        tag = f"internal-{version_fmt}"
        release_name = f"cards-{version_fmt}"

        # Tag commit
        log_info(f"Tagging commit: {tag}")
        Git.tag(tag, f"release {version_fmt}")

        # Create release
        log_info(f"Creating release: {release_name}")
        body = "## Release Notes\nThis is work in progress."
        release_id = github.create_release(tag, release_name, body)
        log_info(f"RELEASE ID: {release_id}")

        log_info("prepare_release: SUCCESS")
    except Exception as e:
        log_error(str(e))


if __name__ == "__main__":
    main()
