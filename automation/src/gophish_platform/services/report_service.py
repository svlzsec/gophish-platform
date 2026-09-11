"""Export the minimum campaign event dataset to a client-owned CSV."""
from __future__ import annotations
import csv
from pathlib import Path
from gophish_platform.client import GophishClient

def export_results(client: GophishClient, campaign_id: int, client_dir: str | Path) -> Path:
    campaign = client.campaign_results(campaign_id)
    destination = Path(client_dir) / "reports" / f"campaign-{campaign_id}.csv"
    destination.parent.mkdir(parents=True, exist_ok=True)
    fields = ["email", "event", "timestamp"]
    with destination.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields); writer.writeheader()
        for result in campaign.results:
            email = result.get("email", "")
            for event in result.get("timeline", []):
                message = str(event.get("message", "")).lower()
                kind = "credential_submission" if "submitted" in message else "click" if "clicked" in message else None
                if kind: writer.writerow({"email": email, "event": kind, "timestamp": event.get("time", "")})
    return destination
