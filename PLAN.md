# car-rental-analytics-platform Implementation Plan

## 1. Project Overview

### Purpose of the Platform
`car-rental-analytics-platform` is a production-style cloud data platform for a car rental business. Its purpose is to unify operational, financial, and customer data into a reliable analytical foundation that supports fleet planning, utilization optimization, pricing decisions, demand forecasting, maintenance visibility, and executive reporting.

The platform should ingest transactional, master, and event data from operational applications, external partner APIs, file drops, and near-real-time event streams. It should standardize those inputs into canonical business models, transform them into warehouse-ready analytical structures, and expose trusted metrics for dashboards, modeling, and operational decisions.

### Business Users
- Revenue management teams optimizing rates, discounts, and promotional strategies.
- Fleet operations managers monitoring vehicle availability, utilization, turnaround time, and maintenance exposure.
- Regional and branch managers tracking booking conversion, location performance, and idle inventory.
- Finance and FP&A teams analyzing revenue, margin, vehicle economics, and forecasting.
- Customer operations and support leaders measuring customer behavior, loyalty, cancellations, and service quality.
- Executive stakeholders reviewing network-wide KPIs, profitability, growth, and operational risk.

### Technical Users
- Data engineers building ingestion, transformation, quality, and orchestration pipelines.
- Analytics engineers modeling trusted business entities and marts.
- Cloud engineers managing infrastructure, security, deployment, and platform reliability.
- Data analysts and BI developers building dashboards and semantic metrics.
- Data scientists and ML engineers training demand forecasting and pricing models.
- Database engineers and DBAs managing warehouse performance, governance, retention, and access control.

### Core Capabilities
- Ingest bookings, reservation updates, vehicle inventory, customer, location, pricing, and maintenance data from batch and streaming sources.
- Capture near-real-time changes for bookings, fleet status, telematics or utilization events, and pricing updates through Kafka or queue-based pipelines.
- Land immutable raw data in cloud storage with replay capability and source-level lineage.
- Standardize and validate incoming datasets into source-aligned staging models.
- Build canonical entities for bookings, vehicles, customers, locations, pricing, and maintenance.
- Publish analytical marts for utilization, revenue, pricing, demand, customer behavior, and operational KPIs.
- Produce model-ready datasets for forecasting and optimization use cases.
- Enforce production data quality, observability, lineage, access governance, and cost-aware platform operations.

### Why This Matters
Car rental businesses operate at the intersection of perishable inventory, dynamic pricing, location-level demand variation, and high operational complexity. A vehicle that sits idle reduces asset yield; a vehicle that is overbooked or unavailable erodes customer trust and revenue; pricing that is too low leaves money on the table, while pricing that is too high suppresses conversion.

This platform matters because it creates a shared decisioning layer across:
- Operations: improve fleet rotation, availability, turnaround, and maintenance planning.
- Pricing: support daily or intra-day pricing decisions using booking pace, vehicle class availability, and local demand signals.
- Utilization: measure how effectively the fleet is deployed by class, geography, and time period.
- Forecasting: anticipate demand by location, vehicle class, seasonality, and external factors to improve capacity and revenue planning.

The repository should be designed as a realistic enterprise-grade portfolio project that demonstrates robust engineering practices, not just a collection of notebooks and ad hoc SQL.

## 2. System Architecture

### Source Systems and External Providers
Planned source domains:
- Reservation and booking system APIs for create, modify, cancel, pickup, and return events.
- Fleet management systems for vehicle inventory, registration, status, assignment, and lifecycle state.
- Pricing or yield management systems for base rate, surge multiplier, discount, and override events.
- CRM or customer profile systems for customer demographics, loyalty, and contact preferences.
- Maintenance and work-order systems for inspections, repairs, service schedules, and downtime.
- Branch or location master data systems for airport, city, suburban, and partner-operated branches.
- Flat files from finance or vendors for supplemental attributes, adjustments, and reconciliations.
- Streaming sources such as booking event topics, vehicle status events, telemetry proxies, or queue-based operational events.
- Optional external signals such as holidays, weather, airport traffic, or tourism demand indicators for forecasting enrichment.

