from __future__ import annotations

import pandas as pd


def build_forecast_features(bookings: pd.DataFrame, pricing: pd.DataFrame, fleet: pd.DataFrame) -> pd.DataFrame:
    booking_daily = (
        bookings.assign(service_date=pd.to_datetime(bookings["scheduled_pickup_ts"]).dt.date)
        .groupby(["pickup_location_id", "vehicle_class", "service_date"], as_index=False)
        .agg(
            booking_count=("booking_id", "nunique"),
            booked_revenue_amount=("booked_revenue_amount", "sum"),
        )
    )
    pricing_daily = (
        pricing.assign(service_date=pd.to_datetime(pricing["effective_start_ts"]).dt.date)
        .groupby(["location_id", "vehicle_class", "service_date"], as_index=False)
        .agg(avg_rate_amount=("rate_amount", "mean"))
        .rename(columns={"location_id": "pickup_location_id"})
    )
    fleet_daily = (
        fleet.groupby(["current_location_id", "vehicle_class"], as_index=False)
        .agg(available_vehicles=("available_flag", "sum"))
        .rename(columns={"current_location_id": "pickup_location_id"})
    )
    features = booking_daily.merge(pricing_daily, on=["pickup_location_id", "vehicle_class", "service_date"], how="left")
    features = features.merge(fleet_daily, on=["pickup_location_id", "vehicle_class"], how="left")
    features["avg_rate_amount"] = features["avg_rate_amount"].fillna(features["avg_rate_amount"].median())
    features["available_vehicles"] = features["available_vehicles"].fillna(0)
    features["bookings_7d_avg_proxy"] = features.groupby(["pickup_location_id", "vehicle_class"])["booking_count"].transform(
        lambda series: series.rolling(7, min_periods=1).mean()
    )
    return features
