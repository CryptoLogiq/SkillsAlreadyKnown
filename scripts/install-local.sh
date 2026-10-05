#!/usr/bin/env bash
set -euo pipefail

if [[ ! -t 1 && -z "${SAK_TERMINAL_REEXEC:-}" && -z "${CODEX_CI:-}" && -z "${CI:-}" ]]; then
  script="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
  title="SkillsAlreadyKnown local install"
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
