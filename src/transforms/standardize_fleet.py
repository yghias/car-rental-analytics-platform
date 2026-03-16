from __future__ import annotations

import pandas as pd


STATUS_MAP = {
    "available": "rentable",
    "reserved": "reserved",
    "maintenance": "out_of_service",
    "cleaning": "turnaround",
}


def standardize_fleet(frame: pd.DataFrame) -> pd.DataFrame:
    standardized = frame.copy()
    standardized["fleet_status_standardized"] = standardized["fleet_status"].map(STATUS_MAP).fillna("unknown")
    standardized["available_flag"] = standardized["fleet_status_standardized"].eq("rentable") & standardized["rentable_flag"]
    return standardized
