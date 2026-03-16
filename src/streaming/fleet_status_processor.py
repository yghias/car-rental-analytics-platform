from __future__ import annotations

from src.common.schemas import StreamingEnvelope


def normalize_fleet_status_event(envelope: StreamingEnvelope) -> dict:
    payload = envelope.payload
    return {
        "event_id": envelope.event_id,
        "event_ts": envelope.event_ts,
        "vehicle_id": payload["vehicle_id"],
        "current_location_id": payload["current_location_id"],
        "fleet_status": payload["fleet_status"],
        "rentable_flag": payload["rentable_flag"],
        "source": envelope.source,
    }
