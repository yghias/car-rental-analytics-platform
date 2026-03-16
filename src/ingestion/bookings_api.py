from __future__ import annotations

import argparse
from datetime import UTC, datetime
from typing import Iterable

from src.common.logging import get_logger
from src.common.schemas import BookingRecord
from src.common.storage import raw_path, write_json_lines
from src.common.warehouse import records_to_dataframe, upsert_dataframe

logger = get_logger(__name__)


def fetch_bookings(start_date: str, end_date: str) -> Iterable[BookingRecord]:
    sample_payload = [
        {
            "booking_id": "B1001",
            "customer_id": "C201",
            "pickup_location_id": "DTW01",
            "return_location_id": "DTW01",
            "vehicle_class": "SUV",
            "booking_status": "booked",
            "scheduled_pickup_ts": "2026-03-01T10:00:00Z",
            "scheduled_return_ts": "2026-03-03T10:00:00Z",
            "booked_revenue_amount": 189.50,
            "updated_at": "2026-03-01T08:10:00Z",
        },
        {
            "booking_id": "B1002",
            "customer_id": "C202",
            "pickup_location_id": "ORD01",
            "return_location_id": "ORD01",
            "vehicle_class": "ECONOMY",
            "booking_status": "cancelled",
            "scheduled_pickup_ts": "2026-03-01T09:00:00Z",
            "scheduled_return_ts": "2026-03-02T09:00:00Z",
            "booked_revenue_amount": 74.00,
            "updated_at": "2026-03-01T08:45:00Z",
        },
    ]
    logger.info("Fetched booking payloads", extra={"start_date": start_date, "end_date": end_date})
    return [BookingRecord(**row) for row in sample_payload]


def run(start_date: str, end_date: str) -> None:
    ingest_ts = datetime.now(tz=UTC)
    records = list(fetch_bookings(start_date, end_date))
    write_json_lines([record.model_dump(mode="json") for record in records], raw_path("bookings", ingest_ts))
    frame = records_to_dataframe(records)
    upsert_dataframe("staging.stg_bookings", frame)
    logger.info("Completed booking ingestion", extra={"row_count": len(frame)})


def main() -> None:
    parser = argparse.ArgumentParser(description="Ingest bookings from reservation API")
    parser.add_argument("--start-date", required=True)
    parser.add_argument("--end-date", required=True)
    args = parser.parse_args()
    run(args.start_date, args.end_date)


if __name__ == "__main__":
    main()
