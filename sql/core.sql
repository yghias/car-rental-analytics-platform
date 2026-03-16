create or replace table core.booking_enriched as
select
    b.booking_id,
    b.customer_id,
    c.loyalty_tier,
    c.country_code,
    b.pickup_location_id,
    lp.location_name as pickup_location_name,
    lp.region as pickup_region,
    b.return_location_id,
    lr.location_name as return_location_name,
    b.vehicle_class,
    b.booking_status,
    b.booking_created_ts,
    b.scheduled_pickup_ts,
    b.scheduled_return_ts,
    b.actual_pickup_ts,
    b.actual_return_ts,
    greatest(datediff('day', b.scheduled_pickup_ts, b.scheduled_return_ts), 1) as scheduled_rental_days,
    b.booked_revenue_amount,
    coalesce(b.final_revenue_amount, b.booked_revenue_amount) as final_revenue_amount,
    b.source_system,
    b.ingestion_ts
from core.booking b
left join core.customer c
  on b.customer_id = c.customer_id
 and c.is_current = true
left join core.location lp
  on b.pickup_location_id = lp.location_id
 and lp.is_current = true
left join core.location lr
  on b.return_location_id = lr.location_id
 and lr.is_current = true;

create or replace table core.vehicle_availability_daily as
select
    snapshot_date,
    current_location_id as location_id,
    vehicle_class,
    count(distinct vehicle_id) as fleet_vehicle_count,
    sum(case when available_flag then 1 else 0 end) as available_vehicle_count,
    sum(case when in_maintenance then 1 else 0 end) as maintenance_vehicle_count
from core.fleet_status_snapshot
group by 1, 2, 3;

create or replace table core.pricing_daily_snapshot as
select
    location_id,
    vehicle_class,
    channel,
    cast(date_trunc('day', effective_start_ts) as date) as service_date,
    avg(rate_amount) as avg_rate_amount,
    min(rate_amount) as min_rate_amount,
    max(rate_amount) as max_rate_amount,
    count(*) as pricing_event_count
from core.pricing_event
group by 1, 2, 3, 4;

create or replace table core.maintenance_vehicle_rollup as
select
    vehicle_id,
    location_id,
    count(*) as maintenance_event_count,
    sum(greatest(datediff('hour', opened_at, closed_at), 0)) as maintenance_downtime_hours,
    sum(estimated_cost_amount) as maintenance_cost_amount
from core.maintenance_event
group by 1, 2;
