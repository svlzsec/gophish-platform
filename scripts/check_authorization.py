#!/usr/bin/env python3
"""CLI gate for campaign authorization."""
from __future__ import annotations
import argparse
from pathlib import Path
from authorization import AuthorizationError, validate_authorization

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--client", required=True)
    args = parser.parse_args()
    path = Path(__file__).resolve().parents[1] / "clients" / args.client / "authorization.yaml"
    try:
        auth = validate_authorization(path, args.client)
    except AuthorizationError as exc:
        print(f"DENIED: {exc}")
        return 1
    print(f"AUTHORIZED client={auth['client']} start={auth['scope_start']} end={auth['scope_end']} approved_by={auth['approved_by']}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
