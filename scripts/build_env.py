#!/usr/bin/env python3
"""Set up build environment."""

from lib import Shell, log_error, log_info


def main() -> None:
    """Activate Java 17."""
    try:
        Shell.run("sdk use java 17.0.8.1-tem")
        log_info("Java 17 environment activated")
    except Exception as e:
        log_error(str(e))


if __name__ == "__main__":
    main()
