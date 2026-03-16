from __future__ import annotations

import argparse
import json
from datetime import UTC, datetime

from src.common.logging import get_logger
from src.common.schemas import StreamingEnvelope
from src.common.storage import raw_path, write_json_lines
from src.common.warehouse import records_to_dataframe, upsert_dataframe
from src.streaming.booking_events_processor import normalize_booking_event
from src.streaming.fleet_status_processor import normalize_fleet_status_event
from src.streaming.pricing_events_processor import normalize_pricing_event

logger = get_logger(__name__)


PROCESSORS = {
    "booking_events": (normalize_booking_event, "staging.stg_booking_events"),
    "fleet_status_events": (normalize_fleet_status_event, "staging.stg_fleet_status_events"),
    "pricing_events": (normalize_pricing_event, "staging.stg_pricing_stream_events"),
}


def sample_event(topic: str) -> StreamingEnvelope:
    payload_map = {
        "booking_events": {
            "booking_id": "B1001",
            "booking_status": "checked_out",
            "pickup_location_id": "DTW01",
            "vehicle_class": "SUV",
        },
        "fleet_status_events": {
            "vehicle_id": "V1001",
            "current_location_id": "DTW01",
            "fleet_status": "reserved",
            "rentable_flag": False,
        },
        "pricing_events": {
            "pricing_event_id": "P1003",
            "location_id": "DTW01",
            "vehicle_class": "SUV",
            "channel": "mobile",
            "rate_amount": 97.0,
        },
    }
    return StreamingEnvelope(
        event_id=f"{topic}-evt-001",
        event_type=topic,
        event_ts=datetime.now(tz=UTC),
        source="sample_topic",
        schema_version="1.0.0",
        payload=payload_map[topic],
    )


def run(topic: str) -> None:
    if topic not in PROCESSORS:
        raise ValueError(f"Unsupported topic: {topic}")
    processor, target_table = PROCESSORS[topic]
    envelope = sample_event(topic)
    normalized = processor(envelope)
    write_json_lines([json.loads(envelope.model_dump_json())], raw_path(topic, datetime.now(tz=UTC)))
    upsert_dataframe(target_table, records_to_dataframe([normalized]))
    logger.info("Processed event", extra={"topic": topic, "target_table": target_table})


def main() -> None:
    parser = argparse.ArgumentParser(description="Consume and process sample Kafka event")
    parser.add_argument("--topic", required=True, choices=sorted(PROCESSORS))
    args = parser.parse_args()
    run(args.topic)


if __name__ == "__main__":
    main()
