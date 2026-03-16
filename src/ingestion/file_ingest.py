from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd

from src.common.logging import get_logger
from src.common.quality import assert_non_empty, assert_required_columns
from src.common.warehouse import upsert_dataframe

logger = get_logger(__name__)


REQUIRED_COLUMNS = {
    "staging.stg_bookings": ["booking_id", "customer_id", "pickup_location_id", "return_location_id", "vehicle_class"],
    "staging.stg_fleet_inventory": ["vehicle_id", "vin", "vehicle_class", "current_location_id", "fleet_status"],
    "staging.stg_pricing_events": ["pricing_event_id", "location_id", "vehicle_class", "channel", "rate_amount"],
}


def load_frame(path: Path) -> pd.DataFrame:
    if path.suffix.lower() == ".csv":
        return pd.read_csv(path)
    if path.suffix.lower() == ".json":
        return pd.read_json(path, lines=True)
    raise ValueError(f"Unsupported input file type: {path}")


def run(file_path: str, target_table: str) -> None:
    path = Path(file_path)
    frame = load_frame(path)
    checks = [assert_non_empty(frame, path.name)]
    if target_table in REQUIRED_COLUMNS:
        checks.append(assert_required_columns(frame, REQUIRED_COLUMNS[target_table]))
    failed_checks = [result for result in checks if not result.passed]
    if failed_checks:
        raise ValueError(f"Input validation failed for {path}: {failed_checks}")
    upsert_dataframe(target_table, frame)
    logger.info("Loaded file ingestion payload", extra={"file_path": file_path, "target_table": target_table, "row_count": len(frame)})


def main() -> None:
    parser = argparse.ArgumentParser(description="Load source records from local file into staging")
    parser.add_argument("--file-path", required=True)
    parser.add_argument("--target-table", required=True)
    args = parser.parse_args()
    run(args.file_path, args.target_table)


if __name__ == "__main__":
    main()
