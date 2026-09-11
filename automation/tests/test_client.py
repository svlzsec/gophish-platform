from datetime import datetime, timezone
import httpx
import respx
from gophish_platform.client import GophishClient
from gophish_platform.models import CampaignRequest

@respx.mock
def test_create_campaign_is_typed():
    route = respx.post("https://gophish.test/api/campaigns/").mock(return_value=httpx.Response(201, json={"id": 7, "name": "test", "status": "Scheduled"}))
    with GophishClient("https://gophish.test", "secret") as client:
        result = client.create_campaign(CampaignRequest(name="test", subject="s", url="https://landing", group_ids=[2], template_id=3, launch_date=datetime(2026, 9, 16, tzinfo=timezone.utc)))
    assert result.id == 7
    assert route.called
    assert route.calls[0].request.url.params["api_key"] == "secret"

@respx.mock
def test_list_campaigns_without_real_http():
    respx.get("https://gophish.test/api/campaigns/").mock(return_value=httpx.Response(200, json=[{"id": 1, "name": "one"}]))
    with GophishClient("https://gophish.test", "key") as client:
        assert client.list_campaigns()[0].name == "one"
