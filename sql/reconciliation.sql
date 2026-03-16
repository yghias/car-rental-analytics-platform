-- Source-to-target reconciliation patterns for operational validation.

create or replace view ops.recon_booking_volume as
select
    cast(updated_at as date) as business_date,
    count(*) as staging_booking_count,
    count(distinct booking_id) as staging_distinct_booking_count
from staging.stg_bookings
group by 1;

create or replace view ops.recon_booking_to_fact as
select
    s.business_date,
    s.staging_distinct_booking_count,
    coalesce(f.fact_booking_count, 0) as fact_booking_count,
    s.staging_distinct_booking_count - coalesce(f.fact_booking_count, 0) as booking_count_delta
from ops.recon_booking_volume s
left join (
    select
        pickup_date as business_date,
        count(distinct booking_id) as fact_booking_count
    from marts.fact_booking
    group by 1
) f
  on s.business_date = f.business_date;

create or replace view ops.recon_pricing_to_effectiveness as
select
    p.service_date,
    p.location_id,
    p.vehicle_class,
    p.channel,
    p.pricing_event_count,
    coalesce(e.booking_count, 0) as matched_booking_count,
    coalesce(e.realized_revenue_amount, 0) as matched_realized_revenue_amount
from core.pricing_daily_snapshot p
left join marts.fact_pricing_effectiveness e
  on p.service_date = e.service_date
 and p.location_id = e.location_id
 and p.vehicle_class = e.vehicle_class
 and p.channel = e.channel;

create or replace view ops.recon_vehicle_supply as
select
    d.snapshot_date,
    d.location_id,
    d.vehicle_class,
    d.fleet_vehicle_count,
    d.available_vehicle_count,
    coalesce(u.available_vehicle_count, 0) as mart_available_vehicle_count,
    d.available_vehicle_count - coalesce(u.available_vehicle_count, 0) as available_vehicle_delta
from core.vehicle_availability_daily d
left join (
    select
        snapshot_date,
        location_id,
        vehicle_class,
        sum(available_vehicle_count) as available_vehicle_count
    from marts.fact_vehicle_utilization
    group by 1, 2, 3
) u
  on d.snapshot_date = u.snapshot_date
 and d.location_id = u.location_id
 and d.vehicle_class = u.vehicle_class;

create or replace view ops.recon_revenue_consistency as
select
    r.service_date,
    r.location_id,
    r.vehicle_class,
    sum(r.booked_revenue_amount) as booked_revenue_amount,
    sum(r.realized_revenue_amount) as realized_revenue_amount,
    sum(case when r.realized_revenue_amount < r.booked_revenue_amount then 1 else 0 end) as below_booked_count
from marts.fact_revenue r
group by 1, 2, 3;
