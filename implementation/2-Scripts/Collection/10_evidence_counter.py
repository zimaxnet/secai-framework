
#!/usr/bin/env python3
import json, os, csv, glob
ROOT=os.path.dirname(os.path.dirname(__file__))
OUT=os.path.join(ROOT,"out")
rows=[]
for path in sorted(glob.glob(os.path.join(OUT,"*.json"))):
    name=os.path.basename(path)
    try:
        with open(path) as f:
            data=json.load(f)
        if isinstance(data, list):
            count=len(data)
        elif isinstance(data, dict):
            # Count top-level keys or items list if present
            count=len(data)
            if "value" in data and isinstance(data["value"], list):
                count=len(data["value"])
        else:
            count=0
    except Exception:
        count=0
    rows.append({"artifact": name, "evidence_count": count})
with open(os.path.join(OUT,"evidence_counts.csv"),"w",newline="") as f:
    w=csv.DictWriter(f, fieldnames=["artifact","evidence_count"])
    w.writeheader()
    w.writerows(rows)
print("Wrote", os.path.join(OUT,"evidence_counts.csv"))
