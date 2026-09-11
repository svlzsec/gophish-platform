from datetime import datetime, timezone
from pathlib import Path
from unittest.mock import patch
from gophish_platform.services.lifecycle_service import destroy_if_expired

def test_not_expired_does_not_destroy(tmp_path: Path):
    scripts = tmp_path / "scripts"; scripts.mkdir(); (scripts / "destroy.sh").write_text("")
    auth = tmp_path / "clients" / "acme" / "authorization.yaml"; auth.parent.mkdir(parents=True)
    auth.write_text("client: acme\nscope_end: '2026-09-22T00:00:00Z'\n")
    with patch("subprocess.run") as run:
        assert not destroy_if_expired(auth, now=datetime(2026, 9, 20, tzinfo=timezone.utc)); run.assert_not_called()

def test_expired_invokes_destroy(tmp_path: Path):
    scripts = tmp_path / "scripts"; scripts.mkdir(); destroy = scripts / "destroy.sh"; destroy.write_text("")
    auth = tmp_path / "clients" / "acme" / "authorization.yaml"; auth.parent.mkdir(parents=True)
    auth.write_text("client: acme\nscope_end: '2026-09-22T00:00:00Z'\n")
    with patch("subprocess.run") as run:
        assert destroy_if_expired(auth, now=datetime(2026, 9, 23, tzinfo=timezone.utc)); run.assert_called_once_with([str(destroy), "acme"], check=True)
