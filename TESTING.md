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

## Operational Validation

- Airflow DAG import tests
- notebook structure validation
- pipeline smoke tests against sample data

## Release Criteria

- CI passes
- critical SQL tests pass
- no unreviewed schema contract changes
- documentation updated for behavior changes