### Batch Ingestion Layer
Batch ingestion should handle API pulls, scheduled exports, and file-based drops.

Responsibilities:
- Incremental extraction using high-watermarks, timestamps, or source-issued sequence IDs.
- Full snapshot support for slowly changing reference data such as locations, vehicle master data, or rate cards.
- File ingestion from cloud storage landing buckets with schema-aware parsing for CSV, JSON, and parquet.
- Source-specific validation, retry handling, and extraction audit logging.
- Raw payload persistence before transformation.

Recommended design:
- Python-based connectors under `src/ingestion/`.
- Airflow-managed DAGs invoking connector modules with parameterized extraction windows.
- Extraction metadata persisted in audit tables for run ID, source, row count, checksum, and watermark tracking.

### Streaming/Event Ingestion Layer
Streaming ingestion should support near-real-time operational awareness.

Candidate event types:
- Booking created, updated, canceled, checked out, and checked in.
- Vehicle available, assigned, in-cleaning, in-maintenance, and out-of-service.
- Price changed for location, vehicle class, date bucket, or channel.
- Branch capacity alerts and unexpected utilization spikes.

Recommended design:
- Kafka topics or queue-based event ingestion with schema contracts.
- Python consumer services under `src/streaming/`.
- Micro-batch or stream-processing jobs to validate, enrich with metadata, deduplicate, and write to raw and standardized zones.
- Dead-letter topics or queues for malformed, out-of-order, or schema-breaking events.

### Raw Landing Zone
The raw landing zone should be immutable and replayable.

Requirements:
- Store untouched API payloads, files, and streaming event bodies in cloud object storage.
- Partition by source system, entity, ingest date, and optionally event hour.
- Include manifest or metadata files capturing schema version, ingestion timestamp, source extract window, and checksum.
- Support reprocessing for code changes, backfills, and forensic audits.

Typical layout:
- `s3://.../raw/bookings/source_system=reservation_api/ingest_date=YYYY-MM-DD/...`
- `s3://.../raw/pricing/source_system=pricing_api/...`
- `s3://.../raw/events/topic=booking_events/ingest_hour=...`

### Standardization and Transformation Layer
This layer converts raw inputs into validated, source-consistent structures and canonical entities.

Responsibilities:
- Parse source-specific payloads into staging tables with typed columns.
- Standardize identifiers, timestamps, currencies, statuses, and enumerations.
- Apply conforming rules for booking lifecycle, vehicle status, location hierarchy, and maintenance classification.
- Handle slowly changing dimensions, deduplication, late-arriving data, and effective dating.
- Materialize canonical models consumed by downstream marts and ML datasets.

Implementation pattern:
- SQL- and dbt-style modeling in `models/staging/` and `models/marts/`.
- Heavier transformations or large-scale joins in Spark jobs where warehouse-native processing is not sufficient.

### Analytical Warehouse / Lakehouse Layer
The analytical serving layer should support both ad hoc analytics and production reporting.

Warehouse options:
- Snowflake preferred for mature separation of compute/storage, semi-structured support, and scalable marts.
- Redshift as an alternative if the implementation is positioned toward AWS-native warehousing.

Expected warehouse zones:
- `raw` or external tables over landed data.
- `staging` for standardized source-aligned models.
- `core` for canonical enterprise entities.
- `marts` for dimensional and fact models.
- `ml` for feature tables, training sets, and scored outputs.
- `ops` for platform metadata, audit logs, and observability metrics.

### Semantic/Reporting Layer
This layer should expose business-friendly metrics with standardized definitions.

Outputs:
- BI-ready models for utilization, revenue, booking conversion, fleet downtime, and pricing performance.
- Metric definitions for fleet utilization rate, revenue per available car day, booking lead time, cancellation rate, and maintenance downtime.
- Dashboard-ready data products for executive, finance, operations, and pricing teams.

Potential delivery:
- Warehouse views or semantic models.
- Metric documentation in `dashboards/metrics.md`.
- Optional BI integration notes for Tableau, Power BI, Looker, or Superset.

### Orchestration and Scheduling
Airflow should coordinate batch pipelines, transformation DAGs, data quality checks, backfills, and ML dataset generation.

