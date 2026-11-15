#!/usr/bin/env python3
"""Validate generation and packaging without touching delivered archives or WoW."""
from pathlib import Path
import os
import importlib.util
import shutil
import subprocess
import sys
import tempfile
import zipfile

root = Path(__file__).resolve().parent.parent

def run(*args, success=True, env=None):
    result = subprocess.run(args, text=True, capture_output=True, env=env)
    assert (result.returncode == 0) == success, result.stdout + result.stderr
    return result

# Public exports must not silently fall back to French in the English section.
spec = importlib.util.spec_from_file_location("patchnotes_export", root / "scripts/generate-patchnotes.py")
export = importlib.util.module_from_spec(spec)
spec.loader.exec_module(export)
source = 'return {\n additions = {"Conseil sans traduction"},\n fixes = {},\n}\n'
try:
    export.render_markdown("Test", "1.0.0", source, export.read_catalogs(root))
except ValueError as error:
    assert "Missing en-EN patchnote translation" in str(error)
else:
    raise AssertionError("Missing English translations must stop public exports")
assert export.render_markdown("Test", "1.0.0", 'return {\n additions = {},\n fixes = {},\n}') == "# Test — 1.0.0\n"

with tempfile.TemporaryDirectory() as temporary:
    fixture = Path(temporary) / "addon"
    (fixture / "scripts").mkdir(parents=True)
    (fixture / "data").mkdir()
    shutil.copytree(root / "patchnote", fixture / "patchnote")
    shutil.copytree(root / "traductions", fixture / "traductions")
    for script in ("generate-patchnotes.py", "package.sh", "install-local.sh"):
        shutil.copy(root / "scripts" / script, fixture / "scripts" / script)
    shutil.copy(root / "SkillsAlreadyKnown.toc", fixture)
    generator = fixture / "scripts/generate-patchnotes.py"
    run(sys.executable, str(generator))
    output = fixture / "data/Patchnotes.lua"
    before = output.read_bytes()
    run(sys.executable, str(generator), "--check")
    run(sys.executable, str(generator))
    assert output.read_bytes() == before
    extra = fixture / "patchnote/0.10.0.lua"
    extra.write_text('return {\n version = "0.10.0",\n status = "released",\n additions = {},\n fixes = {},\n}\n')
    run(sys.executable, str(generator), "--check", success=False)
    run(sys.executable, str(generator))
    text = output.read_text()
    assert text.index('version = "0.10.0"') < text.index('version = "0.3.3"')
    extra.unlink()
    run("bash", str(fixture / "scripts/package.sh"))
    version = next(line.split(":", 1)[1].strip() for line in (fixture / "SkillsAlreadyKnown.toc").read_text().splitlines() if line.startswith("## Version:"))
    archive = fixture / f"release/SkillsAndMore-{version}.zip"
    original = archive.read_bytes()
    latest = fixture / "release/latest"
    latest_archive = latest / archive.name
    notes = latest / "patchnote.md"
    assert latest_archive.read_bytes() == original
    markdown_before = notes.read_text()
    assert markdown_before.startswith(f"# Skills & More — {version}\n")
    assert markdown_before.index("## English") < markdown_before.index("## Français")
    assert "### New features" in markdown_before and "### Bug fixes" in markdown_before
    assert "### Ajouts de fonctionnalités" in markdown_before and "### Corrections de bugs" in markdown_before
    english, french = markdown_before.split("## Français", 1)
    assert "De nouveaux repères" not in english and "De nouveaux repères" in french
    assert "New markers distinguish" in english
    assert "Unreleased" not in markdown_before and "local SAK" not in markdown_before
    generated_before = output.read_bytes()
    run(sys.executable, str(generator), "--format", "markdown", "--check")
    assert output.read_bytes() == generated_before
    notes.write_text("stale")
    run(sys.executable, str(generator), "--format", "markdown", "--check", success=False)
    run("bash", str(fixture / "scripts/package.sh"), "--refresh-latest")
    assert notes.read_text() == markdown_before and archive.read_bytes() == original
    latest_archive.unlink()
    stale = latest / "SkillsAlreadyKnown-0.0.0.zip"
    stale.write_bytes(b"old latest copy")
    stale_new = latest / "SkillsAndMore-0.0.0.zip"
    stale_new.write_bytes(b"older branded copy")
    keep = latest / "keep.txt"
    keep.write_text("preserve unrelated files")
    run("bash", str(fixture / "scripts/package.sh"), "--refresh-latest")
    assert latest_archive.read_bytes() == original and not stale.exists() and not stale_new.exists() and keep.exists()
    # A source edit must not silently pair new notes with an old immutable ZIP.
    release_notes = fixture / f"patchnote/{version}.lua"
    saved = release_notes.read_text()
    for language in ("en-EN", "fr_FR"):
        catalog = fixture / "traductions" / (language + ".lua")
        source = catalog.read_text(); end = source.rfind("}")
        catalog.write_text(source[:end] + '  ["Unpackaged change"] = "Unpackaged change",\n' + source[end:])
    release_notes.write_text(saved.replace("additions = {", 'additions = {\n    "Unpackaged change",', 1))
    run("bash", str(fixture / "scripts/package.sh"), "--refresh-latest", success=False)
    assert archive.read_bytes() == original and notes.read_text() == markdown_before
    release_notes.write_text(saved)
    with zipfile.ZipFile(archive) as package:
        names = package.namelist()
        assert "SkillsAlreadyKnown/data/Patchnotes.lua" in names
        assert not any("/patchnote/" in name or "/scripts/" in name or name.endswith("AGENTS.md") for name in names)
        assert b'"Unreleased"' in package.read("SkillsAlreadyKnown/data/Patchnotes.lua")
    run("bash", str(fixture / "scripts/package.sh"), success=False)
    assert archive.read_bytes() == original
    legacy = fixture / f"release/SkillsAlreadyKnown-{version}.zip"
    legacy.write_bytes(original)
    archive.unlink()
    run("bash", str(fixture / "scripts/package.sh"), success=False)
    run("bash", str(fixture / "scripts/package.sh"), "--refresh-latest")
    assert legacy.read_bytes() == original and (latest / legacy.name).read_bytes() == original
    assert not archive.exists(), "Do not rebuild existing releases under a new filename"
    wow = Path(temporary) / "wow"
    (wow / "Interface/AddOns").mkdir(parents=True)
    env = dict(os.environ, SAK_WOW_ROOT=str(wow))
    output.write_text("stale source intentionally retained during dry run")
    run("bash", str(fixture / "scripts/install-local.sh"), "--dry-run", env=env)
    assert output.read_text() == "stale source intentionally retained during dry run"
    assert not (wow / "Interface/AddOns/SkillsAlreadyKnown_dev").exists()
    run("bash", str(fixture / "scripts/install-local.sh"), env=env)
    installed = wow / "Interface/AddOns/SkillsAlreadyKnown_dev"
    assert "SkillsAlreadyKnown_dev" in (installed / "data/Patchnotes.lua").read_text()
    installed_toc = (installed / "SkillsAlreadyKnown_dev.toc").read_text()
    assert "SkillsAlreadyKnown_dev_dev" not in installed_toc
    assert "## OptionalDeps: TrainerSpells\n" in installed_toc
    assert not (installed / "patchnote").exists()
    assert not (installed / "Patchnotes.lua").exists()
    assert output.read_text() == "stale source intentionally retained during dry run"
print("PASS: Lua/Markdown generation, latest ZIP/notes pairing, stale checks, archive protection, exclusions and staged DEV generation/dry-run")
