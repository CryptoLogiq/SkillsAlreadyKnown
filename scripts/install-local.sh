#!/usr/bin/env bash
set -euo pipefail

addon="SkillsAlreadyKnown"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
wow_root="$(cd "$root/../.." && pwd)"
target="$wow_root/Interface/AddOns/$addon"

case "$target" in
  */Interface/AddOns/SkillsAlreadyKnown) ;;
  *)
    echo "Refusing to install to unexpected path: $target" >&2
    exit 1
    ;;
esac

mkdir -p "$target"

rsync -a --delete --delete-excluded \
  --exclude '.git' \
  --exclude '.github' \
  --exclude '.gitignore' \
  --exclude '.gitattributes' \
  --exclude '.pkgmeta' \
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
  "$root/" "$target/"

echo "Installed $addon to $target"
