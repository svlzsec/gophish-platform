"""Small typed HTTP client for the installed Gophish REST API."""
from __future__ import annotations
from typing import Any, TypeVar
import httpx
from pydantic import BaseModel, TypeAdapter
from .models import Campaign, CampaignRequest, GroupRequest, LandingPageRequest, TemplateRequest

T = TypeVar("T", bound=BaseModel)
class GophishClient:
    """Call Gophish endpoints; this client neither sends mail nor collects data itself."""
    def __init__(self, base_url: str, api_key: str, *, verify: bool = True, transport: httpx.BaseTransport | None = None) -> None:
        self._http = httpx.Client(base_url=base_url.rstrip("/"), params={"api_key": api_key}, verify=verify, transport=transport, timeout=20)
    def _request(self, method: str, path: str, json: Any = None) -> Any:
        response = self._http.request(method, path, json=json)
        response.raise_for_status()
        return response.json()
    def create_campaign(self, campaign: CampaignRequest) -> Campaign:
        groups = [{"id": identifier} for identifier in campaign.group_ids]
        body = campaign.model_dump(
            mode="json", exclude={"group_ids", "template_id", "page_id", "sending_profile_id"}
        ) | {
            "groups": groups,
            "template": {"id": campaign.template_id},
            "page": {"id": campaign.page_id},
            "smtp": {"id": campaign.sending_profile_id},
        }
        return Campaign.model_validate(self._request("POST", "/api/campaigns/", body))
    def list_campaigns(self) -> list[Campaign]:
        return TypeAdapter(list[Campaign]).validate_python(self._request("GET", "/api/campaigns/"))
    def campaign_results(self, campaign_id: int) -> Campaign:
        return Campaign.model_validate(self._request("GET", f"/api/campaigns/{campaign_id}/results"))
    def create_group(self, group: GroupRequest) -> dict[str, Any]:
        return self._request("POST", "/api/groups/", group.model_dump(mode="json"))
    def list_groups(self) -> list[dict[str, Any]]:
        return self._request("GET", "/api/groups/")
    def create_template(self, template: TemplateRequest) -> dict[str, Any]:
        return self._request("POST", "/api/templates/", template.model_dump(mode="json"))
    def create_landing_page(self, page: LandingPageRequest) -> dict[str, Any]:
        return self._request("POST", "/api/pages/", page.model_dump(mode="json"))
    def close(self) -> None:
        self._http.close()
    def __enter__(self) -> "GophishClient": return self
    def __exit__(self, *_: object) -> None: self.close()
