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

create or replace table marts.mart_pricing_performance as
select
    p.service_date,
    p.location_id,
    p.vehicle_class,
    p.channel,
    p.booking_count,
    p.avg_rate_amount,
    p.realized_revenue_amount,
    lag(p.avg_rate_amount) over (
        partition by p.location_id, p.vehicle_class, p.channel
        order by p.service_date
    ) as prior_day_avg_rate_amount,
    p.realized_revenue_amount - lag(p.realized_revenue_amount) over (
        partition by p.location_id, p.vehicle_class, p.channel
        order by p.service_date
    ) as revenue_delta_vs_prior_day
from marts.fact_pricing_effectiveness p;

create or replace table marts.mart_revenue_summary as
select
    service_date,
    location_id,
    vehicle_class,
    sum(realized_revenue_amount) as realized_revenue_amount,
    sum(booked_revenue_amount) as booked_revenue_amount,
    count(distinct booking_id) as booking_count,
    round(avg(realized_revenue_amount), 2) as avg_revenue_per_booking
from marts.fact_revenue
group by 1, 2, 3;

create or replace table marts.mart_booking_conversion as
select
    pickup_date as service_date,
    location_id,
    vehicle_class,
    count(distinct booking_id) as total_booking_count,
    sum(case when booking_status <> 'cancelled' then 1 else 0 end) as converted_booking_count,
    sum(case when booking_status = 'cancelled' then 1 else 0 end) as cancelled_booking_count,
    case
        when count(distinct booking_id) = 0 then 0
        else round(
            sum(case when booking_status <> 'cancelled' then 1 else 0 end)
            / count(distinct booking_id),
            4
        )
    end as booking_conversion_rate
from marts.fact_booking
group by 1, 2, 3;

create or replace table marts.mart_channel_mix as
select
    d.service_date,
    d.location_id,
    d.vehicle_class,
    d.booking_channel,
    sum(d.active_booking_day_count) as active_booking_day_count,
    row_number() over (
        partition by d.service_date, d.location_id, d.vehicle_class
        order by sum(d.active_booking_day_count) desc
    ) as booking_channel_rank
from marts.fact_booking_day d
group by 1, 2, 3, 4;

create or replace table marts.mart_downtime_exposure as
select
    m.location_id,
    v.vehicle_class,
    sum(m.downtime_hours) as total_downtime_hours,
    sum(m.estimated_cost_amount) as maintenance_cost_amount,
    count(distinct m.vehicle_id) as impacted_vehicle_count
from marts.fact_maintenance_downtime m
left join marts.dim_vehicle v
  on m.vehicle_id = v.vehicle_id
group by 1, 2;

create or replace table marts.mart_location_forecast_gap as
select
    f.service_date,
    f.location_id,
    f.vehicle_class,
    f.actual_booking_count,
    f.forecasted_booking_count,
    f.forecast_error,
    case
        when f.actual_booking_count = 0 then null
        else round(abs(f.forecast_error) / f.actual_booking_count, 4)
    end as forecast_error_pct
from marts.fact_forecast_actual f;
