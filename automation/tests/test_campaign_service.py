from pathlib import Path
from unittest.mock import patch

from gophish_platform.models import Campaign
from gophish_platform.services.campaign_service import launch_campaign


class FakeClient:
    def __init__(self) -> None:
        self.template = None
        self.page = None
        self.campaign = None

    def create_template(self, template):
        self.template = template
        return {"id": 11}

    def create_landing_page(self, page):
        self.page = page
        return {"id": 12}

    def create_campaign(self, campaign):
        self.campaign = campaign
        return Campaign(id=13, name=campaign.name)


def test_launch_connects_email_and_landing_page():
    repo = Path(__file__).resolve().parents[2]
    client = FakeClient()
    with patch("gophish_platform.services.campaign_service.validate_authorization") as validate:
        result = launch_campaign(repo / "clients/acme-corp/config.yaml", client=client)  # type: ignore[arg-type]

    validate.assert_called_once()
    assert result.id == 13
    assert client.page.capture_credentials is False
    assert client.page.capture_passwords is False
    assert client.campaign.template_id == 11
    assert client.campaign.page_id == 12
    assert client.campaign.sending_profile_id == 1
