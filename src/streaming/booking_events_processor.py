from __future__ import annotations

from src.common.schemas import StreamingEnvelope


def normalize_booking_event(envelope: StreamingEnvelope) -> dict:
    payload = envelope.payload
    return {
        "event_id": envelope.event_id,
        "event_ts": envelope.event_ts,
        "booking_id": payload["booking_id"],
        "booking_status": payload["booking_status"],
        "pickup_location_id": payload["pickup_location_id"],
        "vehicle_class": payload["vehicle_class"],
        "source": envelope.source,
    }
