# Runbook

## Purpose

This runbook provides operational procedures for common failure modes in ingestion, streaming, transformation, and reporting.

## Booking API Failure

### Symptoms
- booking ingestion DAG fails
- freshness breach on `stg_bookings`
- zero extracted rows during business hours

### Actions
1. confirm API health and authentication
2. inspect last successful watermark
3. rerun the extraction for the failed window
4. validate raw landing objects exist
5. rerun downstream staging and mart tasks

## Dead-Letter Queue Growth

### Symptoms
- streaming lag rises
- rejected event count spikes

### Actions
1. inspect rejected payload schema version
2. confirm producer contract changes
3. patch validator or mapping logic if contract change is intentional
4. replay dead-letter events after fix

## Revenue Reconciliation Failure

### Actions
1. compare source revenue totals to `fact_revenue`
2. identify whether the variance is in extraction, staging, or canonical logic
3. rebuild affected partitions only
4. document the incident and resolution path

## Backfill Procedure

1. identify source domain and date range
2. confirm raw data exists or re-extract source data
3. run parameterized backfill DAG or batch job
4. rerun quality checks and reconciliation
5. notify downstream consumers if business metrics change materially
