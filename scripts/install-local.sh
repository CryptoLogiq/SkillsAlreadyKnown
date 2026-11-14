#!/usr/bin/env bash
set -euo pipefail

addon="SkillsAlreadyKnown"
dev_addon="${addon}_dev"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dry_run=()
case "${1:-}" in
  "") ;;
  --dry-run) dry_run=(--dry-run --itemize-changes) ;;
  *) echo "Usage: $0 [--dry-run]" >&2; exit 1 ;;
esac
if (( $# > 1 )); then
  echo "Usage: $0 [--dry-run]" >&2
  exit 1
fi

wow_root="${SAK_WOW_ROOT:-$HOME/Games/Heroic/Prefixes/Battle.net/drive_c/Program Files (x86)/World of Warcraft/_forever_}"
if [[ ! -d "$wow_root/Interface/AddOns" ]]; then
  echo "WoW AddOns directory not found: $wow_root/Interface/AddOns" >&2
  echo "Set SAK_WOW_ROOT to the client directory (for example _forever_)." >&2
  exit 1
fi
wow_root="$(cd "$wow_root" && pwd -P)"
target="$wow_root/Interface/AddOns/$dev_addon"

case "$target" in
  */Interface/AddOns/SkillsAlreadyKnown_dev) ;;
  *)
    echo "Refusing to install to unexpected path: $target" >&2
    exit 1
    ;;
esac

if [[ -L "$target" || "$root" == "$target" || "$root" == "$target/"* ]]; then
  echo "Refusing to overwrite a symlink or the development source: $target" >&2
  exit 1
fi
printf 'Source: %s\nTarget: %s\n' "$root" "$target"

stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT

# Generate into staging so --dry-run never changes the working tree.
python3 "$root/scripts/generate-patchnotes.py" --output "$stage/Patchnotes.lua"

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
  "$root/" "$stage/"

mkdir -p "$stage/data"
mv "$stage/Patchnotes.lua" "$stage/data/Patchnotes.lua"

# Give the development copy its own TOC, namespace, saved variables and asset paths.
# The source and published package keep their original names.
python3 - "$stage" "$addon" "$dev_addon" <<'PYDEV'
from pathlib import Path
import sys
stage, addon, dev_addon = Path(sys.argv[1]), sys.argv[2], sys.argv[3]
for path in stage.rglob("*.lua"):
    # Transform addon-owned modules and nested data, never vendored libraries.
    if path.relative_to(stage).parts[0] == "libs":
        continue
    path.write_text(path.read_text().replace(addon, dev_addon))
toc = stage / (addon + ".toc")
text = toc.read_text().replace(addon, dev_addon)
text = text.replace("## Title: Skills & More", "## Title: Skills & More [DEV]")
(stage / (dev_addon + ".toc")).write_text(text)
toc.unlink()
PYDEV

rsync -a --delete --delete-excluded "${dry_run[@]}" "$stage/" "$target/"

if (( ${#dry_run[@]} )); then
  echo "Dry run complete; no files changed."
else
  echo "Installed $dev_addon to $target"
fi
