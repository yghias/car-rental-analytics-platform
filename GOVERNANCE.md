# Governance

## Objectives

Governance in this project is designed to make analytical outputs explainable, auditable, and safe to operate in a multi-stakeholder environment. The goal is not just compliance language; it is reliable data ownership and decision trust.

## Domain Ownership

- Reservations domain owner: commercial operations or reservation systems team
- Fleet domain owner: fleet operations team
- Pricing domain owner: revenue management
- Customer domain owner: customer platform or CRM team
- Location domain owner: branch operations master data steward
- Maintenance domain owner: maintenance operations or vendor integration owner
- Platform owner: data engineering

## Authoritative Source Rules

- Booking status, trip dates, and booking amounts come from the reservation platform.
- Vehicle identity and operational status come from the fleet system.
- Effective pricing comes from the pricing engine or approved override feed.
- Customer loyalty and profile attributes come from the customer platform.
- Branch hierarchy comes from the location master.
- Maintenance duration and closure state come from the work-order system.

Where source systems overlap, precedence is determined by domain ownership and effective timestamp.

## Data Classification

### Public / low sensitivity
- branch metadata
- aggregate metrics
- vehicle class reference data

### Internal
- operational KPIs
- pricing event history
- branch utilization detail

### Confidential
- customer identifiers
- booking-level revenue
- maintenance cost details

## Data Quality Stewardship

Quality is owned jointly:

- source teams own upstream correctness
- data engineering owns pipeline integrity, freshness, and transformation correctness
- analytics engineering owns metric definitions and mart validation
- consumers own escalation when business expectations materially diverge

## Lineage Requirements

Business-critical marts should be traceable back to:

- source system
- extraction run ID
- raw object path or event topic
- staging model
- canonical model
- mart model

## Metadata Expectations

Every major dataset should define:

- owner
- refresh frequency
- SLA
- authoritative source
- key columns
- sensitive fields
- downstream consumers

## Retention Guidance

- raw landing data: retained for replay and audit windows
- staging and core: retained for historical analytics and reconciliation
- dead-letter events: retained for operational investigation
- model feature snapshots: retained to support forecast reproducibility

## Change Management

Schema changes should follow:

1. source contract review
2. staging impact assessment
3. downstream model validation
4. documentation update
5. deployment with monitoring
