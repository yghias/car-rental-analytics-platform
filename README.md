# car-rental-analytics-platform

`car-rental-analytics-platform` is an end-to-end cloud data platform for a multi-location car rental business. It ingests operational data from reservation systems, fleet tools, pricing services, customer platforms, maintenance systems, file drops, and streaming events, then transforms those inputs into trusted warehouse models for utilization analytics, revenue reporting, pricing analysis, demand forecasting, and operational dashboards.

This repository is written as a production-style portfolio project with a deliberately SQL-heavy implementation style. It emphasizes realistic data platform concerns including incremental ingestion, near-real-time event processing, warehouse modeling, dimensional marts, SQL-first transformations, orchestration, observability, lineage, access control, idempotent backfills, and business-aligned analytical outputs.

## Business Problem

Car rental companies manage high-cost physical assets with time-sensitive demand. The business needs to answer questions such as:

- Which branches are over- or under-utilized by vehicle class?
- How are pricing changes affecting booking conversion and realized revenue?
- Where is maintenance downtime reducing rentable supply?
- What will demand look like next week by location and class?
- Which data products can finance, pricing, and operations trust without manual reconciliation?

Without a unified data platform, these answers are fragmented across APIs, spreadsheets, operational tools, and inconsistent SQL extracts. This project centralizes those domains into a governed analytics foundation.

## Architecture Summary

The platform follows a layered cloud data architecture:

1. Ingestion layer
   Python connectors pull APIs and file drops, while Kafka consumers process near-real-time booking, fleet, and pricing events.
2. Raw landing zone
   Immutable source payloads land in cloud storage for replay, auditing, and schema evolution.
3. Standardization layer
   Staging models type and normalize source-specific payloads.
4. Canonical modeling layer
   Core business entities align bookings, vehicles, pricing, customers, locations, and maintenance records.
5. Analytical warehouse layer
   Dimensional marts expose metrics for utilization, revenue, pricing, downtime, and forecasting.
6. Semantic and reporting layer
   BI-ready tables support dashboards for operations, finance, pricing, and executive users.
7. ML and forecasting layer
   Feature generation and scoring pipelines support demand forecasting and pricing analysis.

See [ARCHITECTURE.md](/Users/yasserghias/Documents/Playground/car-rental-analytics-platform/ARCHITECTURE.md) and [PLAN.md](/Users/yasserghias/Documents/Playground/car-rental-analytics-platform/PLAN.md) for the full blueprint.

## Tech Stack

- Python for ingestion, streaming, transformation helpers, and ML utilities
- Kafka for event-driven booking, pricing, and fleet status processing
- Snowflake-oriented warehouse design with Redshift-compatible modeling concepts
- SQL-first warehouse contracts, dimensional marts, and dbt-style models under `sql/` and `models/`
- Airflow DAGs for orchestration, backfills, and quality checks
- Cloud object storage patterns for raw and curated zones
- Terraform for infrastructure definition
- GitHub Actions for CI and deployment workflows

## Key Workflows

### Batch ingestion
- Pull reservations, fleet inventory, pricing data, customers, locations, and maintenance records on defined schedules.
- Persist raw extracts to storage before transformation.
- Record high-watermarks, row counts, checksums, and extraction status.

### Streaming ingestion
- Consume booking state changes, pricing events, and fleet status updates from Kafka.
- Validate event contracts and dead-letter malformed payloads.
- Update operational freshness for near-real-time reporting.

### Warehouse transformation
- Standardize source payloads into typed staging models.
- Build canonical core entities with consistent keys and status mappings.
- Publish fact and dimension models for reporting and analytics.
- Materialize SQL-heavy marts for branch daily performance, booking pace, pricing effectiveness, downtime exposure, and forecast actuals.

### Forecasting and analytics
- Generate feature sets by location, date, and vehicle class.
- Train and score demand forecasting models.
- Support pricing analysis and utilization reporting.

## Business Outcomes

This platform is designed to improve:

- Fleet utilization visibility across branches and vehicle classes
- Speed and reliability of booking and revenue reporting
- Pricing decision support through event-aware analytics
- Operational awareness of downtime and out-of-service inventory
- Forecast-driven planning for demand, capacity, and staffing

Illustrative outcomes are documented in [RESULTS.md](/Users/yasserghias/Documents/Playground/car-rental-analytics-platform/RESULTS.md).

## Why This Platform Matters

In car rental, inventory is both expensive and perishable. A missed booking signal, stale fleet view, or delayed pricing update can impact revenue the same day. This repository shows how to design a platform that makes operational data immediately useful while still preserving analytical rigor, governance, and warehouse performance.

## Repository Guide

- [ARCHITECTURE.md](/Users/yasserghias/Documents/Playground/car-rental-analytics-platform/ARCHITECTURE.md): system design, layer responsibilities, and tradeoffs
- [DATA_MODEL.md](/Users/yasserghias/Documents/Playground/car-rental-analytics-platform/DATA_MODEL.md): conceptual, logical, physical, and dimensional modeling strategy
- [PIPELINES.md](/Users/yasserghias/Documents/Playground/car-rental-analytics-platform/PIPELINES.md): ingestion and transformation pipeline design
- [sql/schema.sql](/Users/yasserghias/Documents/Playground/car-rental-analytics-platform/sql/schema.sql): warehouse DDL for schemas, core entities, marts, and operational metadata
- [sql/marts.sql](/Users/yasserghias/Documents/Playground/car-rental-analytics-platform/sql/marts.sql): production-style reporting and semantic mart SQL
- [sql/tests.sql](/Users/yasserghias/Documents/Playground/car-rental-analytics-platform/sql/tests.sql): warehouse data quality and reconciliation assertions
- [GOVERNANCE.md](/Users/yasserghias/Documents/Playground/car-rental-analytics-platform/GOVERNANCE.md): source authority, lineage, metadata, stewardship, and controls
- [OBSERVABILITY.md](/Users/yasserghias/Documents/Playground/car-rental-analytics-platform/OBSERVABILITY.md): SLAs, monitoring, alerting, and run-level telemetry
- [RUNBOOK.md](/Users/yasserghias/Documents/Playground/car-rental-analytics-platform/RUNBOOK.md): operational procedures for failures, replays, and backfills

## Local Development

Install dependencies and inspect the repository:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Example tasks:

```bash
python -m src.ingestion.bookings_api --start-date 2026-03-01 --end-date 2026-03-02
python -m src.streaming.kafka_consumer --topic booking_events
python -m src.ml.demand_forecast_train --train-date 2026-03-01
```

## Notes

- The code is intentionally sample-friendly but structured like a reviewable production repository.
- PNG assets under `docs/` are lightweight placeholders; Mermaid source diagrams are documented in [ARCHITECTURE.md](/Users/yasserghias/Documents/Playground/car-rental-analytics-platform/ARCHITECTURE.md).
