#!/usr/bin/env bash
set -euo pipefail

addon="SkillsAlreadyKnown"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$(awk -F': *' '/^## Version:/ { print $2; exit }' "$root/$addon.toc")"
refresh_latest=false
case "${1:-}" in
  "") ;;
  --refresh-latest) refresh_latest=true ;;
  *) echo "Usage: $0 [--refresh-latest]" >&2; exit 1 ;;
esac
if (( $# > 1 )); then
  echo "Usage: $0 [--refresh-latest]" >&2
  exit 1
fi
out_dir="$root/release"
zip_path="$out_dir/$addon-$version.zip"
if [[ -z "$version" || "$version" == *[!0-9A-Za-z._-]* ]]; then
  echo "Invalid addon version: $version" >&2
  exit 1
fi
if [[ -e "$zip_path" ]] && ! "$refresh_latest"; then
  echo "Package already exists: $zip_path. Keep it and bump the version before packaging." >&2
  exit 1
fi
if "$refresh_latest" && [[ ! -f "$zip_path" ]]; then
  echo "No existing archive to copy into latest: $zip_path" >&2
  exit 1
fi
stage="$(mktemp -d)"

cleanup() {
  rm -rf "$stage"
}
trap cleanup EXIT

mkdir -p "$out_dir" "$stage/$addon"
python3 "$root/scripts/generate-patchnotes.py" --output "$stage/expected-patchnotes.lua"
python3 "$root/scripts/generate-patchnotes.py" --format markdown --output "$stage/patchnote.md"

if ! "$refresh_latest"; then
python3 "$root/scripts/generate-patchnotes.py"

rsync -a \
  --exclude '.git' \
  --exclude '.github' \
  --exclude '.gitignore' \
  --exclude '.gitattributes' \
  --exclude '.pkgmeta' \
  --exclude 'AGENTS.md' \
  --exclude 'CONTRIBUTING.md' \
  --exclude 'patchnote' \
  --exclude 'scripts' \
  --exclude 'release' \
  --exclude 'releases' \
  --exclude 'dist' \
  --exclude 'build' \
  --exclude '.codex' \
  --exclude '.agents' \
  --exclude '.aws' \
  --exclude '*.zip' \
  --exclude '*.7z' \
  --exclude '*.tar' \
  --exclude '*.tar.gz' \
  "$root/" "$stage/$addon/"

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

fi

# Publish a copy, never rebuild or overwrite a versioned archive.
python3 - "$zip_path" "$out_dir/latest" "$stage" "$addon" <<'PYLATEST'
from pathlib import Path
import os
import shutil
import sys
import tempfile
import zipfile

archive, latest, stage = map(Path, sys.argv[1:4])
addon = sys.argv[4]
with zipfile.ZipFile(archive) as package:
    if package.read(addon + "/data/Patchnotes.lua") != (stage / "expected-patchnotes.lua").read_bytes():
        raise SystemExit("Archive patchnotes differ from the current sources; latest was not updated.")
if latest.is_symlink():
    raise SystemExit("Refusing to write latest through a symlink.")
latest.mkdir(parents=True, exist_ok=True)
for source, name in ((archive, archive.name), (stage / "patchnote.md", "patchnote.md")):
    with tempfile.NamedTemporaryFile(dir=latest, delete=False) as temporary:
        target = Path(temporary.name)
    try:
        shutil.copyfile(source, target)
        os.chmod(target, 0o644)
        os.replace(target, latest / name)
    finally:
        target.unlink(missing_ok=True)
for previous in latest.glob(addon + "-*.zip"):
    if previous.name != archive.name:
        previous.unlink()
PYLATEST

echo "$out_dir/latest/$addon-$version.zip"
echo "$out_dir/latest/patchnote.md"
