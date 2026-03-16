# Sample Data

The `sample_data/` directory is intended for local demos and lightweight validation without requiring live provider access.

## Suggested contents

- `bookings/`
  reservation extracts or booking event samples
- `fleet/`
  vehicle inventory and status snapshots
- `pricing/`
  rate and override examples
- `customers/`
  anonymized customer profile samples
- `maintenance/`
  service and downtime records
- `locations/`
  branch hierarchy reference files

## Design notes

- Sample files should be anonymized and free of sensitive customer data.
- The shape should match staging model expectations closely enough for smoke testing.
- Sample partitions can mirror raw landing patterns to help demonstrate replay and backfill logic.

## Included Test Scenarios

The sample datasets are intentionally imperfect and cover:

- duplicate booking and fleet records
- late-arriving updates
- null fields in required business columns
- overlapping pricing windows
- invalid pricing effective ranges
- maintenance records with impossible timestamps
- schema drift via additive columns such as `promo_code`, `schema_version`, `discount_pct`, and `timezone`

These scenarios are meant to exercise the SQL validation logic in [sql/tests.sql](../sql/tests.sql) and the profiling notebook in [notebooks/data_quality_checks.ipynb](../notebooks/data_quality_checks.ipynb).
