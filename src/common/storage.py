from __future__ import annotations

import json
from datetime import datetime
from pathlib import Path
from typing import Iterable

from src.common.logging import get_logger
from src.common.settings import SETTINGS

logger = get_logger(__name__)


def _localize_uri(uri: str) -> Path:
    if uri.startswith("s3://"):
        safe_path = uri.replace("s3://", "/tmp/s3/")
        return Path(safe_path)
    return Path(uri)


def write_json_lines(records: Iterable[dict], path: str) -> Path:
    target = _localize_uri(path)
    target.parent.mkdir(parents=True, exist_ok=True)
    with target.open("w", encoding="utf-8") as handle:
        for record in records:
            handle.write(json.dumps(record, default=str) + "\n")
    logger.info("Wrote records", extra={"path": str(target)})
    return target


def raw_path(domain: str, ingest_ts: datetime) -> str:
    return (
        f"{SETTINGS.raw_bucket}/{domain}/ingest_date={ingest_ts:%Y-%m-%d}/"
        f"ingest_hour={ingest_ts:%H}/{domain}_{ingest_ts:%Y%m%dT%H%M%S}.jsonl"
    )
