#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="${REPO_URL:-https://github.com/Tariq-Anjum/ai-web-agent-stack.git}"
TARGET_DIR="${1:-$HOME/ai-web-agent-stack}"

command -v git >/dev/null 2>&1 || {
  echo "git is required to bootstrap this repository." >&2
  echo "Install git, then rerun." >&2
  exit 1
}

if [[ -e "$TARGET_DIR/.git" ]]; then
  echo "Repository already exists: $TARGET_DIR"
else
  git clone "$REPO_URL" "$TARGET_DIR"
fi

cd "$TARGET_DIR"

./scripts/prerequisites.sh install

# Docker group changes require a new login session. Detect the common case
# where the daemon is available but the current shell has not picked up the group.
if ! docker info >/dev/null 2>&1; then
  echo >&2
  echo "Docker is installed and running, but this shell cannot access the Docker socket." >&2
  echo "Log out/in (or start a new shell with the docker group), then rerun:" >&2
  echo "  cd $TARGET_DIR && ./scripts/install.sh" >&2
  exit 1
fi

./scripts/install.sh
