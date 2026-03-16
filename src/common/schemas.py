from __future__ import annotations

from datetime import datetime
from typing import Any, Optional

from pydantic import BaseModel, Field


class BookingRecord(BaseModel):
    booking_id: str
    customer_id: str
    pickup_location_id: str
    return_location_id: str
    vehicle_class: str
    booking_status: str
    scheduled_pickup_ts: datetime
    scheduled_return_ts: datetime
    booked_revenue_amount: float = Field(ge=0)
    updated_at: datetime


class FleetRecord(BaseModel):
    vehicle_id: str
    vin: str
    vehicle_class: str
    current_location_id: str
    fleet_status: str
    rentable_flag: bool
    updated_at: datetime


class PricingEventRecord(BaseModel):
    pricing_event_id: str
    location_id: str
    vehicle_class: str
    channel: str
    rate_amount: float = Field(ge=0)
    effective_start_ts: datetime
    effective_end_ts: datetime
    updated_at: datetime


class StreamingEnvelope(BaseModel):
    event_id: str
    event_type: str
    event_ts: datetime
    source: str
    schema_version: str
    payload: dict[str, Any]
    partition_key: Optional[str] = None
