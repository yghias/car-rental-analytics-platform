from __future__ import annotations

import pandas as pd


def standardize_pricing(frame: pd.DataFrame) -> pd.DataFrame:
    standardized = frame.copy()
    standardized["effective_days"] = (
        pd.to_datetime(standardized["effective_end_ts"]) - pd.to_datetime(standardized["effective_start_ts"])
    ).dt.days.clip(lower=1)
    standardized["rate_amount"] = standardized["rate_amount"].astype(float).round(2)
    standardized["price_band"] = pd.cut(
        standardized["rate_amount"],
        bins=[0, 50, 100, 150, float("inf")],
        labels=["budget", "core", "premium", "luxury"],
        include_lowest=True,
    )
    return standardized
