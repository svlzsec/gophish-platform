from datetime import datetime, timezone
from pathlib import Path
import pytest
from scripts.authorization import AuthorizationError, validate_authorization

NOW = datetime(2026, 9, 16, tzinfo=timezone.utc)
VALID = """client: acme\nscope_start: '2026-09-15T00:00:00Z'\nscope_end: '2026-09-22T00:00:00Z'\napproved_by: approver\nsigned_doc_ref: s3://doc\nincluded_targets: ['*.acme.test']\nexcluded_targets: []\n"""
def test_missing_file(tmp_path: Path):
    with pytest.raises(AuthorizationError, match="not found"): validate_authorization(tmp_path / "none", now=NOW)
def test_missing_field(tmp_path: Path):
    path = tmp_path / "a.yaml"; path.write_text(VALID.replace("approved_by: approver\n", ""))
    with pytest.raises(AuthorizationError, match="missing required"): validate_authorization(path, now=NOW)
def test_expired(tmp_path: Path):
    path = tmp_path / "a.yaml"; path.write_text(VALID)
    with pytest.raises(AuthorizationError, match="expired"): validate_authorization(path, now=datetime(2026, 9, 23, tzinfo=timezone.utc))
def test_valid(tmp_path: Path):
    path = tmp_path / "a.yaml"; path.write_text(VALID)
    assert validate_authorization(path, "acme", NOW)["approved_by"] == "approver"