Expected orchestration patterns:
- Source-specific extract DAGs.
- Staging and canonical model build DAGs.
- Mart refresh DAGs.
- Forecast feature generation DAGs.
- Data quality and reconciliation DAGs.
- Backfill DAGs with parameterized date ranges and source selectors.

### Monitoring and Observability
Observability must cover both platform health and data trust.

Capabilities:
- Task-level execution metrics for duration, retries, failures, and backlog.
- Freshness and completeness monitoring for major source domains.
- Row count, schema drift, null-rate, uniqueness, and referential integrity checks.
- Alerting for missed SLAs, dead-letter growth, warehouse load failures, and degraded source throughput.
- Lineage visibility from source extract through published marts.

## 3. Data Architecture

### Conceptual Data Model
The conceptual model should center on the lifecycle of a rentable vehicle and the customer interactions around it.

Primary business domains:
- Reservation demand: bookings, modifications, cancellations, channels, and booking windows.
- Fleet supply: vehicles, classes, branches, status, and availability.
- Commercial controls: prices, discounts, yield rules, and revenue outcomes.
- Customer behavior: profiles, loyalty, segments, and trip history.
- Operations: pickup, return, cleaning, maintenance, downtime, and transfer events.
- Geography: locations, regional rollups, airport/city flags, and local market characteristics.

### Logical Data Model
Canonical logical entities should include:
- `booking`
  Reservation-level business record with lifecycle status, booked class, planned dates, actual dates, revenue, and source system linkage.
- `booking_event`
  Append-only lifecycle event stream for booking state changes.
- `vehicle`
  Vehicle master entity with VIN, class, make/model, acquisition details, and active status.
- `fleet_inventory_snapshot`
  Time-based view of where a vehicle is, whether it is rentable, and its current operational state.
- `customer`
  Customer profile with loyalty attributes, acquisition source, and risk or segmentation flags.
- `location`
  Branch or operational pickup/return location with hierarchy, region, market, and operating hours metadata.
- `pricing_event`
  Rate, discount, override, or recommendation event for a vehicle class, channel, and date range.
- `maintenance_event`
  Service, inspection, repair, or downtime event attached to a vehicle and optionally a location.
- `utilization_metric`
  Derived time-grain metric for vehicle or fleet usage and idle exposure.
- `revenue_fact`
  Revenue realization at booking, day, or branch grain.
- `forecast_feature_snapshot`
  Model-ready features by location, vehicle class, and date bucket.

### Physical Data Model
The physical design should use a layered warehouse pattern:
- Raw external tables or landed parquet/json references.
- Staging tables for source-conformed typing and minimal transformations.
- Core normalized tables for authoritative enterprise entities and event histories.
- Fact and dimension tables for performance-oriented analytics.
- Incremental feature tables for forecasting and pricing analysis.

Recommended physical conventions:
- Surrogate keys on dimensions, natural key mapping tables for source IDs.
- Append-only event tables for auditability.
- Partitioning/clustering by event date, booking date, pickup date, return date, and location ID where supported.
- SCD Type 2 for dimensions with historically significant attributes such as location metadata, vehicle class assignments, or customer segmentation.
- Snapshot tables for daily fleet availability and pricing state.

### Core Entities
The repository plan should explicitly support:
- Bookings
- Vehicles
- Fleet inventory
- Customers
- Locations
- Maintenance events
- Pricing events
- Utilization metrics

Supporting entities should also include:
- Booking channels
- Rate plans
- Discounts and promotions
- Vehicle classes
- Revenue adjustments
- Branch staffing or capacity indicators
- Source system audit records

### Dimensional Modeling Strategy
Recommended star-schema design:
- Facts:
  - `fact_booking`
  - `fact_booking_day`
  - `fact_revenue`
  - `fact_vehicle_utilization`
  - `fact_maintenance_downtime`
  - `fact_pricing_event`
  - `fact_forecast_actual`
- Dimensions:
  - `dim_date`
  - `dim_location`
  - `dim_vehicle`
  - `dim_vehicle_class`
  - `dim_customer`
  - `dim_channel`
  - `dim_rate_plan`
  - `dim_status`

