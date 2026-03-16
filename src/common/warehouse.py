from __future__ import annotations

from dataclasses import asdict, is_dataclass
from typing import Iterable

import pandas as pd

from src.common.logging import get_logger

logger = get_logger(__name__)


def records_to_dataframe(records: Iterable[object]) -> pd.DataFrame:
    rows = []
    for record in records:
        if is_dataclass(record):
            rows.append(asdict(record))
        elif hasattr(record, "model_dump"):
            rows.append(record.model_dump())
        elif isinstance(record, dict):
            rows.append(record)
        else:
            raise TypeError(f"Unsupported record type: {type(record)!r}")
    return pd.DataFrame(rows)


def upsert_dataframe(table_name: str, frame: pd.DataFrame) -> None:
    logger.info(
        "Simulated warehouse upsert",
        extra={"table_name": table_name, "row_count": len(frame)},
    )
