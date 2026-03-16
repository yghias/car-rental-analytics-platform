from __future__ import annotations

from src.common.logging import get_logger
from src.ingestion.bookings_api import run as run_bookings
from src.ingestion.customer_api import run as run_customers
from src.ingestion.fleet_api import run as run_fleet
from src.ingestion.locations_loader import run as run_locations
from src.ingestion.maintenance_loader import run as run_maintenance
from src.ingestion.pricing_api import run as run_pricing

logger = get_logger(__name__)


def run_operational_snapshot(snapshot_date: str) -> None:
    logger.info("Starting operational snapshot", extra={"snapshot_date": snapshot_date})
    run_bookings(snapshot_date, snapshot_date)
    run_fleet(snapshot_date)
    run_pricing()
    run_customers()
    run_locations()
    run_maintenance()
    logger.info("Completed operational snapshot", extra={"snapshot_date": snapshot_date})
