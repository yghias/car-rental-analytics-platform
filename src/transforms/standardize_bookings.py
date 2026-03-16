from __future__ import annotations

import pandas as pd


STATUS_MAP = {
    "booked": "reserved",
    "cancelled": "cancelled",
    "checked_out": "in_rental",
    "checked_in": "completed",
}


def standardize_bookings(frame: pd.DataFrame) -> pd.DataFrame:
    standardized = frame.copy()
    standardized["booking_status_standardized"] = standardized["booking_status"].map(STATUS_MAP).fillna("unknown")
    standardized["scheduled_rental_days"] = (
        pd.to_datetime(standardized["scheduled_return_ts"]) - pd.to_datetime(standardized["scheduled_pickup_ts"])
    ).dt.days.clip(lower=1)
    standardized["booked_revenue_amount"] = standardized["booked_revenue_amount"].astype(float).round(2)
    return standardized
