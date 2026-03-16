# Decisions

## ADR-001: AWS as the Reference Cloud

Status: Accepted

The repository uses AWS as the reference cloud environment, with S3 for raw and curated storage, Kafka-compatible streaming, and Terraform modules shaped around AWS primitives.

Rationale:
- AWS aligns naturally with S3-centric raw landing architecture.
- The ecosystem supports a realistic mix of batch ingestion, streaming, Airflow orchestration, IAM controls, and warehouse connectivity.
- The design remains portable, but the repo benefits from a single coherent cloud narrative.

## ADR-002: Snowflake as the Primary Warehouse

Status: Accepted

Snowflake is the warehouse target for core and mart-layer analytics workloads.

Rationale:
- Strong support for SQL-heavy modeling and dimensional marts.
- Separation of compute and storage supports mixed workloads.
- Good fit for semi-structured ingestion and iterative analytics engineering.

Tradeoff:
- Some SQL syntax may require modest adaptation for Redshift or BigQuery, but the core modeling strategy remains portable.

## ADR-003: SQL-First Transformation Strategy

Status: Accepted

Business transformations, KPI logic, dimensional models, and warehouse quality checks should live primarily in SQL.

Rationale:
- SQL is easier for analytics engineers, data engineers, and database practitioners to review.
- Metric logic remains closer to the warehouse where it is consumed.
- dbt-style models and SQL tests provide better governance and lineage than burying business logic in Python.

Python remains responsible for ingestion, orchestration helpers, event handling, and ML support.

## ADR-004: Raw-First Landing Pattern

Status: Accepted

All source data must land in immutable raw storage before transformation.

Rationale:
- Supports replay and historical reprocessing.
- Improves auditability and incident recovery.
- Decouples upstream source reliability from downstream model rebuilds.

## ADR-005: Batch Plus Streaming

Status: Accepted

The platform combines scheduled extraction with event-driven updates.

Rationale:
- Batch pipelines provide authoritative reconciliation and complete history.
- Streaming reduces latency for operational analytics such as booking pace, inventory shifts, and pricing changes.

## ADR-006: Canonical Core Models Before Marts

Status: Accepted

The repository uses a layered warehouse pattern:
- raw
- staging
- core
- marts

Rationale:
- isolates source complexity
- creates stable enterprise entities
- prevents BI logic from depending directly on source-specific quirks

## ADR-007: Data Quality as a First-Class Warehouse Concern

Status: Accepted

Validation logic belongs in SQL and operational metadata tables, not only in ingestion code.

Rationale:
- Enables repeatable checks close to the data
- Supports reconciliation, anomaly detection, and auditability
- Improves observability for downstream users
