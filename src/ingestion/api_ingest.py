from __future__ import annotations

import argparse
from collections.abc import Callable

from src.common.logging import get_logger
from src.ingestion.bookings_api import run as run_bookings
from src.ingestion.customer_api import run as run_customers
from src.ingestion.fleet_api import run as run_fleet
from src.ingestion.locations_loader import run as run_locations
from src.ingestion.maintenance_loader import run as run_maintenance
from src.ingestion.pricing_api import run as run_pricing

logger = get_logger(__name__)


def ingest_bookings(start_date: str, end_date: str) -> None:
    run_bookings(start_date, end_date)


def ingest_fleet(snapshot_date: str) -> None:
    run_fleet(snapshot_date)


def ingest_pricing() -> None:
    run_pricing()


def ingest_customers() -> None:
    run_customers()


def ingest_locations() -> None:
    run_locations()


def ingest_maintenance() -> None:
    run_maintenance()


def main() -> None:
    parser = argparse.ArgumentParser(description="Dispatch API-style source ingestions")
    parser.add_argument(
        "--domain",
        required=True,
        choices=["bookings", "fleet", "pricing", "customers", "locations", "maintenance"],
    )
    parser.add_argument("--start-date")
    parser.add_argument("--end-date")
    parser.add_argument("--snapshot-date")
    args = parser.parse_args()

    domain_handlers: dict[str, Callable[[], None]] = {
        "bookings": lambda: ingest_bookings(args.start_date or "2026-03-01", args.end_date or "2026-03-01"),
        "fleet": lambda: ingest_fleet(args.snapshot_date or "2026-03-01"),
        "pricing": ingest_pricing,
        "customers": ingest_customers,
        "locations": ingest_locations,
        "maintenance": ingest_maintenance,
    }
    logger.info("Running domain ingestion", extra={"domain": args.domain})
    domain_handlers[args.domain]()


if __name__ == "__main__":
    main()
