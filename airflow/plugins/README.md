# Airflow Plugins

This directory is reserved for reusable custom hooks, operators, sensors, and notification helpers.

Examples that would live here in a fuller deployment:
- Snowflake SQL execution wrapper with audit metadata
- Slack or PagerDuty alert operators
- S3 watermark sensors
- Kafka consumer lag sensors

The directory is intentionally kept non-empty so the repository structure is complete and production-like.
