from __future__ import annotations

import argparse
from datetime import UTC, datetime

from src.common.logging import get_logger
from src.common.storage import raw_path, write_json_lines
from src.common.warehouse import records_to_dataframe, upsert_dataframe

logger = get_logger(__name__)


def fetch_customers() -> list[dict]:
    return [
        {
            "customer_id": "C201",
            "loyalty_tier": "GOLD",
            "country_code": "US",
            "marketing_opt_in": True,
            "updated_at": "2026-03-01T06:00:00Z",
        },
        {
            "customer_id": "C202",
            "loyalty_tier": "STANDARD",
            "country_code": "US",
            "marketing_opt_in": False,
            "updated_at": "2026-03-01T06:02:00Z",
        },
    ]


def run() -> None:
    ingest_ts = datetime.now(tz=UTC)
    records = fetch_customers()
    write_json_lines(records, raw_path("customers", ingest_ts))
    upsert_dataframe("staging.stg_customers", records_to_dataframe(records))
    logger.info("Completed customer ingestion", extra={"row_count": len(records)})


def main() -> None:
    parser = argparse.ArgumentParser(description="Ingest customer profiles")
    parser.parse_args()
    run()


if __name__ == "__main__":
    main()
