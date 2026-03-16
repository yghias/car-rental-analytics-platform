from __future__ import annotations

import pandas as pd


def build_booking_core(bookings: pd.DataFrame, customers: pd.DataFrame, locations: pd.DataFrame) -> pd.DataFrame:
    enriched = bookings.merge(customers, on="customer_id", how="left")
    pickup_locations = locations[["location_id", "region", "airport_flag"]].rename(
        columns={"location_id": "pickup_location_id", "region": "pickup_region", "airport_flag": "pickup_airport_flag"}
    )
    return enriched.merge(pickup_locations, on="pickup_location_id", how="left")


def build_vehicle_availability_core(fleet: pd.DataFrame, maintenance: pd.DataFrame) -> pd.DataFrame:
    maintenance_flags = maintenance[["vehicle_id", "maintenance_event_id"]].assign(in_maintenance=True)
    return fleet.merge(maintenance_flags, on="vehicle_id", how="left").fillna({"in_maintenance": False})
