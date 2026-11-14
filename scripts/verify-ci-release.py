#!/usr/bin/env python3
"""Check the exact ZIP that will be attached to both release services."""
from pathlib import Path, PurePosixPath
import argparse
import json
import re
import zipfile


def verify(root):
    metadata = json.loads((root / "release/ci-release.json").read_text())
    archive = root / "release/latest" / metadata["archive"]
    forbidden = {".git", ".github", ".aws", ".codex", ".agents", "scripts", "patchnote", "release", "releases", "dist", "build", "WTF", "Cache", "Logs", "Errors", ".vscode", ".idea", ".packager", "__pycache__"}
    with zipfile.ZipFile(archive) as package:
        names = package.namelist()
        if len(names) != len(set(names)):
            raise ValueError("Duplicate ZIP members")
        for name in names:
            parts = PurePosixPath(name).parts
            if not parts or parts[0] != "SkillsAlreadyKnown" or ".." in parts:
                raise ValueError("Unexpected addon folder in ZIP")
            if (forbidden.intersection(parts) or name.endswith("AGENTS.md")
                    or name.endswith("CONTRIBUTING.md")
                    or any(part == ".env" or part.startswith(".env.") for part in parts)
                    or name.endswith((".pyc", ".pyo", ".pkg"))):
                raise ValueError("Development-only files in ZIP")
        toc = package.read("SkillsAlreadyKnown/SkillsAlreadyKnown.toc").decode()
        if re.search(r"^## Version:\s*(\S+)", toc, re.M)[1] != metadata["version"]:
            raise ValueError("ZIP version does not match its release metadata")
        if "## SavedVariablesPerCharacter: SkillsAlreadyKnownDB" not in toc:
            raise ValueError("Saved-variable identity changed")
        for line in toc.splitlines():
            if not line or line.startswith("#"):
                continue
            file = line.split(" [", 1)[0].replace("\\", "/")
            packaged = package.read("SkillsAlreadyKnown/" + file)
            source = (root / file).read_bytes()
            if file.startswith("libs/"):
                if packaged != source:
                    raise ValueError("Upstream library bytes changed: " + file)
            elif packaged.replace(b"\r\n", b"\n") != source.replace(b"\r\n", b"\n"):
                raise ValueError("Packaged file differs from tested source: " + file)
        if package.read("SkillsAlreadyKnown/data/Patchnotes.lua").replace(b"\r\n", b"\n") != (root / "data/Patchnotes.lua").read_bytes():
            raise ValueError("Packaged runtime patchnotes differ")
    notes = (root / "release/latest/patchnote.md").read_text()
    if not notes.startswith("# Skills & More — " + metadata["version"] + "\n"):
        raise ValueError("Markdown version differs from the ZIP version")
    return archive


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent.parent)
    args = parser.parse_args()
    print("Verified release: " + str(verify(args.root)))


if __name__ == "__main__":
    main()
