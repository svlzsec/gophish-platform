from datetime import datetime, timezone
import httpx
import respx
from gophish_platform.client import GophishClient
from gophish_platform.models import CampaignRequest, LandingPageRequest

@respx.mock
def test_create_campaign_is_typed():
    route = respx.post("https://gophish.test/api/campaigns/").mock(return_value=httpx.Response(201, json={"id": 7, "name": "test", "status": "Scheduled"}))
    with GophishClient("https://gophish.test", "secret") as client:
        result = client.create_campaign(CampaignRequest(name="test", url="https://landing", group_ids=[2], template_id=3, page_id=4, sending_profile_id=5, launch_date=datetime(2026, 9, 16, tzinfo=timezone.utc)))
    assert result.id == 7
    assert route.called
    assert route.calls[0].request.url.params["api_key"] == "secret"
    assert route.calls[0].request.content
    assert b'"page":{"id":4}' in route.calls[0].request.content
    assert b'"smtp":{"id":5}' in route.calls[0].request.content

@respx.mock
def test_list_campaigns_without_real_http():
    respx.get("https://gophish.test/api/campaigns/").mock(return_value=httpx.Response(200, json=[{"id": 1, "name": "one"}]))
    with GophishClient("https://gophish.test", "key") as client:
        assert client.list_campaigns()[0].name == "one"

@respx.mock
def test_create_landing_page_disables_credential_capture():
    route = respx.post("https://gophish.test/api/pages/").mock(return_value=httpx.Response(201, json={"id": 4, "name": "page"}))
    with GophishClient("https://gophish.test", "key") as client:
        page = client.create_landing_page(LandingPageRequest(name="page", html="<p>Safe</p>"))
    assert page["id"] == 4
    assert b'"capture_passwords":false' in route.calls[0].request.content
