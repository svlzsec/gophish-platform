#!/usr/bin/env bash
set -euo pipefail
client="${1:?usage: deploy.sh <client>}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ "${GITHUB_ACTIONS:-}" == "true" && -n "${ACTIONS_ID_TOKEN_REQUEST_TOKEN:-}" ]] || { echo "ERROR: apply is restricted to GitHub Actions OIDC" >&2; exit 1; }
echo "[1/4] Validating authorization"
python "$root/scripts/check_authorization.py" --client "$client"
env_dir="$root/terraform/environments/$client"
[[ -d "$env_dir" ]] || { echo "Unknown client: $client" >&2; exit 1; }
echo "[2/4] Initializing Terraform"
terraform -chdir="$env_dir" init
echo "[3/4] Selecting isolated workspace and applying"
terraform -chdir="$env_dir" workspace select "$client" || terraform -chdir="$env_dir" workspace new "$client"
terraform -chdir="$env_dir" apply -input=false -auto-approve -var-file=terraform.tfvars
echo "[4/4] Health check"
"$root/scripts/healthcheck.sh" "$(terraform -chdir="$env_dir" output -raw landing_url)"
