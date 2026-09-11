#!/usr/bin/env python3
"""Parse repository-owned YAML files as a lightweight local/CI check."""

from pathlib import Path

import yaml


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    paths = sorted((root / ".github" / "workflows").glob("*.yml"))
    paths.extend(sorted((root / "clients").rglob("*.yaml")))
    for path in paths:
        yaml.safe_load(path.read_text(encoding="utf-8"))
        print(f"OK {path.relative_to(root)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
