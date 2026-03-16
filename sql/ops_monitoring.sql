create or replace view ops.pipeline_health_daily as
select
    cast(started_at as date) as run_date,
    pipeline_name,
    count(*) as run_count,
    sum(case when status = 'success' then 1 else 0 end) as success_count,
    sum(case when status <> 'success' then 1 else 0 end) as failure_count,
    avg(datediff('second', started_at, completed_at)) as avg_runtime_seconds
from ops.pipeline_run
group by 1, 2;

create or replace view ops.data_quality_failures_daily as
select
    cast(evaluated_at as date) as evaluation_date,
    dataset_name,
    severity,
    count(*) as failed_check_count
from ops.data_quality_result
where passed_flag = false
group by 1, 2, 3;

create or replace view ops.freshness_gaps as
select
    'bookings' as dataset_name,
    max(updated_at) as latest_source_ts,
    datediff('minute', max(updated_at), current_timestamp) as freshness_gap_minutes
from staging.stg_bookings
union all
select
    'fleet_inventory',
    max(updated_at),
    datediff('minute', max(updated_at), current_timestamp)
from staging.stg_fleet_inventory
union all
select
    'pricing_events',
    max(updated_at),
    datediff('minute', max(updated_at), current_timestamp)
from staging.stg_pricing_events;
