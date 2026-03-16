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

create or replace table marts.fact_booking as
select
    b.booking_id,
    b.customer_id,
    b.pickup_location_id as location_id,
    b.vehicle_class,
    b.booking_status,
    cast(date_trunc('day', b.scheduled_pickup_ts) as date) as pickup_date,
    cast(date_trunc('day', b.scheduled_return_ts) as date) as return_date,
    greatest(datediff('day', b.scheduled_pickup_ts, b.scheduled_return_ts), 1) as scheduled_rental_days,
    b.booked_revenue_amount
from core.booking b;

create or replace table marts.fact_booking_pace as
select
    cast(date_trunc('day', b.scheduled_pickup_ts) as date) as pickup_date,
    b.pickup_location_id as location_id,
    b.vehicle_class,
    cast(date_trunc('day', b.booking_created_ts) as date) as booking_created_date,
    count(distinct b.booking_id) as booking_count
from core.booking b
group by 1, 2, 3, 4;

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

create or replace table marts.fact_pricing_effectiveness as
select
    b.pickup_location_id as location_id,
    b.vehicle_class,
    cast(date_trunc('day', b.scheduled_pickup_ts) as date) as service_date,
    coalesce(p.channel, 'unknown') as channel,
    count(distinct b.booking_id) as booking_count,
    avg(p.rate_amount) as avg_rate_amount,
    sum(coalesce(b.final_revenue_amount, b.booked_revenue_amount)) as realized_revenue_amount
from core.booking b
left join core.pricing_event p
  on b.pickup_location_id = p.location_id
 and b.vehicle_class = p.vehicle_class
 and b.scheduled_pickup_ts >= p.effective_start_ts
 and b.scheduled_pickup_ts < p.effective_end_ts
group by 1, 2, 3, 4;

create or replace table marts.fact_maintenance_downtime as
select
    maintenance_event_id,
    vehicle_id,
    location_id,
    maintenance_type,
    greatest(datediff('hour', opened_at, closed_at), 0) as downtime_hours,
    estimated_cost_amount
from core.maintenance_event;

create or replace table marts.mart_branch_daily_performance as
select
    r.service_date,
    r.location_id,
    r.vehicle_class,
    count(distinct r.booking_id) as completed_booking_count,
    sum(r.realized_revenue_amount) as realized_revenue_amount,
    sum(u.available_vehicle_count) as available_vehicle_count,
    sum(u.maintenance_vehicle_count) as maintenance_vehicle_count,
    case
        when sum(u.available_vehicle_count) = 0 then null
        else sum(r.realized_revenue_amount) / sum(u.available_vehicle_count)
    end as revenue_per_available_car_day
from marts.fact_revenue r
left join marts.fact_vehicle_utilization u
  on r.service_date = u.snapshot_date
 and r.location_id = u.location_id
 and r.vehicle_class = u.vehicle_class
group by 1, 2, 3;

create or replace table marts.mart_operational_kpis as
select
    b.pickup_date as service_date,
    b.location_id,
    b.vehicle_class,
    count(distinct b.booking_id) as booking_count,
    sum(case when b.booking_status = 'cancelled' then 1 else 0 end) as cancelled_booking_count,
    sum(coalesce(u.available_vehicle_count, 0)) as available_vehicle_count,
    sum(coalesce(u.maintenance_vehicle_count, 0)) as maintenance_vehicle_count,
    sum(coalesce(r.realized_revenue_amount, 0)) as realized_revenue_amount
from marts.fact_booking b
left join marts.fact_vehicle_utilization u
  on b.pickup_date = u.snapshot_date
 and b.location_id = u.location_id
 and b.vehicle_class = u.vehicle_class
left join marts.fact_revenue r
  on b.booking_id = r.booking_id
group by 1, 2, 3;
