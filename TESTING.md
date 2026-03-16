# Testing

## Testing Strategy

The platform uses layered testing to validate code, data contracts, transformations, and analytical outputs.

## Python Tests

- unit tests for parsing, checkpointing, and transformation helpers
- integration-style tests for connector behavior against mocked payloads
- schema validation tests for streaming records

## SQL and Data Tests

- uniqueness and non-null checks for business keys
- referential integrity checks between facts and dimensions
- accepted values tests for statuses and enums
- metric sanity checks for negative revenue, invalid durations, or impossible utilization
- booking pace checks to ensure pickup-date demand is not undercounted after late-arriving modifications
- pricing-window overlap checks to detect conflicting effective rates for the same branch, class, and channel
- branch-level reconciliation checks between operational booking counts and curated marts
- freshness and completeness checks against expected source extract windows

## Operational Validation

- Airflow DAG import tests
- notebook structure validation
- pipeline smoke tests against sample data
- SQL asset validation to confirm required warehouse DDL, marts, and tests exist in the repo
- dbt-style model metadata validation to ensure sources, descriptions, and model-level tests remain documented

## Release Criteria

- CI passes
- critical SQL tests pass
- no unreviewed schema contract changes
- documentation updated for behavior changes
