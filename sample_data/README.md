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
