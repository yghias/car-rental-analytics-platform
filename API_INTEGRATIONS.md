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

## Integration Standards

Each connector should provide:

- source-specific configuration
- deterministic checkpointing
- extraction audit metrics
- typed normalized records
- source lineage metadata
- explicit error classification
