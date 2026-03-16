# API Integrations

## Integration Philosophy

All external integrations are wrapped in explicit connector modules. Connectors are responsible for extraction, authentication, pagination, checkpointing, and raw persistence. They should not contain business transformation logic beyond source-normalization needed to land stable staging tables.

## Reservation API

### Purpose
Extract booking lifecycle data including create, modify, cancel, pickup, and return events.

### Expected endpoints
- `/bookings`
- `/bookings/{id}`
- `/bookings/changes`

### Extraction pattern
- incremental by `updated_at`
- paginated requests
- retry on transient errors
- persist raw payload for every page

### Key fields
- booking identifier
- customer identifier
- pickup and return timestamps
- pickup and return branch
- vehicle class
- price amount and currency
- status
- update timestamp

### Example payload
```json
{
  "booking_id": "B1001",
  "customer_id": "C201",
  "pickup_location_id": "DTW01",
  "return_location_id": "DTW01",
  "vehicle_class": "SUV",
  "booking_channel": "direct_web",
  "booking_status": "booked",
  "booking_created_ts": "2026-03-01T07:55:00Z",
  "scheduled_pickup_ts": "2026-03-01T10:00:00Z",
  "scheduled_return_ts": "2026-03-03T10:00:00Z",
  "booked_revenue_amount": 189.50,
  "updated_at": "2026-03-01T08:10:00Z"
}
```

## Fleet Inventory API

### Purpose
Capture vehicle master data and operational state.

### Expected endpoints
- `/vehicles`
- `/vehicles/status`
- `/vehicles/assignments`

### Notes
- vehicle status should be standardized because providers often expose vendor-specific enums
- VIN and internal fleet ID should both be retained

### Example payload
```json
{
  "vehicle_id": "V1001",
  "vin": "1HGBH41JXMN109186",
  "vehicle_class": "SUV",
  "current_location_id": "DTW01",
  "fleet_status": "available",
  "rentable_flag": true,
  "odometer_miles": 28411,
  "updated_at": "2026-03-01T08:00:00Z"
}
```

## Pricing API

### Purpose
Capture effective rates, discounts, and branch-level override behavior.

### Expected endpoints
- `/rates`
- `/rate-overrides`
- `/discounts`

### Design concerns
- ensure effective windows are inclusive and timezone-safe
- preserve both list price and override logic
- capture channel and branch scope explicitly

### Example payload
```json
{
  "pricing_event_id": "P1001",
  "location_id": "DTW01",
  "vehicle_class": "SUV",
  "channel": "direct_web",
  "rate_amount": 92.50,
  "effective_start_ts": "2026-03-01T00:00:00Z",
  "effective_end_ts": "2026-03-02T00:00:00Z",
  "updated_at": "2026-03-01T07:50:00Z"
}
```

## Customer API

### Purpose
Refresh customer profile and loyalty attributes used in analytics segmentation.

### Expected endpoints
- `/customers`
- `/customers/loyalty`

### Sensitive data policy
- do not propagate unnecessary PII to marts
- mask or tokenize direct identifiers where possible

## Location Feed

### Purpose
Refresh authoritative branch hierarchy and operating metadata.

### Common patterns
- daily file drop
- API or reference table sync

### Required fields
- branch code
- location name
- city, state, country
- region
- airport flag
- latitude and longitude if available

### Example row shape
```json
{
  "location_id": "DTW01",
  "location_name": "Detroit Airport",
  "city": "Detroit",
  "state": "MI",
  "region": "MIDWEST",
  "airport_flag": true,
  "updated_at": "2026-03-01T00:00:00Z"
}
```

## Maintenance Feed

### Purpose
Track repair windows and service interruptions.

### Required fields
- maintenance event ID
- vehicle identifier
- open timestamp
- close timestamp
- work-order category
- labor and parts cost where available

### Example payload
```json
{
  "maintenance_event_id": "M1001",
  "vehicle_id": "V1002",
  "location_id": "ORD01",
  "maintenance_type": "brake_service",
  "opened_at": "2026-03-01T03:00:00Z",
  "closed_at": "2026-03-01T08:00:00Z",
  "estimated_cost_amount": 420.00
}
```

## Data Contracts

Contract expectations enforced across connectors and staging:

- required columns must be present for each domain
- timestamps must be ISO-8601 parseable
- monetary amounts must be non-negative unless explicitly modeled as adjustments
- identifiers must remain stable across late-arriving corrections
- additive columns are allowed and preserved in raw storage
- renamed or type-shifted fields must be normalized in staging before loading core tables

## Schema Evolution Handling

Expected pipeline behavior:

- Added columns:
  persist in raw storage immediately and map into staging once reviewed
- Renamed fields:
  normalize in the source-specific extractor or staging SQL
- Type changes:
  cast conservatively in staging and quarantine records that no longer parse cleanly
- Backward compatibility:
  staging models should preserve canonical output columns even if upstream field names drift

## Integration Standards

Each connector should provide:

- source-specific configuration
- deterministic checkpointing
- extraction audit metrics
- typed normalized records
- source lineage metadata
- explicit error classification