Modeling principles:
- Build business-process-centric facts with consistent grain.
- Isolate source system complexity in staging models.
- Preserve both transaction grain and daily snapshot grain for operational analytics.
- Separate booked, actual, and forecasted metrics to avoid semantic ambiguity.

### Data Lineage and Metadata Considerations
Every business-critical table should include:
- Source system identifiers and extract provenance.
- Ingestion timestamp, processing timestamp, and effective business timestamp.
- Transformation job metadata and model version.
- Data quality status or pass/fail results where relevant.

Lineage expectations:
- Column-level or model-level lineage from raw object to staging, core, and mart layers.
- Metadata documentation in warehouse catalogs and repository docs.
- Tagging for PII, confidential financial data, and operationally sensitive fields.

### Governance and Authoritative Data Source Strategy
The platform should define one system of record per domain, even when multiple systems contribute attributes.

Illustrative strategy:
- Bookings: reservation platform is authoritative for lifecycle state and planned rental details.
- Vehicles and fleet status: fleet management system is authoritative for vehicle identity and operational status.
- Pricing: pricing engine or rate management system is authoritative for effective rate decisions.
- Customer identity: CRM or customer profile service is authoritative for customer master attributes.
- Locations: branch master or operations master data is authoritative for branch hierarchy.
- Maintenance: maintenance/work-order system is authoritative for repair and downtime events.

Conflict resolution rules should be documented explicitly for overlapping fields and late-arriving corrections.

## 4. Technology Stack

### Python Services
Python should be the primary language for:
- API connectors
- File ingestion utilities
- Streaming consumers
- Shared data contracts and validation logic
- Forecast feature generation and ML orchestration utilities

Recommended libraries:
- `requests` or provider SDKs for API extraction
- `pydantic` for payload validation
- `pandas` and `pyarrow` for local processing and file handling
- `boto3` or cloud SDK equivalents
- `sqlalchemy` for warehouse metadata operations where needed

### Spark / Distributed Processing
Spark should be included for large-scale transformations or historical reprocessing workloads such as:
- Rebuilding multi-year booking history
- Joining large booking and pricing datasets
- Processing event-heavy telemetry or utilization feeds
- Generating wide feature tables for modeling

This can be implemented with PySpark or a managed equivalent, while keeping warehouse-native SQL as the default for standard analytics transformations.

### Snowflake or Redshift Warehouse
Preferred option:
- Snowflake for flexible compute scaling, semi-structured ingestion, and robust analytics engineering workflows.

Alternative option:
- Redshift for AWS-native alignment and cost-efficient warehousing in AWS-heavy deployments.

The plan should be written warehouse-agnostically where reasonable, while using dbt-style patterns that can target either platform.

### Kafka or Event Queues for Streaming
Streaming should use one of:
- Kafka for durable topic-based event ingestion and multi-consumer architectures.
- Managed event queues such as AWS SQS/SNS, EventBridge, or Kinesis when a simpler eventing pattern is preferred.

Kafka is the stronger portfolio signal for near-real-time platform design and should be the default in architecture documentation.

### Airflow Orchestration
Airflow should orchestrate:
- Scheduled source extraction
- Warehouse model builds
- Snapshot generation
- Data quality checks
- Backfills and reprocessing workflows
- Forecast dataset refreshes

### dbt-Style Modeling
The repository should include:
- `dbt_project.yml`
- Source freshness checks
- Staging, intermediate, and mart models
- Schema tests and custom SQL tests
- Documentation-ready model descriptions

If full dbt is not implemented immediately, the structure should still follow dbt conventions to support later expansion.

### Cloud Storage
Cloud object storage should back the raw and curated zones:
- Amazon S3 if positioning the stack on AWS.
- Equivalent support can be noted for Azure Blob or GCS, but the initial repo should align to one cloud story for coherence.

### CI/CD and Infrastructure Tooling
Recommended tooling:
- GitHub Actions for CI and deployment workflows.
- Terraform under `infrastructure/terraform/` for storage, Kafka, Airflow, IAM, and warehouse-adjacent resources.
- Docker for local development consistency.
- Linting, testing, and SQL validation in CI.

## 5. Repository Structure

The planned repository should follow this structure:

