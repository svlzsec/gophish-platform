"""Canonical authorization validation shared by CLI and automation."""
from __future__ import annotations
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
import yaml

REQUIRED = {"client", "scope_start", "scope_end", "approved_by", "signed_doc_ref", "included_targets", "excluded_targets"}

class AuthorizationError(ValueError):
    """Raised when a client's contractual authorization is unusable."""

def _timestamp(value: Any, field: str) -> datetime:
    if not isinstance(value, str):
        raise AuthorizationError(f"{field} must be an RFC3339 string")
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as exc:
        raise AuthorizationError(f"{field} must be RFC3339") from exc
    if parsed.tzinfo is None:
        raise AuthorizationError(f"{field} must include a timezone")
    return parsed.astimezone(timezone.utc)

def validate_authorization(path: str | Path, client: str | None = None, now: datetime | None = None) -> dict[str, Any]:
    """Load and validate required fields, identity, and active time window."""
    source = Path(path)
    if not source.is_file():
        raise AuthorizationError(f"authorization not found: {source}")
    data = yaml.safe_load(source.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise AuthorizationError("authorization must be a YAML mapping")
    missing = sorted(REQUIRED - data.keys())
    if missing:
        raise AuthorizationError(f"missing required fields: {', '.join(missing)}")
    if client and data["client"] != client:
        raise AuthorizationError("authorization client does not match requested client")
    start, end = _timestamp(data["scope_start"], "scope_start"), _timestamp(data["scope_end"], "scope_end")
    current = (now or datetime.now(timezone.utc)).astimezone(timezone.utc)
    if start >= end:
        raise AuthorizationError("scope_start must be before scope_end")
    if current < start:
        raise AuthorizationError(f"authorization window has not started ({start.isoformat()})")
    if current >= end:
        raise AuthorizationError(f"authorization expired ({end.isoformat()})")
    if not data["approved_by"] or not data["signed_doc_ref"] or not data["included_targets"]:
        raise AuthorizationError("approval, signed document, and included targets cannot be empty")
    return data
