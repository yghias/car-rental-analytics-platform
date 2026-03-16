from __future__ import annotations

import argparse
from datetime import UTC, datetime

from src.common.logging import get_logger
from src.common.storage import raw_path, write_json_lines
from src.common.warehouse import records_to_dataframe, upsert_dataframe

logger = get_logger(__name__)


def fetch_maintenance_events() -> list[dict]:
    return [
        {
            "maintenance_event_id": "M1001",
            "vehicle_id": "V1002",
            "location_id": "ORD01",
            "maintenance_type": "brake_service",
            "opened_at": "2026-03-01T03:00:00Z",
            "closed_at": "2026-03-01T08:00:00Z",
            "estimated_cost_amount": 420.0,
        }
    ]


def run() -> None:
    ingest_ts = datetime.now(tz=UTC)
    records = fetch_maintenance_events()
    write_json_lines(records, raw_path("maintenance", ingest_ts))
    upsert_dataframe("staging.stg_maintenance_events", records_to_dataframe(records))
    logger.info("Completed maintenance ingestion", extra={"row_count": len(records)})


def main() -> None:
    parser = argparse.ArgumentParser(description="Load maintenance events")
    parser.parse_args()
    run()


if __name__ == "__main__":
    main()
