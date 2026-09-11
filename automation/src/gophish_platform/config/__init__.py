"""Configuration loaders."""
from pathlib import Path
import yaml
from gophish_platform.models import ClientConfig

def load_client_config(path: str | Path) -> ClientConfig:
    return ClientConfig.model_validate(yaml.safe_load(Path(path).read_text(encoding="utf-8")))
