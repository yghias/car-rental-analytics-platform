from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class DagWindow:
    schedule: str
    retries: int
    retry_delay_minutes: int


BOOKING_DAG_WINDOW = DagWindow(schedule="*/30 * * * *", retries=2, retry_delay_minutes=10)
FLEET_DAG_WINDOW = DagWindow(schedule="0 * * * *", retries=2, retry_delay_minutes=15)
FORECAST_DAG_WINDOW = DagWindow(schedule="0 6 * * *", retries=1, retry_delay_minutes=30)
