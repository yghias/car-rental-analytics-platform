from __future__ import annotations

import pandas as pd


def evaluate_price_uplift(frame: pd.DataFrame) -> pd.DataFrame:
    analyzed = frame.copy()
    analyzed["expected_revenue"] = analyzed["booking_count"] * analyzed["avg_rate_amount"]
    analyzed["revenue_per_available_vehicle"] = analyzed["expected_revenue"] / analyzed["available_vehicles"].clip(lower=1)
    return analyzed.sort_values("revenue_per_available_vehicle", ascending=False)
