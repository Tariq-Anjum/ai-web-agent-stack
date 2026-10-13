#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
temp="$(mktemp -d)"
trap 'rm -rf -- "$temp"' EXIT
mkdir -p "$temp/project/scripts" "$temp/project/.git" "$temp/bin"
cp "$ROOT/scripts/bootstrap.sh" "$temp/project/scripts/"
# Mock only the system-mutating boundary. Never install packages or clone online.
printf '#!/usr/bin/env bash\nexit 99\n' > "$temp/bin/git"
printf '#!/usr/bin/env bash\nexit 0\n' > "$temp/bin/docker"
printf '#!/usr/bin/env bash\n[[ "$1" == install ]]\n' > "$temp/project/scripts/prerequisites.sh"
printf '#!/usr/bin/env bash\nprintf "INSTALL_ROOT=%%s\\n" "$PWD"\n' > "$temp/project/scripts/install.sh"
chmod +x "$temp/bin/"* "$temp/project/scripts/"*
output="$(PATH="$temp/bin:$PATH" "$temp/project/scripts/bootstrap.sh")"
grep -Fxq "INSTALL_ROOT=$temp/project" <<<"$output"
echo 'PASS bootstrap: default target is current checkout, no duplicate clone'
