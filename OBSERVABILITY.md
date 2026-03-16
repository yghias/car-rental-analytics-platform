# Observability

## Goals

Observability should answer three questions:

1. Is the platform running?
2. Is the data fresh and trustworthy?
3. If not, where did it break and what is the blast radius?

## Pillars

### Pipeline health
- DAG success rate
- task retries and runtime distribution
- streaming consumer lag
- dead-letter volume

### Data health
- freshness by source and dataset
- row counts and completeness
- null-rate and uniqueness thresholds
- reconciliation against source control totals where available

### Platform health
- warehouse job failures
- storage growth trends
- Kafka throughput and lag
- deployment failure events

## SLAs

- booking staging freshness: within 30 minutes
- fleet status freshness for event-backed datasets: within 15 minutes
- pricing event freshness: within 20 minutes
- daily executive marts: available by 6:00 AM local warehouse region time
- forecast features: available by 7:00 AM

## Key Alerts

- missed ingestion schedule
- source extraction returns zero rows unexpectedly
- schema drift detected
- dead-letter backlog exceeds threshold
- daily revenue mart fails reconciliation
- booking cancellations spike abnormally beyond expected baseline

## Telemetry Design

Every ingestion run should emit:

- source name
- run ID
- start and end timestamp
- extraction window
- records extracted
- records landed
- records rejected
- status

Every transformation run should emit:

- model name
- row counts in and out
- runtime
- test failures
- partition date or load window

## Operational Dashboards

Recommended monitoring views:

- ingestion status by source
- freshness by dataset
- failed tasks over time
- consumer lag by topic
- data quality failures by model
- SLA breach history
