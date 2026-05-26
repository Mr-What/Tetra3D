#!/usr/bin/env python3
import csv
import re
import sys

if len(sys.argv) < 2:
    print("Usage: python3 extractProbeAccuracy.py accuracyLog.txt [output.csv]")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2] if len(sys.argv) > 2 else "probe_accuracy.csv"

pos_re = re.compile(
    r'PROBE_ACCURACY at X:?\s*([+-]?\d+(?:\.\d+)?)\s+Y:?\s*([+-]?\d+(?:\.\d+)?)',
    re.IGNORECASE
)

res_re = re.compile(
    r'probe accuracy results:\s*'
    r'maximum\s+([+-]?\d+(?:\.\d+)?),\s*'
    r'minimum\s+([+-]?\d+(?:\.\d+)?),\s*'
    r'range\s+([+-]?\d+(?:\.\d+)?),\s*'
    r'average\s+([+-]?\d+(?:\.\d+)?),\s*'
    r'median\s+([+-]?\d+(?:\.\d+)?),\s*'
    r'standard deviation\s+([+-]?\d+(?:\.\d+)?)',
    re.IGNORECASE
)

with open(input_file, "r", encoding="utf-8", errors="replace") as f:
    text = f.read()

rows = []
current_xy = None

for line in text.splitlines():
    m = pos_re.search(line)
    if m:
        current_xy = (m.group(1), m.group(2))
        continue

    m = res_re.search(line)
    if m and current_xy is not None:
        rows.append([
            current_xy[0],
            current_xy[1],
            m.group(1),  # max
            m.group(2),  # min
            m.group(3),  # range
            m.group(4),  # average
            m.group(5),  # median
            m.group(6),  # std dev
        ])
        current_xy = None

with open(output_file, "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow([
        "%X", "Y", "max", "min", "range",
        "average", "median", "standard_deviation"
    ])
    w.writerows(rows)

print(f"Wrote {len(rows)} rows to {output_file}")
