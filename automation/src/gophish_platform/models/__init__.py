"""Typed API and client configuration models."""
from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field

class CampaignRequest(BaseModel):
    name: str
    subject: str
    launch_date: datetime | None = None
    url: str
    group_ids: list[int] = Field(min_length=1)
    template_id: int

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

class ClientConfig(BaseModel):
    client: str
    base_url: str
    api_key_parameter: str
    authorization_path: str
    catalog_template: str
    campaign: dict
