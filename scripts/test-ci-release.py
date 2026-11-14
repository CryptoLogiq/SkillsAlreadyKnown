#!/usr/bin/env python3
"""Exercise beta/stable release policy and real offline packaging in isolated repos."""
from pathlib import Path
import importlib.util
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile

root = Path(__file__).resolve().parent.parent


def command(repo, *args, success=True, env=None):
    result = subprocess.run(args, cwd=repo, capture_output=True, text=True, env=env)
    assert (result.returncode == 0) == success, result.stdout[-4500:] + result.stderr
    return result


def module(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def fixture(parent, name):
    target = parent / name
    target.mkdir()
    files = command(root, "git", "ls-files", "--cached", "--others", "--exclude-standard", "-z").stdout
    for file in set(files.split("\0")) - {""}:
        source = root / file
        if source.is_file():
            destination = target / file
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, destination)
    toc = target / "SkillsAlreadyKnown.toc"
    toc.write_text(re.sub(r"^## Version:.*$", "## Version: 0.4.0", toc.read_text(), flags=re.M))
    for notes in (target / "patchnote").glob("*.lua"):
        if notes.stem not in ("0.4.0", "Unreleased"):
            notes.unlink()
    (target / "patchnote/Unreleased.lua").write_text('return {\n version = "Unreleased",\n status = "development",\n basedOn = "0.4.0",\n additions = {"Beta-only feature."},\n fixes = {"Beta-only fix."},\n}\n')
    command(target, "git", "init", "-b", "dev")
    command(target, "git", "config", "user.name", "Release tests")
    command(target, "git", "config", "user.email", "release-tests@example.invalid")
    command(target, "git", "add", ".")
    command(target, "git", "commit", "-m", "Fixture")
    command(target, "git", "remote", "add", "origin", "https://github.com/CryptoLogiq/SkillsAlreadyKnown.git")
    return target


