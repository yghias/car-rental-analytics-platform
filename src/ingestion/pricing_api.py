from __future__ import annotations

import argparse
from datetime import UTC, datetime

from src.common.logging import get_logger
from src.common.schemas import PricingEventRecord
from src.common.storage import raw_path, write_json_lines
from src.common.warehouse import records_to_dataframe, upsert_dataframe

logger = get_logger(__name__)


def fetch_pricing_updates() -> list[PricingEventRecord]:
    payload = [
        {
            "pricing_event_id": "P1001",
            "location_id": "DTW01",
            "vehicle_class": "SUV",
            "channel": "direct_web",
            "rate_amount": 92.5,
            "effective_start_ts": "2026-03-01T00:00:00Z",
            "effective_end_ts": "2026-03-02T00:00:00Z",
            "updated_at": "2026-03-01T07:50:00Z",
        },
        {
            "pricing_event_id": "P1002",
            "location_id": "ORD01",
            "vehicle_class": "ECONOMY",
            "channel": "corporate",
            "rate_amount": 55.0,
            "effective_start_ts": "2026-03-01T00:00:00Z",
            "effective_end_ts": "2026-03-03T00:00:00Z",
            "updated_at": "2026-03-01T07:55:00Z",
        },
    ]
    return [PricingEventRecord(**row) for row in payload]


def run() -> None:
    ingest_ts = datetime.now(tz=UTC)
    records = fetch_pricing_updates()
    write_json_lines([record.model_dump(mode="json") for record in records], raw_path("pricing_events", ingest_ts))
    upsert_dataframe("staging.stg_pricing_events", records_to_dataframe(records))
    logger.info("Completed pricing ingestion", extra={"row_count": len(records)})


def main() -> None:
    parser = argparse.ArgumentParser(description="Ingest pricing updates")
    parser.parse_args()
    run()


if __name__ == "__main__":
    main()
