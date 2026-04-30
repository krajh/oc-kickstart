#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/dist/release}"
TAG="${1:-${TAG:-}}"

REQUIRED_PATHS=(
  "AGENTS.md"
  "bunfig.toml"
  "opencode.json"
  "oc-kickstart-install"
  "agents"
  "plugins"
  "protocols"
  "skills"
  "commands"
  "shade"
)

usage() {
  cat <<'EOF'
Usage: scripts/build-release-assets.sh <tag>

Builds release assets for a tag like v0.1.1 into dist/release/.
EOF
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

file_sha256() {
  local file="$1"

  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | cut -d' ' -f1
    return 0
  fi

  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | cut -d' ' -f1
    return 0
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$file" <<'PY'
import hashlib
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
print(hashlib.sha256(path.read_bytes()).hexdigest())
PY
    return 0
  fi

  die "No SHA-256 tool available (need sha256sum, shasum, or python3)"
}

if [[ -z "$TAG" ]]; then
  usage
  exit 1
fi

if [[ ! "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  die "Tag must match vX.Y.Z (got: $TAG)"
fi

for path in "${REQUIRED_PATHS[@]}"; do
  [[ -e "$ROOT_DIR/$path" ]] || die "Missing required path: $path"
done

mkdir -p "$OUT_DIR"

TARBALL_NAME="oc-kickstart-${TAG}.tar.gz"
TARBALL_PATH="$OUT_DIR/$TARBALL_NAME"
MANIFEST_PATH="$OUT_DIR/manifest.json"
INSTALL_PATH="$OUT_DIR/install"
INSTALLER_PATH="$OUT_DIR/oc-kickstart-install"

rm -f "$TARBALL_PATH" "$MANIFEST_PATH" "$INSTALL_PATH" "$INSTALLER_PATH"

cp "$ROOT_DIR/install" "$INSTALL_PATH"
cp "$ROOT_DIR/oc-kickstart-install" "$INSTALLER_PATH"
chmod +x "$INSTALL_PATH" "$INSTALLER_PATH"

tar -czf "$TARBALL_PATH" -C "$ROOT_DIR" "${REQUIRED_PATHS[@]}"

TARBALL_SHA256="$(file_sha256 "$TARBALL_PATH")"

cat > "$MANIFEST_PATH" <<EOF
{
  "version": "${TAG#v}",
  "tag": "$TAG",
  "asset": "$TARBALL_NAME",
  "sha256": "$TARBALL_SHA256"
}
EOF

printf 'Built release assets in %s\n' "$OUT_DIR"
printf ' - %s\n' "$INSTALL_PATH"
printf ' - %s\n' "$INSTALLER_PATH"
printf ' - %s\n' "$MANIFEST_PATH"
printf ' - %s\n' "$TARBALL_PATH"