```text
car-rental-analytics-platform/
├── README.md
├── PLAN.md
├── ARCHITECTURE.md
├── DATA_MODEL.md
├── PIPELINES.md
├── API_INTEGRATIONS.md
├── GOVERNANCE.md
├── OBSERVABILITY.md
├── CI_CD.md
├── SECURITY.md
├── TESTING.md
├── ROADMAP.md
├── RUNBOOK.md
├── USE_CASES.md
├── RESULTS.md
├── RESUME_BULLETS.md
├── LINKEDIN_SUMMARY.md
├── PORTFOLIO_ENTRY.md
├── requirements.txt
├── .env.example
├── Dockerfile
├── .gitignore
├── dbt_project.yml
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy.yml
├── src/
│   ├── ingestion/
│   │   ├── bookings_api.py
│   │   ├── fleet_api.py
│   │   ├── pricing_api.py
│   │   ├── customer_api.py
│   │   ├── locations_loader.py
│   │   ├── maintenance_loader.py
│   │   └── file_drop_loader.py
│   ├── transforms/
│   │   ├── standardize_bookings.py
│   │   ├── standardize_fleet.py
│   │   ├── standardize_pricing.py
│   │   ├── build_canonical_models.py
│   │   └── generate_feature_sets.py
│   ├── orchestration/
│   │   ├── jobs.py
│   │   ├── config.py
│   │   └── metadata.py
│   ├── streaming/
│   │   ├── kafka_consumer.py
│   │   ├── booking_events_processor.py
│   │   ├── fleet_status_processor.py
│   │   └── pricing_events_processor.py
│   ├── ml/
│   │   ├── forecasting_features.py
│   │   ├── demand_forecast_train.py
│   │   ├── demand_forecast_score.py
│   │   └── pricing_analysis.py
│   └── common/
│       ├── settings.py
│       ├── logging.py
│       ├── schemas.py
│       ├── storage.py
│       ├── warehouse.py
│       └── quality.py
├── sql/
│   ├── schema.sql
│   ├── marts.sql
│   └── tests.sql
├── models/
│   ├── staging/
│   │   ├── stg_bookings.sql
│   │   ├── stg_fleet_inventory.sql
│   │   ├── stg_customers.sql
│   │   ├── stg_locations.sql
│   │   ├── stg_pricing_events.sql
│   │   └── stg_maintenance_events.sql
│   └── marts/
│       ├── fact_booking.sql
│       ├── fact_vehicle_utilization.sql
│       ├── fact_revenue.sql
│       ├── fact_maintenance_downtime.sql
│       ├── dim_location.sql
│       ├── dim_vehicle.sql
│       └── mart_demand_forecast_features.sql
├── airflow/
│   ├── dags/
│   │   ├── bookings_ingestion_dag.py
│   │   ├── fleet_ingestion_dag.py
│   │   ├── pricing_ingestion_dag.py
│   │   ├── warehouse_transform_dag.py
│   │   └── forecast_dataset_dag.py
│   └── plugins/
├── notebooks/
│   ├── forecasting.ipynb
│   └── data_quality_checks.ipynb
├── sample_data/
│   ├── README.md
│   ├── bookings/
│   ├── fleet/
│   ├── pricing/
│   ├── customers/
│   ├── maintenance/
│   └── locations/
├── dashboards/
│   ├── metrics.md
│   └── mockups/
├── infrastructure/
│   └── terraform/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── storage.tf
│       ├── kafka.tf
│       ├── airflow.tf
│       ├── iam.tf
│       └── monitoring.tf
└── docs/
    ├── overview.png
    ├── data-flow.png
    └── schema.png
```

### Repository Planning Notes
- Root markdown documents should explain the platform from architecture, operations, governance, security, and portfolio perspectives.
- `src/` should hold executable Python services and utilities.
- `models/` should represent dbt-style SQL transformations.
- `airflow/` should contain DAGs and optional custom operators or hooks.
- `sql/` should support bootstrap DDL, test queries, and warehouse-specific helper scripts.
- `sample_data/` should make the repo demonstrable without requiring live provider access.
- `docs/` should contain architecture visuals used in README and portfolio collateral.

## 6. Pipeline Design

