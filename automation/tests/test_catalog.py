"""Validate reusable catalog bundles without contacting Gophish."""

import json
from pathlib import Path

from gophish_platform.models import LandingPageRequest, TemplateRequest


CATALOG = Path(__file__).resolve().parents[2] / "catalog"


def test_every_catalog_email_has_a_safe_connected_landing():
    bundles = sorted(CATALOG.glob("*/*.json"))
    assert len(bundles) >= 4
    for email_path in bundles:
        data = json.loads(email_path.read_text(encoding="utf-8"))
        landing_name = data.pop("landing_page_file")
        template = TemplateRequest.model_validate(data)
        landing_html = (email_path.parent / landing_name).read_text(encoding="utf-8")
        page = LandingPageRequest(name=f"{template.name} landing", html=landing_html)

        assert "{{.URL}}" in template.html
        assert "{{.TrackingURL}}" in template.html
        assert "<form" in page.html
        assert 'method="post"' in page.html
        assert 'type="password"' not in page.html
        assert not page.capture_credentials
        assert not page.capture_passwords
