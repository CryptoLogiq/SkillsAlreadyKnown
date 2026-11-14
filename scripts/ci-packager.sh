#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mode="${1:-build}"
case "$mode" in
  build|publish) ;;
  *) echo "Usage: $0 [build|publish]" >&2; exit 1 ;;
esac
packager="${SAM_PACKAGER:-$root/.packager/release.sh}"
if [[ ! -f "$packager" ]]; then
  echo "The pinned BigWigs packager checkout is missing." >&2
  exit 1
fi
metadata="$(python3 - "$root/release/ci-release.json" <<'PY'
import json, re, sys
from pathlib import Path
release = json.loads(Path(sys.argv[1]).read_text())
version, tag, channel = (release[key] for key in ("version", "tag", "channel"))
if not re.fullmatch(r"\d+\.\d+\.\d+(?:-beta\.\d+\.\d+)?", version):
    raise SystemExit("Invalid release version")
if tag != "v" + version or channel not in ("beta", "release"):
    raise SystemExit("Invalid release tag/channel")
if ("-beta." in version) != (channel == "beta"):
    raise SystemExit("Release channel and version disagree")
print(version)
print(tag)
PY
)"
mapfile -t release_fields <<< "$metadata"
version="${release_fields[0]}"
tag="${release_fields[1]}"
latest="$root/release/latest"
archive="$latest/SkillsAndMore-$version.zip"
args=(-e -l -u -g forever -t "$root" -r "$latest" -n "SkillsAndMore-$version:$version")
if [[ "$mode" == build ]]; then
  if [[ -e "$archive" ]]; then
    echo "Refusing to rebuild an existing CI archive." >&2
    exit 1
  fi
  args+=(-d)
else
  if [[ -z "${CF_API_TOKEN:-${CF_API_KEY:-}}" || -z "${GH_API_TOKEN:-}" ]]; then
    echo "Publishing requires CurseForge and GitHub tokens." >&2
    exit 1
  fi
  python3 "$root/scripts/verify-ci-release.py"
  before="$(sha256sum "$archive")"
  # Reuse the validated ZIP: publishing must not assemble a different artifact.
  args+=(-c -z)
fi
# A dev push is packaged as its validated beta tag in this same workflow run.
# This avoids starting a second workflow from a GITHUB_TOKEN-created tag.
# With -z, upstream skips initializing upload metadata as well as ZIP creation.
# Supply it explicitly so upload-only mode sends the already verified archive.
archive="$archive" archive_name="${archive##*/}" archive_label="$version" archive_version="$version" \
GITHUB_EVENT_NAME=workflow_dispatch GITHUB_REF="refs/tags/$tag" GITHUB_REF_NAME="$tag" \
  bash "$packager" "${args[@]}"
python3 "$root/scripts/verify-ci-release.py"
if [[ "$mode" == publish && "$(sha256sum "$archive")" != "$before" ]]; then
  echo "Publishing changed the already validated ZIP." >&2
  exit 1
fi
