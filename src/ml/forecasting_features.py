from __future__ import annotations

import pandas as pd

from src.transforms.generate_feature_sets import build_forecast_features
from src.transforms.standardize_bookings import standardize_bookings
from src.transforms.standardize_fleet import standardize_fleet
from src.transforms.standardize_pricing import standardize_pricing


def build_feature_frame(bookings: pd.DataFrame, pricing: pd.DataFrame, fleet: pd.DataFrame) -> pd.DataFrame:
    return build_forecast_features(
        standardize_bookings(bookings),
        standardize_pricing(pricing),
        standardize_fleet(fleet),
    )
