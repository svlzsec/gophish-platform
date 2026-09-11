"""Typed API and client configuration models."""
from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field

class CampaignRequest(BaseModel):
    name: str
    launch_date: datetime | None = None
    url: str
    group_ids: list[int] = Field(min_length=1)
    template_id: int
    page_id: int
    sending_profile_id: int

class Campaign(BaseModel):
    model_config = ConfigDict(extra="allow")
    id: int
    name: str
    status: str | None = None
    results: list[dict] = Field(default_factory=list)

class GroupRequest(BaseModel):
    name: str
    targets: list[dict[str, str]]

class TemplateRequest(BaseModel):
    name: str
    subject: str
    html: str
    text: str = ""


class LandingPageRequest(BaseModel):
    """Landing page accepted by the Gophish REST API."""

    name: str
    html: str
    capture_credentials: bool = False
    capture_passwords: bool = False

class ClientConfig(BaseModel):
    client: str
    base_url: str
    api_key_parameter: str
    authorization_path: str
    catalog_template: str
    campaign: dict
