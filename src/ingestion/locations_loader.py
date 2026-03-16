from __future__ import annotations

import argparse
from datetime import UTC, datetime

from src.common.logging import get_logger
from src.common.storage import raw_path, write_json_lines
from src.common.warehouse import records_to_dataframe, upsert_dataframe

logger = get_logger(__name__)


def load_locations() -> list[dict]:
    return [
        {
            "location_id": "DTW01",
            "location_name": "Detroit Airport",
            "city": "Detroit",
            "state": "MI",
            "region": "MIDWEST",
            "airport_flag": True,
            "updated_at": "2026-03-01T00:00:00Z",
        },
        {
            "location_id": "ORD01",
            "location_name": "Chicago O'Hare",
            "city": "Chicago",
            "state": "IL",
            "region": "MIDWEST",
            "airport_flag": True,
            "updated_at": "2026-03-01T00:00:00Z",
        },
    ]


def run() -> None:
    ingest_ts = datetime.now(tz=UTC)
    records = load_locations()
    write_json_lines(records, raw_path("locations", ingest_ts))
    upsert_dataframe("staging.stg_locations", records_to_dataframe(records))
    logger.info("Completed location load", extra={"row_count": len(records)})


def main() -> None:
    parser = argparse.ArgumentParser(description="Load branch locations")
    parser.parse_args()
    run()


if __name__ == "__main__":
    main()