### Booking Ingestion
Purpose:
Capture reservation lifecycle data with full history.

Design:
- Pull incremental bookings and reservation updates from reservation APIs on a frequent schedule.
- Persist raw responses to the landing zone.
- Standardize booking IDs, source timestamps, pickup/return locations, vehicle class, booking channel, rate plan, and lifecycle status.
- Preserve booking event history to capture modifications, cancellations, upgrades, and extensions.
- Reconcile booked dates with actual pickup and return timestamps once trips complete.

Output tables:
- `stg_bookings`
- `core_booking`
- `core_booking_event`
- `fact_booking`
- `fact_booking_day`

### Fleet Inventory Ingestion
Purpose:
Track the state and availability of vehicles over time.

Design:
- Extract vehicle master data and current status snapshots from fleet systems.
- Capture attributes such as VIN, class, make, model, branch, odometer, status, rentable flag, and acquisition/disposal dates.
- Build periodic inventory snapshots to measure supply, idle inventory, and operational utilization.
- Detect changes in assignment, availability, and out-of-service conditions.

Output tables:
- `stg_fleet_inventory`
- `core_vehicle`
- `core_fleet_status_snapshot`
- `fact_vehicle_utilization`

### Pricing Updates
Purpose:
Maintain a time-aware record of commercial decisions.

Design:
- Ingest base rates, override events, discount campaigns, yield adjustments, and dynamic pricing changes.
- Standardize effective start/end windows, vehicle class, channel, location scope, and override priority.
- Retain event history to compare offered rates versus realized revenue and demand response.

Output tables:
- `stg_pricing_events`
- `core_pricing_event`
- `fact_pricing_event`

### Customer and Location Ingestion
Purpose:
Build trusted customer and branch dimensions.

Design:
- Load customer profiles, loyalty tiers, contact preferences, and source segmentation attributes.
- Standardize location hierarchies including branch, city, metro, region, airport flag, and operating schedule.
- Handle slowly changing dimension logic for customer and branch attributes that affect historical reporting.

Output tables:
- `stg_customers`
- `stg_locations`
- `dim_customer`
- `dim_location`

### Maintenance Event Ingestion
Purpose:
Expose the operational cost of downtime and service interruptions.

Design:
- Load inspection, repair, cleaning, and work-order events.
- Standardize maintenance types, severity, open/close times, cost, and vehicle linkage.
- Translate maintenance windows into downtime facts for utilization and availability reporting.

Output tables:
- `stg_maintenance_events`
- `core_maintenance_event`
- `fact_maintenance_downtime`

### Streaming Event Processing
Purpose:
Reduce latency for operational analytics and alerting.

Design:
- Consume booking, pricing, and fleet status topics from Kafka.
- Validate payload shape and schema version.
- Deduplicate using event ID plus source timestamp semantics.
- Write raw event bodies to object storage and standardized records to staging tables.
- Support late-arriving event reconciliation against batch extracts.

Near-real-time outputs:
- Updated availability indicators
- Booking pace metrics
- Recent pricing change visibility
- Operational alert datasets

### Canonical Modeling
Purpose:
Create business-stable, source-agnostic entities.

Design:
- Map source-specific keys to canonical IDs.
- Harmonize statuses across booking, vehicle, and maintenance domains.
- Resolve cross-system joins between bookings, vehicles, customers, and locations.
- Maintain effective dating and source provenance for all critical dimensions.

### Analytical Mart Generation
Purpose:
Publish trusted, performant reporting models.

Planned marts:
- Utilization mart by date, location, and vehicle class
- Revenue mart by booking, location, and channel
- Pricing effectiveness mart comparing offered price, conversion, and realized revenue
- Demand mart comparing booking pace, pickup volume, and historical seasonal baselines
- Maintenance impact mart showing downtime and revenue-at-risk exposure

### Forecasting Dataset Generation
Purpose:
Create model-ready time series datasets for demand forecasting.

Design:
- Aggregate daily booking demand by location and vehicle class.
- Join pricing, fleet availability, holidays, seasonality, and optional weather/external signals.
- Build lag features, rolling averages, lead indicators, and capacity constraints.
- Persist training and scoring feature tables with versioned generation logic.

