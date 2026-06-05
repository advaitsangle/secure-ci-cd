#!/usr/bin/env python3
"""Fail the build if a SARIF report contains any findings.

Each scanner in the pipeline is configured to emit only high-severity
findings, so any result here represents a high-severity issue that must
block the merge. Usage: sarif_gate.py <file.sarif> [<file.sarif> ...]
"""
import json
import sys

exit_code = 0

for path in sys.argv[1:]:
    try:
        with open(path) as f:
            sarif = json.load(f)
    except FileNotFoundError:
        print(f"::error::{path}: SARIF report not found — the scan did not produce output.")
        exit_code = 1
        continue
    except json.JSONDecodeError as e:
        print(f"::error::{path}: invalid SARIF ({e}).")
        exit_code = 1
        continue

    count = sum(len(run.get("results", [])) for run in sarif.get("runs", []))
    if count:
        print(f"::error::{path}: {count} high-severity finding(s) — blocking merge.")
        exit_code = 1
    else:
        print(f"{path}: no findings.")

sys.exit(exit_code)
