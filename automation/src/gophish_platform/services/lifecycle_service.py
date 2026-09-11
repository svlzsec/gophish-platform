"""Defense-in-depth lifecycle check; AWS Scheduler remains the primary cutoff."""
from __future__ import annotations
from datetime import datetime, timezone
from pathlib import Path
import subprocess
import yaml

def destroy_if_expired(authorization_path: str | Path, *, now: datetime | None = None) -> bool:
    path = Path(authorization_path).resolve()
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    end = datetime.fromisoformat(data["scope_end"].replace("Z", "+00:00"))
    if (now or datetime.now(timezone.utc)).astimezone(timezone.utc) < end.astimezone(timezone.utc): return False
    repo = next(parent for parent in path.parents if (parent / "scripts" / "destroy.sh").is_file())
    subprocess.run([str(repo / "scripts" / "destroy.sh"), data["client"]], check=True)
    return True
