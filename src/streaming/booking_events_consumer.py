from __future__ import annotations

import argparse

from src.common.logging import get_logger
from src.streaming.kafka_consumer import run as run_consumer

logger = get_logger(__name__)


def main() -> None:
    parser = argparse.ArgumentParser(description="Consume booking events and load them into the warehouse staging layer")
    parser.add_argument("--topic", default="booking_events")
    args = parser.parse_args()
    logger.info("Starting booking events consumer", extra={"topic": args.topic})
    run(args.topic)


if __name__ == "__main__":
    main()
