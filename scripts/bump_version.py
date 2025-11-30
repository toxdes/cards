#!/usr/bin/env python3
"""Bump application version in pubspec.yaml."""

import sys

from lib import Git, Version, log_error, log_info


def main() -> None:
    """Bump version and commit."""
    bump_type = sys.argv[1] if len(sys.argv) > 1 else "patch"

    try:
        old, new = Version.bump(bump_type)
        Git.commit(
            f"chore: bump {bump_type + ' ' if bump_type == 'patch' else ''}version",
            ["pubspec.yaml"],
        )
        log_info(f"{bump_type} version bumped: {old} -> {new}")

        log_info("bump_version: SUCCESS")
    except Exception as e:
        log_error(str(e))


if __name__ == "__main__":
    main()
