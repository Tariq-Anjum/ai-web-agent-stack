#!/usr/bin/env bash
set -Eeuo pipefail

need_sudo() {
  command -v sudo >/dev/null 2>&1 || {
    echo "sudo is required to install system packages and manage Docker." >&2
    exit 1
  }
}

install_arch() {
  need_sudo
  sudo pacman -Syu --needed docker docker-compose git curl jq openssl ca-certificates xz tar
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER" || true
}

install_debian() {
  need_sudo
  sudo apt-get update
  sudo apt-get install -y docker.io docker-compose-v2 git curl jq openssl ca-certificates xz-utils tar
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER" || true
}

case "${1:-check}" in
  install)
    if command -v pacman >/dev/null 2>&1; then
      install_arch
    elif command -v apt-get >/dev/null 2>&1; then
      install_debian
    else
      echo "Unsupported package manager. Install Docker/Compose, Git, curl, jq, openssl, tar and xz manually." >&2
      exit 1
    fi
    ;;
  check)
    for cmd in docker curl jq git openssl tar; do
      command -v "$cmd" >/dev/null 2>&1 || echo "MISSING: $cmd"
    done
    docker compose version >/dev/null 2>&1 || echo "MISSING: docker compose"
    ;;
  *)
    echo "Usage: $0 [check|install]" >&2
    exit 2
    ;;
esac