## 7. Analytics and ML Components

### Demand Forecasting
Primary objective:
Forecast future booking demand at the location-by-vehicle-class-by-date grain.

Feature candidates:
- Historical bookings and cancellations
- Booking lead time and pace
- Location seasonality and holiday calendars
- Current and recent pricing levels
- Fleet availability and out-of-service counts
- Local events, weather, or airport traffic proxies where available

Outputs:
- Short-term demand forecast
- Confidence intervals
- Forecast versus actual tracking
- Capacity risk indicators

### Fleet Utilization Analytics
Questions answered:
- How much of the fleet is revenue-generating versus idle?
- Which locations are over- or under-supplied by class?
- How much availability is lost to maintenance or turnaround delays?

Key metrics:
- Utilization rate
- Revenue per available car day
- Idle days per vehicle
- Downtime rate
- Turnaround time

### Pricing Analysis
Focus areas:
- Rate changes versus booking conversion
- Price elasticity by location, date bucket, and vehicle class
- Discount effectiveness
- Revenue uplift from yield decisions
- Outlier pricing or override patterns

### Revenue Reporting
Reporting outputs:
- Revenue by branch, region, channel, customer segment, and vehicle class
- Net revenue after discounts and adjustments
- Daily, weekly, and monthly trend reporting
- Booked versus realized revenue comparisons

### Operational KPI Generation
KPIs should include:
- Booking volume
- Cancellation rate
- No-show rate if supported
- Pickup and return punctuality
- Vehicle availability rate
- Fleet downtime percentage
- Forecast accuracy
- Branch-level utilization and revenue efficiency

### Rules-Based Versus ML-Based Logic
The project should demonstrate both deterministic analytics engineering and advanced ML.

Rules-based components:
- Data quality checks
- Status normalization
- SLA monitoring
- Basic pricing threshold alerts
- Capacity risk flags using configurable thresholds

ML-based components:
- Demand forecasting
- Optional pricing recommendation scoring
- Anomaly detection for unusual booking or utilization behavior

This distinction is important because a production platform must continue delivering value even when ML components are retraining, degraded, or not yet deployed.

## 8. Operational Design

### Scheduling
Proposed orchestration cadence:
- Booking ingestion: every 15 to 30 minutes for batch pull plus streaming for key events.
- Fleet inventory snapshots: hourly, with more frequent streaming updates for critical states.
- Pricing ingestion: every 15 minutes or event-driven.
- Customer and location master data: daily, with ad hoc refresh support.
- Maintenance ingestion: hourly or aligned to work-order event frequency.
- Mart rebuilds: hourly for operational marts, daily for heavy executive or finance aggregates.
- Forecast dataset refresh: daily, with optional intra-day scoring for short-range demand views.

### SLAs
Example platform SLAs:
- Booking data available in staging within 30 minutes of source emission.
- Fleet status reflected in operational marts within 15 minutes for streaming-covered events.
- Daily executive reporting refreshed by 6:00 AM local warehouse region time.
- Forecast dataset ready by 7:00 AM for pricing and fleet planning workflows.

### Backfills
Backfill strategy should support:
- Historical reload by source and date range.
- Idempotent reprocessing of raw landed data without duplicating warehouse records.
- Warehouse partition rebuilds for impacted dates only.
- Source-aware replay from Kafka offsets or raw object partitions.

### Idempotency
All ingestion and transform jobs should be designed to be safely rerunnable.

Practices:
- Deterministic merge keys
- Watermark tracking with replay capability
- Event deduplication using source event ID and ingestion controls
- Upsert or replace logic at the appropriate grain

### Data Quality Checks
Checks should exist at multiple layers:
- Raw: file presence, schema version, extraction completeness
- Staging: type conformance, null thresholds, enum validation
- Core: referential integrity, uniqueness, lifecycle consistency
- Marts: metric sanity thresholds, reconciliation to source totals

Representative tests:
- Every booking references a valid pickup and return location.
- Vehicle status snapshots do not create impossible overlapping states.
- Pricing events have valid effective windows.
- Maintenance close timestamps are not earlier than open timestamps.

