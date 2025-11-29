"""Shared utilities for release scripts."""

import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any, Dict, Optional, Tuple
from urllib.parse import quote


class ANSI:
    """ANSI color codes."""

    BLUE = "\033[94m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    RED = "\033[91m"
    BOLD = "\033[1m"
    RESET = "\033[0m"


class ProcessError(Exception):
    """Raised when a shell command fails."""

    pass


class Config:
    """Manages environment configuration from .env file."""

    _instance: Optional["Config"] = None

    def __new__(cls) -> "Config":
        """Singleton pattern for config."""
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._env: Optional[Dict[str, str]] = None
        return cls._instance

    def load(self) -> Dict[str, str]:
        """Load .env file variables."""
        if self._env:
            return self._env

        # Try current directory first, then parent
        env_file = Path(".env")
        if not env_file.exists():
            env_file = Path("../.env")
        if not env_file.exists():
            raise FileNotFoundError(
                ".env file not found in current or parent directory"
            )

        self._env = {}
        with open(env_file) as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue

                # Handle both: KEY=VALUE and export KEY=VALUE
                if line.startswith("export "):
                    line = line[7:]  # Remove "export "

                if "=" in line:
                    key, val = line.split("=", 1)
                    # Remove quotes if present
                    val = val.strip("\"'")
                    self._env[key.strip()] = val

        return self._env

    def get(self, key: str, default: str = "") -> str:
        """Get config value."""
        return self.load().get(key, default)

    def require(self, key: str) -> str:
        """Get required config value or raise."""
        val = self.get(key)
        if not val:
            raise ValueError(f"Missing required config: {key}")
        return val

    @property
    def gh_token(self) -> str:
        """Get GitHub token from .env."""
        return self.require("GH_TOKEN")


class Shell:
    """Execute shell commands."""

    @staticmethod
    def run(cmd: str, check: bool = True, capture: bool = False) -> str:
        """Run command and return output."""
        # Print command before running (without sensitive data)
        log_cmd(cmd)

        if capture:
            # Capture output and return it
            result = subprocess.run(
                cmd, shell=True, capture_output=True, text=True, check=False
            )

            if result.stdout:
                print(result.stdout.rstrip())

            if check and result.returncode != 0:
                raise ProcessError(f"Command failed with exit code {result.returncode}")

            return result.stdout.strip()
        else:
            # Stream output in real-time
            result = subprocess.run(
                cmd, shell=True, capture_output=False, text=True, check=False
            )

            if check and result.returncode != 0:
                raise ProcessError(f"Command failed with exit code {result.returncode}")

            return ""


class Version:
    """Manage application version."""

    PUBSPEC = Path("./pubspec.yaml")
    PATTERN = re.compile(r"(\d+)\.(\d+)\.(\d+)\+(\d+)")

    @classmethod
    def raw(cls) -> str:
        """Get version from pubspec.yaml."""
        if not cls.PUBSPEC.exists():
            raise FileNotFoundError("pubspec.yaml not found")

        version = Shell.run("yq -r '.version' ./pubspec.yaml", capture=True)
        return version.strip()

    @classmethod
    def formatted(cls) -> str:
        """Get version with + replaced by _."""
        return cls.raw().replace("+", "_")

    @classmethod
    def parse(cls, ver: str) -> Tuple[int, int, int, int]:
        """Parse version to (major, minor, patch, code)."""
        match = cls.PATTERN.match(ver)
        if not match:
            raise ValueError(f"Invalid version: {ver}")
        return tuple(int(x) for x in match.groups())  # type: ignore

    @classmethod
    def bump(cls, bump_type: str) -> Tuple[str, str]:
        """Bump version and return (old, new)."""
        if bump_type not in ("major", "minor", "patch"):
            raise ValueError(f"Invalid bump type: {bump_type}")

        old = cls.raw()
        major, minor, patch, code = cls.parse(old)

        if bump_type == "major":
            major += 1
            minor = patch = 0
        elif bump_type == "minor":
            minor += 1
            patch = 0
        else:
            patch += 1

        code += 1
        new = f"{major}.{minor}.{patch}+{code}"

        Shell.run(f'yq -i -y ".version = \\"{new}\\"" ./pubspec.yaml')
        return old, new


class Git:
    """Git operations."""

    @staticmethod
    def tag(name: str, msg: str) -> None:
        """Create git tag."""
        Shell.run(f'git tag -a {name} HEAD -m "{msg}"')

    @staticmethod
    def commit(msg: str, files: Optional[list] = None) -> None:
        """Commit changes."""
        if files:
            for f in files:
                Shell.run(f"git add {f}")
        Shell.run(f'git commit -m "{msg}"')


class GitHub:
    """GitHub API interactions."""

    API = "https://api.github.com/repos/toxdes/cards"
    UPLOAD = "https://uploads.github.com/repos/toxdes/cards"

    def __init__(self, token: str):
        self.token = token

    def create_release(
        self,
        tag: str,
        name: str,
        body: str = "",
        draft: bool = True,
        prerelease: bool = False,
    ) -> int:
        """Create release and return ID."""
        data = {
            "tag_name": tag,
            "target_commitish": "main",
            "name": name,
            "body": body,
            "draft": draft,
            "prerelease": prerelease,
            "generate_release_notes": False,
        }

        redacted_cmd = (
            f"curl -L -X POST "
            f'-H "Accept: application/vnd.github+json" '
            f'-H "Authorization: Bearer ***" '
            f'-H "X-GitHub-Api-Version: 2022-11-28" '
            f"{self.API}/releases "
            f"-d '{json.dumps(data)}'"
        )

        log_cmd(redacted_cmd)

        # Actual token
        cmd = (
            f"curl -L -X POST "
            f'-H "Accept: application/vnd.github+json" '
            f'-H "Authorization: Bearer {self.token}" '
            f'-H "X-GitHub-Api-Version: 2022-11-28" '
            f"{self.API}/releases "
            f"-d '{json.dumps(data)}'"
        )

        result = subprocess.run(
            cmd, shell=True, capture_output=True, text=True, check=False
        )

        if result.returncode != 0:
            raise ProcessError(f"Failed to create release: {result.stderr}")

        resp_data = json.loads(result.stdout)
        return int(resp_data["id"])

    def get_release(self, tag: str) -> Dict[str, Any]:
        """Get release by tag."""

        redacted_cmd = (
            f"curl -L -X GET"
            f'-H "Accept: application/vnd.github+json" '
            f'-H "Authorization: Bearer ***" '
            f'-H "X-GitHub-Api-Version: 2022-11-28" '
            f"{self.API}/releases/tags/{tag}"
        )

        log_cmd(redacted_cmd)

        # Actual token
        cmd = (
            f"curl -L -X GET "
            f'-H "Accept: application/vnd.github+json" '
            f'-H "Authorization: Bearer {self.token}" '
            f'-H "X-GitHub-Api-Version: 2022-11-28" '
            f"{self.API}/releases/tags/{tag}"
        )

        result = subprocess.run(
            cmd, shell=True, capture_output=True, text=True, check=False
        )
        return json.loads(result.stdout)

    def get_release_id(self, tag: str) -> int:
        """Get release ID by tag or raise if not found."""
        data = self.get_release(tag)
        release_id = data.get("id")
        if not release_id:
            raise ValueError(f"Release not found for tag: {tag}")
        return int(release_id)

    def upload(self, release_id: int, filepath: str, name: str, label: str) -> None:
        """Upload asset to release."""
        if not Path(filepath).exists():
            raise FileNotFoundError(f"Not found: {filepath}")

        log_info(f"Uploading {label}")

        # URL encode parameters
        encoded_name = quote(name, safe="")
        encoded_label = quote(label, safe="")

        # Build URL properly
        base_url = f"{self.UPLOAD}/releases/{release_id}/assets"
        query = f"name={encoded_name}&label={encoded_label}"
        url = f"{base_url}?{query}"

        redacted_cmd = (
            f"curl -L -X POST "
            f'-H "Accept: application/vnd.github+json" '
            f'-H "Authorization: Bearer ***" '
            f'-H "X-GitHub-Api-Version: 2022-11-28" '
            f'-H "Content-Type: application/octet-stream" '
            f"-o /dev/null "
            f'"{url}" '
            f'--data-binary "@{filepath}"'
        )

        log_cmd(redacted_cmd)

        # Actual token
        cmd = (
            f"curl -L -X POST "
            f'-H "Accept: application/vnd.github+json" '
            f'-H "Authorization: Bearer {self.token}" '
            f'-H "X-GitHub-Api-Version: 2022-11-28" '
            f'-H "Content-Type: application/octet-stream" '
            f"-o /dev/null "
            f'"{url}" '
            f'--data-binary "@{filepath}"'
        )

        result = subprocess.run(
            cmd, shell=True, capture_output=False, text=True, check=False
        )

        if result.returncode != 0:
            raise ProcessError(f"Failed to upload {label}")

        print()


def log_info(msg: str) -> None:
    """Log info message with color***."""
    print(f"{ANSI.BLUE}{ANSI.BOLD}[INFO]{ANSI.RESET} {msg}")


def log_cmd(cmd: str) -> None:
    """Log command before running."""
    print(f"{ANSI.GREEN}{ANSI.BOLD}[SHELL]{ANSI.RESET} {cmd}")


def log_error(msg: str) -> None:
    """Log error and exit."""
    print(f"{ANSI.RED}{ANSI.BOLD}[ERROR]{ANSI.RESET} {msg}", file=sys.stderr)
    sys.exit(1)
