create or replace table marts.fact_vehicle_utilization as
select
    f.snapshot_date,
    f.vehicle_id,
    f.current_location_id as location_id,
    f.vehicle_class,
    case when f.available_flag then 1 else 0 end as available_vehicle_count,
    case when f.fleet_status_standardized = 'reserved' then 1 else 0 end as reserved_vehicle_count,
    case when coalesce(f.in_maintenance, false) then 1 else 0 end as maintenance_vehicle_count
from core.fleet_status_snapshot f;

create or replace table marts.fact_revenue as
select
    b.booking_id,
    b.pickup_location_id as location_id,
    b.vehicle_class,
    date_trunc('day', b.scheduled_pickup_ts) as service_date,
    b.booked_revenue_amount,
    coalesce(b.final_revenue_amount, b.booked_revenue_amount) as realized_revenue_amount
from core.booking b;

create or replace table marts.fact_pricing_event as
select
    p.pricing_event_id,
    p.location_id,
    p.vehicle_class,
    p.channel,
    p.rate_amount,
    p.effective_start_ts,
    p.effective_end_ts,
    datediff('day', p.effective_start_ts, p.effective_end_ts) as effective_days
from core.pricing_event p;
