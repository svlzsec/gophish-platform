"""Orchestrate REST resources after enforcing contractual authorization."""
from __future__ import annotations
import json
from pathlib import Path
import boto3
from scripts.authorization import validate_authorization
from gophish_platform.client import GophishClient
from gophish_platform.config import load_client_config
from gophish_platform.models import Campaign, CampaignRequest, TemplateRequest

def launch_campaign(client_config_path: str | Path, *, client: GophishClient | None = None) -> Campaign:
    """Validate scope, load a catalog template, and create a campaign via REST."""
    config_path = Path(client_config_path).resolve()
    config = load_client_config(config_path)
    repo = next(parent for parent in config_path.parents if (parent / "catalog").is_dir())
    validate_authorization(repo / config.authorization_path, config.client)
    template_data = json.loads((repo / "catalog" / config.catalog_template).read_text(encoding="utf-8"))
    owned = client is None
    api_key = boto3.client("ssm").get_parameter(Name=config.api_key_parameter, WithDecryption=True)["Parameter"]["Value"] if owned else ""
    api = client or GophishClient(config.base_url, api_key)
    try:
        template = api.create_template(TemplateRequest.model_validate(template_data))
        request = CampaignRequest.model_validate(config.campaign | {"template_id": template["id"]})
        return api.create_campaign(request)
    finally:
        if owned: api.close()
