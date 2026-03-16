# Data Model

## Modeling Principles

The data model is designed to support both operational analysis and historical financial reporting. It follows a layered approach:

- raw models preserve source fidelity
- staging models normalize source schemas
- core models define canonical business entities
- marts expose dimensional facts and dimensions for reporting
- ML feature models provide time-series-ready forecast inputs

This pattern reduces coupling between upstream systems and downstream analytics while keeping lineage explicit.

## Conceptual Domains

### Reservation Demand
- bookings
- booking lifecycle events
- channels
- rate plans
- cancellations, extensions, and modifications

### Fleet Supply
- vehicles
- vehicle classes
- branch assignment
- availability status
- downtime and maintenance

### Commercial Controls
- pricing events
- discounts and promotions
- override policies
- realized revenue

### Customer and Geography
- customer profiles
- loyalty tiers
- pickup and return locations
- branch hierarchy and market regions

## Logical Model

### Core Entities

#### booking
Represents a reservation or rental transaction with a stable business key and lifecycle state.

Key attributes:
- booking_id
- source_booking_id
- customer_id
- booked_vehicle_class_id
- pickup_location_id
- return_location_id
- booking_channel
- rate_plan_id
- booking_status
- booking_created_ts
- scheduled_pickup_ts
- scheduled_return_ts
- actual_pickup_ts
- actual_return_ts
- booked_revenue_amount
- final_revenue_amount

#### booking_event
Captures booking state transitions as an append-only event table.

Examples:
- created
- modified
- canceled
- checked_out
- extended
- checked_in

#### vehicle
Master entity for a rentable car.

Key attributes:
- vehicle_id
- vin
- plate_number
- vehicle_class_id
- make
- model
- model_year
- acquisition_date
- disposal_date
- active_flag

#### fleet_inventory_snapshot
Point-in-time operational supply state for a vehicle.

Key attributes:
- snapshot_date
- vehicle_id
- current_location_id
- fleet_status
- rentable_flag
- odometer_miles
- out_of_service_flag

#### customer
Canonical customer profile used for segmentation and loyalty reporting.

#### location
Branch, airport, or partner location hierarchy used for network reporting.

#### pricing_event
Time-aware representation of rates, overrides, or discounts by date range, channel, location, and vehicle class.

#### maintenance_event
Operational service activity with duration and cost.

#### utilization_metric
Derived metric set representing vehicle use, idle time, and downtime over a defined period.

## Physical Model

### Warehouse Schemas

- `raw`
  external or landed representations of ingested source data
- `staging`
  typed source-normalized tables
- `core`
  canonical business entities and event histories
- `marts`
  dimensional facts and dimensions
- `ml`
  feature tables, training sets, and scored outputs
- `ops`
  run metadata, ingestion audit, and data quality results

### Storage Patterns

- Append-only event tables for booking and pricing changes
- Snapshot tables for fleet availability and daily supply views
- SCD2 dimensions for location and customer attributes that can change over time
- Partitioning or clustering by event date, pickup date, snapshot date, and location where supported

## Dimensional Strategy

### Fact Tables

- `fact_booking`
  Grain: one row per booking
- `fact_booking_day`
  Grain: one row per booking per rental day
- `fact_vehicle_utilization`
  Grain: one row per vehicle per date
- `fact_revenue`
  Grain: one row per booking, with optional daily revenue allocations
- `fact_pricing_event`
  Grain: one row per pricing decision event
- `fact_maintenance_downtime`
  Grain: one row per maintenance event
- `fact_forecast_actual`
  Grain: one row per location, vehicle class, and service date

### Dimensions

- `dim_date`
- `dim_location`
- `dim_vehicle`
- `dim_vehicle_class`
- `dim_customer`
- `dim_channel`
- `dim_rate_plan`

## Source-of-Truth Strategy

- Reservation platform is authoritative for booking status and booking dates.
- Fleet system is authoritative for vehicle identity and operational state.
- Pricing system is authoritative for effective rates and overrides.
- Customer platform is authoritative for customer attributes and loyalty status.
- Maintenance system is authoritative for repair state and downtime.
- Location master is authoritative for branch metadata and hierarchy.

Conflicts are resolved by domain ownership first, then by business-effective timestamp.

## Lineage and Metadata

Each core and mart model should include:

- source system identifier
- ingestion timestamp
- processing timestamp
- natural key or business key
- surrogate key where applicable
- model version tag or transformation lineage metadata

## Business-Critical Metrics

Derived from the model:

- fleet utilization rate
- available car days
- revenue per available car day
- cancellation rate
- average booking lead time
- maintenance downtime hours
- pricing conversion uplift
- forecast accuracy by location and class
