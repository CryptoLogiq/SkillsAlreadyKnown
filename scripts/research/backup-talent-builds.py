#!/usr/bin/env python3
"""Local research snapshots; never loaded or shipped with the addon."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, urllib.request

ROOT = Path(__file__).resolve().parent / "talent-builds-local"

def lua(value, indent=0):
    if value is None: return "nil"
    if isinstance(value, bool): return str(value).lower()
    if isinstance(value, (int, float)): return str(value)
    if isinstance(value, str): return json.dumps(value, ensure_ascii=False)
    rows = list(enumerate(value, 1)) if isinstance(value, list) else list(value.items())
    return "{\n" + "".join(" "*(indent+2)+"["+lua(k)+"] = "+lua(v,indent+2)+",\n" for k,v in rows) + " "*indent+"}"

def main():
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    target = ROOT / stamp
    (target / "raw").mkdir(parents=True)
    records = []
    def fetch(url, filename):
        record = {"url": url, "file": filename}
        records.append(record)
        try:
            data = urllib.request.urlopen(url, timeout=40).read()
            (target / "raw" / filename).write_bytes(data)
            record.update(status="saved", bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
            return data
        except Exception as error:
            record.update(status="unavailable", error=str(error))
    data = json.loads(fetch("https://talentsforever.com/data.json", "data.json"))
    raw = fetch("https://talentsforever.com/popular.js", "popular.js").decode()
    popular = json.JSONDecoder().raw_decode(raw[raw.index("{"):])[0]
    fetch("https://talentsforever.com/", "index.html")
    specs = 0
    for cls, talents in data["talents"].items():
        stats = popular["classes"].get(cls, {})
        entries = {}
        for tree in talents["trees"]:
            name = tree["name"]
            specs += 1
            entries[name] = {
                "tree": tree,
                "population": stats.get("specN", {}).get(name),
                "selectionByTree": stats.get("pickBy", {}).get(name),
                "popularBuilds": [dict(b, url="https://talentsforever.com/"+b["code"]) for b in stats.get("top", []) if b.get("lead")==name],
                "interpretation": "Observed popularity, not an expert recommendation or proof of PvP/PvE suitability.",
            }
        folder = target / "classes"
        folder.mkdir(exist_ok=True)
        (folder / (cls.lower()+".lua")).write_text("-- Local snapshot; CC BY 4.0, talentsforever.com.\nreturn "+lua({"class":cls,"source":talents.get("source"),"specializations":entries})+"\n")
        for page in ["builds", "leveling"]:
            fetch("https://talentsforever.com/"+cls.lower()+"/"+page, cls.lower()+"-"+page+".html")
    fetch("https://www.wowhead.com/forever/guides", "wowhead-guides.html")
    manifest = {"retrievedUTC":stamp,"exportGenerated":data.get("generated"),"popularGenerated":popular.get("generated"),"license":data.get("license"),"attribution":data.get("attribution"),"classes":len(data["talents"]),"trees":specs,"files":records}
    (target / "manifest.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n")
    (target / "README.md").write_text("# Local talent research snapshot\n\nSource: https://talentsforever.com/ — Chris Baldwin, CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/). Preserve attribution and provenance.\n\nRaw export and public class builds/leveling pages are retained unchanged; classes/*.lua are readable derived tables. Selection matrices follow the exported tree/talent order. Empty popularBuilds means no matching build in the published top list, not that the specialization lacks a viable build.\n\nPopularity is not expert advice. Do not infer a role from the tree name, or PvP/PvE suitability from pick rates. Inspect the current spell mechanics and guide context. Source generation dates may differ from retrieval; beta/hotfix caveats remain in the raw export. No automatic import into runtime data.\n\nWowhead availability is recorded in manifest.json; failed downloads are not archived guides.\n")
    print(target)
    print(f"Archived {len(data['talents'])} classes / {specs} trees; {sum(r['status']=='saved' for r in records)} files saved.")
    for r in records:
        if r["status"]!="saved": print(r["url"],r["error"])

if __name__ == "__main__":
    main()
