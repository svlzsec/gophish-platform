import csv
from pathlib import Path
from gophish_platform.models import Campaign
from gophish_platform.services.report_service import export_results

class FakeClient:
    def campaign_results(self, _campaign_id: int) -> Campaign:
        return Campaign(id=3, name="x", results=[{"email": "u@example.test", "timeline": [{"message": "Clicked Link", "time": "2026-09-16T01:00:00Z"}, {"message": "Submitted Data", "time": "2026-09-16T01:01:00Z"}]}])

def test_export_results(tmp_path: Path):
    destination = export_results(FakeClient(), 3, tmp_path)  # type: ignore[arg-type]
    rows = list(csv.DictReader(destination.open()))
    assert [row["event"] for row in rows] == ["click", "credential_submission"]
