from __future__ import annotations

import argparse

import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error
from sklearn.model_selection import train_test_split

from src.common.logging import get_logger

logger = get_logger(__name__)


def train(frame: pd.DataFrame) -> dict:
    features = frame[["avg_rate_amount", "available_vehicles", "bookings_7d_avg_proxy"]].fillna(0)
    target = frame["booking_count"]
    x_train, x_test, y_train, y_test = train_test_split(features, target, test_size=0.3, random_state=42)
    model = RandomForestRegressor(n_estimators=50, random_state=42)
    model.fit(x_train, y_train)
    predictions = model.predict(x_test)
    mae = mean_absolute_error(y_test, predictions)
    logger.info("Trained demand model", extra={"mae": round(float(mae), 4), "training_rows": len(x_train)})
    return {"model_type": "RandomForestRegressor", "mae": float(mae), "feature_count": features.shape[1]}


def main() -> None:
    parser = argparse.ArgumentParser(description="Train demand forecast model from CSV features")
    parser.add_argument("--train-date", required=True)
    parser.parse_args()
    sample = pd.DataFrame(
        [
            {"avg_rate_amount": 80, "available_vehicles": 12, "bookings_7d_avg_proxy": 8, "booking_count": 9},
            {"avg_rate_amount": 82, "available_vehicles": 10, "bookings_7d_avg_proxy": 9, "booking_count": 11},
            {"avg_rate_amount": 78, "available_vehicles": 15, "bookings_7d_avg_proxy": 7, "booking_count": 8},
            {"avg_rate_amount": 95, "available_vehicles": 7, "bookings_7d_avg_proxy": 11, "booking_count": 13},
            {"avg_rate_amount": 91, "available_vehicles": 8, "bookings_7d_avg_proxy": 10, "booking_count": 12},
        ]
    )
    train(sample)


if __name__ == "__main__":
    main()
