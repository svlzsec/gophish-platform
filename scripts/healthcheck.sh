#!/usr/bin/env bash
set -euo pipefail
url="${1:?usage: healthcheck.sh <url>}"
for _ in $(seq 1 30); do curl --fail --silent --show-error --max-time 5 "$url" >/dev/null && exit 0; sleep 10; done
echo "Healthcheck timed out: $url" >&2; exit 1
