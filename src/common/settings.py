from __future__ import annotations

import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Settings:
    app_env: str = os.getenv("APP_ENV", "local")
    raw_bucket: str = os.getenv("RAW_BUCKET", "/tmp/car-rental-raw")
    curated_bucket: str = os.getenv("CURATED_BUCKET", "/tmp/car-rental-curated")
    warehouse_dsn: str = os.getenv("WAREHOUSE_DSN", "sqlite:////tmp/car_rental_analytics.db")
    kafka_bootstrap_servers: str = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092")
    kafka_group_id: str = os.getenv("KAFKA_GROUP_ID", "car-rental-analytics-platform")
    log_level: str = os.getenv("LOG_LEVEL", "INFO")


SETTINGS = Settings()
