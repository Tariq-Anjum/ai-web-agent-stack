#!/usr/bin/env bash
set -Eeuo pipefail

fail=0

need_sudo() {
  command -v sudo >/dev/null 2>&1 || {
    echo "sudo is required to install system packages and manage Docker." >&2
    exit 1
  }
}

install_arch() {
  need_sudo
  sudo pacman -Syu --needed \
    docker docker-compose git curl jq openssl ca-certificates xz tar nodejs npm
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER" || true
}

install_debian() {
  need_sudo
  sudo apt-get update
  sudo apt-get install -y \
    docker.io docker-compose-v2 git curl jq openssl \
    ca-certificates xz-utils tar nodejs npm
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER" || true
}

check_cmd() {
  local cmd="$1"

  if command -v "$cmd" >/dev/null 2>&1; then
    printf 'PASS: %-12s %s\n' \
      "$cmd" \
      "$("$cmd" --version 2>/dev/null | head -n1 || true)"
  else
    printf 'FAIL: %-12s missing\n' "$cmd"
    fail=1
  fi
}

check() {
  printf '%s\n' 'Checking prerequisites...'

  check_cmd docker
  check_cmd curl
  check_cmd jq
  check_cmd git
  check_cmd openssl
  check_cmd tar
  check_cmd xz
  check_cmd node
  check_cmd npm

  if command -v node >/dev/null 2>&1; then
    if node -e 'process.exit(Number(process.versions.node.split(".")[0]) >= 24 ? 0 : 1)'; then
      printf 'PASS: %-12s Node.js >= 24 required by agent-browser
' "node-version"
    else
      printf 'FAIL: %-12s Node.js >= 24 is required by agent-browser
' "node-version"
      fail=1
    fi
  fi

  if docker compose version >/dev/null 2>&1; then
    printf 'PASS: %-12s %s\n' "compose" "$(docker compose version)"
  else
    printf '%s\n' 'FAIL: compose      Docker Compose plugin is unavailable'
    fail=1
  fi

  if docker info >/dev/null 2>&1; then
    printf '%s\n' 'PASS: Docker daemon is reachable'
  else
    printf '%s\n' 'FAIL: Docker daemon is not reachable'
    fail=1
  fi

  if (( fail )); then
    printf '%s\n' ''
    printf '%s\n' 'Prerequisite check failed.'
    return 1
  fi

  printf '%s\n' ''
  printf '%s\n' 'Prerequisite check passed.'
}

case "${1:-check}" in
  install)
    if command -v pacman >/dev/null 2>&1; then
      install_arch
    elif command -v apt-get >/dev/null 2>&1; then
      install_debian
    else
      echo "Unsupported package manager. Install Docker/Compose, Git, curl, jq, openssl, tar, xz, Node.js and npm manually." >&2
      exit 1
    fi
    ;;
  check)
    check
    ;;
  *)
    echo "Usage: $0 [check|install]" >&2
    exit 2
    ;;
esac
