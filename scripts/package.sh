#!/usr/bin/env bash
set -euo pipefail

if [[ ! -t 1 && -z "${SAK_TERMINAL_REEXEC:-}" && -z "${CODEX_CI:-}" && -z "${CI:-}" ]]; then
  script="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
  title="SkillsAlreadyKnown package"
  command="SAK_TERMINAL_REEXEC=1 '$script'; status=\$?; echo; read -r -p 'Press Enter to close...'; exit \$status"

  if command -v konsole >/dev/null 2>&1; then
    exec konsole --title "$title" -e bash -lc "$command"
  elif command -v gnome-terminal >/dev/null 2>&1; then
    exec gnome-terminal --title="$title" -- bash -lc "$command"
  elif command -v xfce4-terminal >/dev/null 2>&1; then
    exec xfce4-terminal --title="$title" --command "bash -lc \"$command\""
  elif command -v mate-terminal >/dev/null 2>&1; then
    exec mate-terminal --title="$title" -- bash -lc "$command"
  elif command -v xterm >/dev/null 2>&1; then
    exec xterm -T "$title" -e bash -lc "$command"
  fi
fi

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