with tempfile.TemporaryDirectory(prefix="sam-ci-release-") as directory:
    parent = Path(directory)
    beta = fixture(parent, "beta")
    prepare = module(beta / "scripts/prepare-ci-release.py", "prepare_beta")
    head = command(beta, "git", "rev-parse", "HEAD").stdout.strip()
    original_toc = (beta / "SkillsAlreadyKnown.toc").read_bytes()
    original_notes = (beta / "patchnote/Unreleased.lua").read_bytes()
    for ref in ("refs/heads/main", "refs/heads/feature", "refs/tags/v0.4.1-beta.1"):
        try:
            prepare.plan(beta, ref, 42, 1, head)
        except ValueError:
            pass
        else:
            raise AssertionError("Unexpected allowed release ref: " + ref)
    assert (beta / "SkillsAlreadyKnown.toc").read_bytes() == original_toc
    command(beta, sys.executable, "scripts/prepare-ci-release.py", "--ref", "refs/heads/dev",
            "--run-number", "42", "--sha", head, success=False,
            env=dict(os.environ, GITHUB_ACTIONS="false"))
    result = command(beta, sys.executable, "scripts/prepare-ci-release.py", "--ref", "refs/heads/dev",
                     "--run-number", "42", "--sha", head,
                     "--github-output", str(parent / "metadata-outputs"),
                     env=dict(os.environ, GITHUB_ACTIONS="true"))
    metadata = json.loads(result.stdout)
    assert "version=0.4.1-beta.42.1" in (parent / "metadata-outputs").read_text()
    assert metadata["version"] == "0.4.1-beta.42.1" and metadata["channel"] == "beta"
    assert metadata["archive"] == "SkillsAndMore-0.4.1-beta.42.1.zip"
    assert command(beta, "git", "rev-parse", metadata["tag"] + "^{commit}").stdout.strip() == head
    assert (beta / "patchnote/Unreleased.lua").read_bytes() == original_notes
    runtime = (beta / "data/Patchnotes.lua").read_text()
    assert 'version = "0.4.1-beta.42.1"' in runtime and 'status = "beta"' in runtime
    markdown = (beta / "release/latest/patchnote.md").read_text()
    assert "0.4.1-beta.42.1" in markdown and "Beta-only feature." in markdown
    assert "Skills Already Known devient" not in markdown, "Beta notes must describe pending changes, not the previous stable release"

    packager = os.environ.get("SAM_TEST_PACKAGER")
    if not packager and (root / ".packager/release.sh").is_file():
        packager = str(root / ".packager/release.sh")
    if packager:
        env = dict(os.environ, SAM_PACKAGER=packager, GITHUB_ACTIONS="true",
                   GITHUB_EVENT_NAME="push", GITHUB_REF="refs/heads/dev", GITHUB_REF_NAME="dev",
                   GITHUB_OUTPUT=str(parent / "outputs"))
        for key in ("CF_API_TOKEN", "CF_API_KEY", "GH_API_TOKEN", "GITHUB_API_TOKEN", "GITHUB_OAUTH", "WOWI_API_TOKEN", "WAGO_API_TOKEN"):
            env.pop(key, None)
        if not shutil.which("zip"):
            # Only the host ZIP executable is substituted; the pinned upstream
            # packager performs all staging/filtering/metadata work unchanged.
            bin_dir = parent / "bin"
            bin_dir.mkdir()
            zip_shim = bin_dir / "zip"
            zip_shim.write_text('''#!/usr/bin/env python3
from pathlib import Path
import sys, zipfile
args = [arg for arg in sys.argv[1:] if not arg.startswith('-')]
with zipfile.ZipFile(args[0], 'w', zipfile.ZIP_DEFLATED) as out:
    for name in args[1:]:
        for path in Path(name).rglob('*'):
            if path.is_file(): out.write(path, str(path))
''')
            zip_shim.chmod(0o755)
            env["PATH"] = str(bin_dir) + os.pathsep + env["PATH"]
        command(beta, "bash", "scripts/ci-packager.sh", "build", env=env)
        archive = beta / "release/latest" / metadata["archive"]
        assert archive.is_file()
        assert "release_type=beta" in (parent / "outputs").read_text()
        original = archive.read_bytes()
        command(beta, "bash", "scripts/ci-packager.sh", "publish", success=False, env=env)
        assert archive.read_bytes() == original
        command(beta, "bash", "scripts/ci-packager.sh", "build", success=False, env=env)
        # Missing files and source/artifact divergence must prevent publishing.
        with zipfile.ZipFile(archive, "a") as package:
            package.writestr("SkillsAlreadyKnown/scripts/private.txt", "must not ship")
        command(beta, "python3", "scripts/verify-ci-release.py", success=False)
        archive.write_bytes(original)

    stable = fixture(parent, "stable")
    prepare = module(stable / "scripts/prepare-ci-release.py", "prepare_stable")
    head = command(stable, "git", "rev-parse", "HEAD").stdout.strip()
    command(stable, "git", "tag", "-a", "v0.4.0", "-m", "stable")
    try:
        prepare.plan(stable, "refs/tags/v0.4.0", 1, 1, head)
    except ValueError:
        pass
    else:
        raise AssertionError("Stable release must require main ancestry")
    command(stable, "git", "update-ref", "refs/remotes/origin/main", head)
    try:
        prepare.plan(stable, "refs/tags/v0.4.0", 1, 1, head)
    except ValueError:
        pass
    else:
        raise AssertionError("Unreleased player changes must be promoted before stable publishing")
    # Promote pending notes and commit/tag them on main, exactly as a real stable release.
    pending = (stable / "patchnote/Unreleased.lua").read_text()
    (stable / "patchnote/0.4.1.lua").write_text(pending.replace('version = "Unreleased"', 'version = "0.4.1"').replace('status = "development"', 'status = "released"').replace(' basedOn = "0.4.0",\n', ''))
    (stable / "patchnote/Unreleased.lua").write_text('return {\n version = "Unreleased",\n status = "development",\n basedOn = "0.4.1",\n additions = {},\n fixes = {},\n}\n')
    toc = stable / "SkillsAlreadyKnown.toc"
    toc.write_text(toc.read_text().replace('## Version: 0.4.0', '## Version: 0.4.1'))
    command(stable, "git", "add", ".")
    command(stable, "git", "commit", "-m", "Stable candidate")
    head = command(stable, "git", "rev-parse", "HEAD").stdout.strip()
    command(stable, "git", "update-ref", "refs/remotes/origin/main", head)
    command(stable, "git", "tag", "-a", "v0.4.1", "-m", "stable")
    tag_object = command(stable, "git", "rev-parse", "v0.4.1").stdout.strip()
    metadata = json.loads(command(stable, sys.executable, "scripts/prepare-ci-release.py", "--ref", "refs/tags/v0.4.1", "--sha", tag_object, env=dict(os.environ, GITHUB_ACTIONS="true")).stdout)
    assert metadata["channel"] == "release" and metadata["version"] == "0.4.1"
    notes = (stable / "release/latest/patchnote.md").read_text()
    assert "Beta-only feature." in notes and "Skills Already Known devient" not in notes
    if packager:
        command(stable, "bash", "scripts/ci-packager.sh", "build", env=env)
        assert "release_type=release" in (parent / "outputs").read_text()
print("PASS: dev beta numbering, main/tag guards, pending-note safety, matching runtime/Markdown and offline packager" + (" integration" if packager else " policy (set SAM_TEST_PACKAGER for integration)"))
