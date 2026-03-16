# Pipelines

## Overview

The platform organizes data movement into five major pipeline families:

1. batch ingestion
2. streaming ingestion
3. warehouse standardization
4. mart generation
5. forecast feature and scoring pipelines

Each pipeline is designed around replayability, auditability, and business-tolerant failure handling.

## Batch Ingestion Pipelines

### Booking ingestion

Source:
- reservation APIs
- historical file drops for backfills

Flow:
- read extraction checkpoint
- fetch changed bookings for the configured window
- write raw payloads to object storage
- persist extraction audit record
- load normalized staging table

Controls:
- high-watermark by updated timestamp
- pagination and API retry
- row count validation against API metadata when available

### Fleet inventory ingestion

Source:
- fleet management API or export

Flow:
- extract vehicle master and current state snapshots
- preserve raw snapshots
- standardize statuses into rentable, reserved, in_use, cleaning, maintenance, and retired buckets
- materialize daily vehicle availability tables

### Pricing ingestion

Source:
- pricing engine API
- rate files from pricing teams

Flow:
- ingest base and override pricing records
- align effective date windows
- merge channel and branch scope
- publish pricing event fact models

### Customer and location ingestion

Source:
- CRM or customer platform APIs
- branch master files

Flow:
- load customer dimension attributes
- refresh location hierarchy and branch reference data
- apply SCD logic to historically relevant dimension changes

### Maintenance ingestion

Source:
- work-order or maintenance vendor system

Flow:
- ingest open and closed service events
- classify repair types
- attach downtime and cost attributes
- expose maintenance impact in fleet availability metrics

## Streaming Pipelines

### Booking events

The booking event consumer is used for:

- real-time booking creation awareness
- cancellation monitoring
- active trip changes
- same-day booking pace metrics

Processing steps:
- validate schema version
- normalize timestamps
- deduplicate by event ID
- write raw event archive
- emit standardized event records

### Fleet status events

Used for:

- near-real-time visibility into available versus unavailable vehicles
- alerting on branch-level capacity issues
- surfacing out-of-service spikes

### Pricing events

Used for:

- detecting intra-day pricing changes
- updating pricing analytics latency
- supporting pricing incident investigation

## Transformation Pipelines

### Staging

Staging transformations:
- type source columns
- standardize enums
- deduplicate source records
- preserve source keys and audit columns

### Canonical core

Core transformations:
- map source keys to canonical IDs
- harmonize booking and vehicle status logic
- join bookings to dimensions
- derive actual trip durations and realized revenue
- convert maintenance events into downtime windows

### Marts

Marts are refreshed from core models and optimized for:
- branch and region performance
- vehicle-class utilization
- pricing effectiveness
- executive KPI reporting
- forecasting feature generation

## Scheduling Strategy

- Streaming consumers run continuously.
- Booking, pricing, and fleet extraction DAGs run every 15 to 60 minutes depending on domain criticality.
- Heavy daily snapshots and finance-aligned revenue aggregations run overnight.
- Forecast dataset generation runs daily before business planning workflows.

## Replay and Backfill Strategy

- Raw data is the replay boundary.
- Batch backfills can be parameterized by source, entity, and date range.
- Event replay can be performed from Kafka offsets or from archived raw event partitions.
- Warehouse backfills should rebuild only the affected date partitions where possible.
