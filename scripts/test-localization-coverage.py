#!/usr/bin/env python3
"""Prevent missing translations and untranslated French UI strings."""
from pathlib import Path
import json
import re

root = Path(__file__).resolve().parent.parent
literal = r'"(?:\\.|[^"\\])*"'

def read_catalog(name):
    text = (root / "traductions" / name).read_text()
    return {json.loads(key): json.loads(value) for key, value in re.findall(
        r'^\s*\[(' + literal + r')\]\s*=\s*(' + literal + r'),\s*$', text, re.M)}

english = read_catalog("en-EN.lua")
french = read_catalog("fr_FR.lua")
assert len(english) > 500 and english.keys() == french.keys()
for file in list(root.glob("*.lua")) + list((root / "data").glob("*.lua")):
    for key in re.findall(r'\bL\((' + literal + r')\)', file.read_text()):
        assert json.loads(key) in english, f"{file.name}: untranslated key {key}"
for file in (root / "patchnote").glob("*.lua"):
    for key in re.findall(r'^\s*(' + literal + r'),\s*$', file.read_text(), re.M):
        assert json.loads(key) in english, f"{file.name}: untranslated patchnote {key}"
for key, value in english.items():
    assert re.findall(r'%[dsf]', key) == re.findall(r'%[dsf]', value), key
    for token in re.findall(r'\|c[0-9a-fA-F]{8}|\|r', key):
        assert key.count(token) == value.count(token), key
print(f"PASS: {len(english)} paired catalog entries, UI/patchnote coverage, formatting placeholders and color codes")