### Monitoring
Operational monitoring should include:
- DAG success/failure and runtime trends
- Consumer lag for streaming services
- Freshness by source domain
- Dead-letter queue counts
- Warehouse credit or compute consumption if available
- Data quality trend dashboards

### Alerting
Alerting routes should cover:
- Pipeline failures
- SLA breaches
- Quality threshold failures
- Dead-letter spikes
- Missing source extracts
- Material deviations in booking volume or utilization that may indicate upstream issues

### Failure Handling
Failure handling approach:
- Retry transient source/API failures with exponential backoff.
- Send malformed events to dead-letter storage.
- Quarantine bad files for investigation without blocking unrelated source domains.
- Support partial DAG reruns from task boundaries.
- Maintain runbooks for source outage scenarios and replay procedures.

## 9. Security and Governance

### Access Control
Security should be role-based and least-privilege.

Controls:
- Separate roles for ingestion services, transformation jobs, analysts, admins, and BI consumers.
- Restrict write access to raw and core layers.
- Provide read-only access to curated marts for most consumers.
- Use service principals or IAM roles instead of long-lived credentials.

### Sensitive Data Handling
Sensitive fields may include:
- Customer names
- Contact details
- Loyalty identifiers
- Payment-related references if present
- Driver or license-related attributes if ever modeled

Required protections:
- Mask or tokenize sensitive customer fields in analytics-facing layers.
- Avoid storing unnecessary sensitive attributes in marts.
- Encrypt data at rest and in transit.
- Tag sensitive columns for access enforcement and audit.

### Auditability
The system should support:
- End-to-end job execution logs
- Data change traceability via timestamps and source metadata
- Access logging for sensitive tables where supported
- Reproducibility of transformations and forecast datasets by versioned code and metadata

### Retention
Retention policy should be tiered:
- Raw landing data retained long enough for replay, audit, and compliance needs.
- Core and mart data retained according to business reporting requirements.
- Streaming dead-letter data retained for a shorter operational investigation window.
- Forecast feature snapshots retained for model reproducibility and backtesting.

### Metadata Management
Metadata expectations:
- Data catalog entries for major datasets
- Business glossary for KPI definitions
- Technical metadata for owners, refresh cadence, source systems, and quality expectations
- Lineage references in repository documentation and warehouse documentation

### Compliance-Oriented Design Considerations
Even if this is a portfolio project, the design should reflect compliance-aware engineering:
- Minimize collection of personally identifiable information.
- Apply data classification and documented access controls.
- Support deletion or suppression workflows if customer privacy requirements apply.
- Separate development and production-style environments conceptually.
- Ensure secrets are managed through environment variables or secret stores, not committed code.

## 10. Portfolio Positioning

### Senior Data Engineer
This project demonstrates senior data engineering skills by showing:
- Multi-source ingestion design across APIs, files, and event streams
- Layered warehouse architecture with raw, staging, core, and mart zones
- Incremental processing, idempotency, backfills, and schema evolution planning
- Production-quality observability, data quality, and lineage thinking

### Senior Cloud Engineer
This project demonstrates senior cloud engineering skills by showing:
- Cloud-native storage and eventing architecture
- Infrastructure-as-code with Terraform
- Secure service-to-service access patterns
- Containerized local development and CI/CD deployment workflows
- Managed compute and warehouse integration patterns

### Senior Database Engineer
This project demonstrates senior database engineering skills by showing:
- Thoughtful logical and physical modeling
- Dimensional design for high-value analytics
- Partitioning, clustering, and performance-aware storage choices
- Warehouse-centric transformation strategy and semantic reporting design

### Senior Database Administrator
This project demonstrates DBA-oriented strengths by showing:
- Role-based access planning
- Data retention, auditing, and governance controls
- Operational SLAs, recovery, and replay considerations
- Metadata, lineage, and workload management awareness

### Hybrid Architect / Engineer / DBA
This project is especially strong for hybrid roles because it connects:
- Platform architecture
- Data engineering implementation
- Warehouse modeling
- Governance and operational reliability
- Analytics and ML enablement

As a portfolio artifact, `car-rental-analytics-platform` should read like a realistic production blueprint that could guide a team from initial repository scaffolding through implementation, hardening, and demonstration of measurable business value.
