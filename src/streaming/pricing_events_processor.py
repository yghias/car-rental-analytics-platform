from __future__ import annotations

from src.common.schemas import StreamingEnvelope


def normalize_pricing_event(envelope: StreamingEnvelope) -> dict:
    payload = envelope.payload
    return {
        "event_id": envelope.event_id,
        "event_ts": envelope.event_ts,
        "pricing_event_id": payload["pricing_event_id"],
        "location_id": payload["location_id"],
        "vehicle_class": payload["vehicle_class"],
        "channel": payload["channel"],
        "rate_amount": payload["rate_amount"],
        "source": envelope.source,
    }
