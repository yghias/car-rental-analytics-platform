from __future__ import annotations

import pandas as pd


def score(frame: pd.DataFrame) -> pd.DataFrame:
    scored = frame.copy()
    scored["forecasted_booking_count"] = (
        0.45 * scored["bookings_7d_avg_proxy"] + 0.02 * scored["available_vehicles"] - 0.01 * scored["avg_rate_amount"] + 4
    ).round(2)
    return scored
