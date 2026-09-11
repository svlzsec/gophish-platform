#!/usr/bin/env bash
set -euo pipefail
client="${1:?usage: destroy.sh <client>}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
env_dir="$root/terraform/environments/$client"
[[ -d "$env_dir" ]] || { echo "Unknown client: $client" >&2; exit 1; }
terraform -chdir="$env_dir" init
terraform -chdir="$env_dir" workspace select "$client"
terraform -chdir="$env_dir" destroy -input=false -auto-approve -var-file=terraform.tfvars
printf '%s destroyed client=%s actor=%s\n' "$(date -u +%FT%TZ)" "$client" "${GITHUB_ACTOR:-$(id -un)}" >> "$root/clients/$client/lifecycle.log"
