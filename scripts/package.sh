#!/usr/bin/env bash
set -euo pipefail

addon="SkillsAlreadyKnown"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$(awk -F': *' '/^## Version:/ { print $2; exit }' "$root/$addon.toc")"
out_dir="$root/release"
stage="$(mktemp -d)"

cleanup() {
  rm -rf "$stage"
}
trap cleanup EXIT

mkdir -p "$out_dir" "$stage/$addon"

rsync -a \
  --exclude '.git' \
  --exclude '.github' \
  --exclude '.gitignore' \
  --exclude '.gitattributes' \
  --exclude '.pkgmeta' \
  --exclude 'AGENTS.md' \
  --exclude 'CONTRIBUTING.md' \
  --exclude 'scripts' \
  --exclude 'release' \
  --exclude 'releases' \
  --exclude 'dist' \
  --exclude 'build' \
  --exclude '.codex' \
  --exclude '.agents' \
  --exclude '*.zip' \
  --exclude '*.7z' \
  --exclude '*.tar' \
  --exclude '*.tar.gz' \
  "$root/" "$stage/$addon/"

zip_path="$out_dir/$addon-$version.zip"

if command -v zip >/dev/null 2>&1; then
  (cd "$stage" && zip -r "$zip_path" "$addon")
elif command -v python3 >/dev/null 2>&1; then
  python3 - "$stage" "$addon" "$zip_path" <<'PY'
import os
import sys
import zipfile

stage, addon, zip_path = sys.argv[1:4]
base = os.path.join(stage, addon)

with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as archive:
    for root, _, files in os.walk(base):
        for filename in files:
            path = os.path.join(root, filename)
            archive.write(path, os.path.relpath(path, stage))
PY
else
  echo "error: need either zip or python3 to create the package" >&2
  exit 1
fi

echo "$zip_path"
