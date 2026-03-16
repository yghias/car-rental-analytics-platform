from __future__ import annotations

import argparse
from datetime import UTC, datetime

from src.common.logging import get_logger
from src.common.schemas import FleetRecord
from src.common.storage import raw_path, write_json_lines
from src.common.warehouse import records_to_dataframe, upsert_dataframe

logger = get_logger(__name__)


def fetch_fleet_snapshot() -> list[FleetRecord]:
    payload = [
        {
            "vehicle_id": "V1001",
            "vin": "1HGBH41JXMN109186",
            "vehicle_class": "SUV",
            "current_location_id": "DTW01",
            "fleet_status": "available",
            "rentable_flag": True,
            "updated_at": "2026-03-01T08:00:00Z",
        },
        {
            "vehicle_id": "V1002",
            "vin": "2A4RR5D14AR275841",
            "vehicle_class": "ECONOMY",
            "current_location_id": "ORD01",
            "fleet_status": "maintenance",
            "rentable_flag": False,
            "updated_at": "2026-03-01T08:05:00Z",
        },
    ]
    return [FleetRecord(**row) for row in payload]


def run(snapshot_date: str) -> None:
    ingest_ts = datetime.now(tz=UTC)
    records = fetch_fleet_snapshot()
    write_json_lines([record.model_dump(mode="json") for record in records], raw_path("fleet_inventory", ingest_ts))
    frame = records_to_dataframe(records)
    frame["snapshot_date"] = snapshot_date
    upsert_dataframe("staging.stg_fleet_inventory", frame)
    logger.info("Completed fleet snapshot load", extra={"snapshot_date": snapshot_date, "row_count": len(frame)})


def main() -> None:
    parser = argparse.ArgumentParser(description="Ingest fleet inventory")
    parser.add_argument("--snapshot-date", required=True)
    args = parser.parse_args()
    run(args.snapshot_date)


if __name__ == "__main__":
    main()
