#!/usr/bin/env python3
"""Validate a release ref and prepare an ephemeral CI checkout for packaging."""
from pathlib import Path
import argparse
import importlib.util
import json
import os
import re
import subprocess

TOC = "SkillsAlreadyKnown.toc"
PROJECT_ID = 1725046


def git(root, *args, check=True):
    return subprocess.run(["git", "-C", str(root), *args], check=check,
                          capture_output=True, text=True)


def generator(root):
    spec = importlib.util.spec_from_file_location("patchnotes", root / "scripts/generate-patchnotes.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def numbers(version):
    if not re.fullmatch(r"\d+\.\d+\.\d+", version):
        raise ValueError("Expected major.minor.patch version")
    return tuple(map(int, version.split(".")))


def field(source, name):
    match = re.search(r'^\s*' + name + r'\s*=\s*"([^"]+)"', source, re.M)
    if not match:
        raise ValueError(f"Missing {name}")
    return match[1]


def plan(root, ref, run_number, attempt, expected_sha=None):
    toc = (root / TOC).read_text()
    base = re.search(r"^## Version:\s*(\S+)", toc, re.M)[1]
    numbers(base)
    head = git(root, "rev-parse", "HEAD").stdout.strip()
    if expected_sha:
        if not re.fullmatch(r"[a-fA-F0-9]{40}", expected_sha):
            raise ValueError("Expected a full workflow commit SHA")
        expected = git(root, "rev-parse", expected_sha + "^{commit}").stdout.strip()
        if head != expected:
            raise ValueError("Checkout does not match the workflow commit")
    if git(root, "diff", "--name-only", "HEAD").stdout.strip():
        raise ValueError("Prepare releases from a clean CI checkout")
    notes = generator(root)
    runtime = notes.generate(root)
    unreleased = (root / "patchnote/Unreleased.lua").read_text()
    if ref == "refs/heads/dev":
        if run_number < 1 or attempt < 1:
            raise ValueError("A beta requires positive workflow run and attempt numbers")
        previous = field(unreleased, "basedOn")
        if numbers(base) < numbers(previous):
            raise ValueError("The TOC version is older than Unreleased.basedOn")
        target = base
        if numbers(base) == numbers(previous):
            major, minor, patch = numbers(base)
            target = f"{major}.{minor}.{patch + 1}"
        version = f"{target}-beta.{run_number}.{attempt}"
        channel, tag = "beta", "v" + version
        if git(root, "show-ref", "--verify", "--quiet", "refs/tags/" + tag, check=False).returncode == 0:
            raise ValueError("This beta tag already exists; use a fresh run attempt")
        runtime = runtime.replace('version = "Unreleased"', f'version = "{version}"', 1)
        runtime = runtime.replace('status = "development"', 'status = "beta"', 1)
        source = unreleased
    elif re.fullmatch(r"refs/tags/v\d+\.\d+\.\d+", ref):
        version = ref.removeprefix("refs/tags/v")
        channel, tag = "release", "v" + version
        if version != base:
            raise ValueError("Stable tag and TOC version must match")
        if git(root, "merge-base", "--is-ancestor", "HEAD", "refs/remotes/origin/main", check=False).returncode:
            raise ValueError("Stable releases must point to a commit on main")
        tagged = git(root, "rev-parse", tag + "^{commit}").stdout.strip()
        if tagged != head:
            raise ValueError("Stable tag does not point to this checkout")
        # A stable file must describe all packaged player changes, not omit pending notes.
        empty = notes.render_markdown("", "", unreleased).strip()
        if "\n" in empty:
            raise ValueError("Promote Unreleased notes into the stable release before publishing")
        source = (root / "patchnote" / (version + ".lua")).read_text()
    else:
        raise ValueError("Only dev builds and stable vX.Y.Z tags on main are allowed")
    title = re.search(r"^## Title:\s*(.+)", toc, re.M)[1]
    markdown = notes.render_markdown(title, version, source, notes.read_catalogs(root))
    return {
        "version": version, "channel": channel, "tag": tag, "commit": head,
        "source_ref": ref, "archive": f"SkillsAndMore-{version}.zip",
        "project_id": PROJECT_ID,
    }, runtime, markdown, toc


def prepare(root, ref, run_number, attempt, expected_sha=None):
    metadata, runtime, markdown, toc = plan(root, ref, run_number, attempt, expected_sha)
    if metadata["channel"] == "beta":
        # Local tag only. The workflow pushes it after tests/build validation and secret checks.
        git(root, "-c", "user.name=github-actions[bot]",
            "-c", "user.email=41898282+github-actions[bot]@users.noreply.github.com",
            "tag", "-a", metadata["tag"], "-m", metadata["tag"])
    latest = root / "release/latest"
    latest.mkdir(parents=True, exist_ok=True)
    (latest / "patchnote.md").write_text(markdown)
    (root / "data/Patchnotes.lua").write_text(runtime)
    toc = re.sub(r"^## Version:.*$", "## Version: " + metadata["version"], toc, flags=re.M)
    (root / TOC).write_text(toc)
    (root / "release/ci-release.json").write_text(json.dumps(metadata, indent=2) + "\n")
    return metadata


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent.parent)
    parser.add_argument("--ref", required=True)
    parser.add_argument("--run-number", type=int, default=0)
    parser.add_argument("--attempt", type=int, default=1)
    parser.add_argument("--sha")
    parser.add_argument("--github-output", type=Path)
    args = parser.parse_args()
    if os.environ.get("GITHUB_ACTIONS") != "true":
        parser.exit(1, "Release preparation is CI-only; use a disposable GitHub Actions checkout.\n")
    try:
        result = prepare(args.root, args.ref, args.run_number, args.attempt, args.sha)
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        parser.exit(1, f"Release preparation failed: {error}\n")
    if args.github_output:
        with args.github_output.open("a") as output:
            for key, value in result.items():
                output.write(f"{key}={value}\n")
    print(json.dumps(result))


if __name__ == "__main__":
    main()
