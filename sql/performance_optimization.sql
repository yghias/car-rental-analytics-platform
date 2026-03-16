-- Performance-oriented patterns for Snowflake-style warehouse tuning.

alter table if exists marts.fact_booking cluster by (pickup_date, location_id, vehicle_class);
alter table if exists marts.fact_revenue cluster by (service_date, location_id, vehicle_class);
alter table if exists marts.fact_vehicle_utilization cluster by (snapshot_date, location_id, vehicle_class);
alter table if exists marts.fact_pricing_effectiveness cluster by (service_date, location_id, vehicle_class, channel);

create or replace transient table marts.tmp_recent_booking_pace as
select
    pickup_date,
    location_id,
    vehicle_class,
    sum(booking_count) as booking_count
from marts.fact_booking_pace
where pickup_date >= dateadd('day', -30, current_date)
group by 1, 2, 3;

create or replace view ops.storage_optimization_candidates as
select
    table_schema,
    table_name,
    row_count,
    bytes,
    case
        when row_count = 0 then null
        else round(bytes / row_count, 2)
    end as bytes_per_row
from snowflake.account_usage.table_storage_metrics
where table_schema in ('CORE', 'MARTS', 'ML');

create or replace view ops.compute_hotspots as
select
    warehouse_name,
    query_type,
    count(*) as query_count,
    sum(total_elapsed_time) / 1000 as total_elapsed_seconds,
    sum(bytes_scanned) as total_bytes_scanned
from snowflake.account_usage.query_history
where start_time >= dateadd('day', -7, current_timestamp)
group by 1, 2;
