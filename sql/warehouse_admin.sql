-- Warehouse administration patterns for a production-style analytics platform.
-- These statements are illustrative and may require warehouse-specific syntax adjustments.

alter table if exists core.booking cluster by (scheduled_pickup_ts, pickup_location_id);
alter table if exists core.fleet_status_snapshot cluster by (snapshot_date, current_location_id);
alter table if exists core.pricing_event cluster by (effective_start_ts, location_id, vehicle_class);

comment on table core.booking is 'Canonical reservation record used for fleet, revenue, and booking pace analytics.';
comment on table core.fleet_status_snapshot is 'Daily or intra-day vehicle status snapshot supporting utilization and downtime reporting.';
comment on table marts.mart_branch_daily_performance is 'Branch-level daily performance mart for finance, operations, and executive dashboards.';

-- Example least-privilege grants.
grant usage on schema marts to role analyst_ro;
grant select on all tables in schema marts to role analyst_ro;
grant usage on schema core to role analytics_engineer_rw;
grant select, insert, update, delete on all tables in schema core to role analytics_engineer_rw;

-- Example retention and fail-safe posture notes.
-- Raw landing storage should retain replayable source extracts for incident recovery and backfills.
-- Operational audit schemas should retain run metadata and quality results long enough for RCA analysis.
